from functools import lru_cache
from typing import List, Literal, Optional
import uuid

import httpx
from fastapi import FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai import types
from pydantic import BaseModel, Field

from agent.agent import create_root_agent
from agent.config import settings
from agent.firestore_session_service import FirestoreSessionService


APP_NAME = "campus_assistant"

app = FastAPI(
    title="EDEM Agent Service",
    description="Servicio HTTP del asistente del campus para frontend y backoffice.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class ChatHistoryMessage(BaseModel):
    role: Literal["user", "assistant"]
    content: str


class ChatRequest(BaseModel):
    message: str
    history: List[ChatHistoryMessage] = Field(default_factory=list)
    session_id: Optional[str] = None


class ChatResponse(BaseModel):
    reply: str
    session_id: str


def extract_bearer_token(authorization: Optional[str]) -> str:
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header requerido")
    parts = authorization.split(" ", 1)
    if len(parts) != 2 or parts[0].lower() != "bearer" or not parts[1].strip():
        raise HTTPException(status_code=401, detail="Bearer token invalido")
    return parts[1].strip()


def fetch_profile(jwt_token: str) -> dict:
    try:
        with httpx.Client(
            base_url=settings.BACKEND_BASE_URL,
            timeout=settings.HTTP_TIMEOUT_SECONDS,
        ) as client:
            resp = client.get(
                "/api/v1/users/me",
                headers={"Authorization": f"Bearer {jwt_token}"},
            )
    except httpx.RequestError as exc:
        raise HTTPException(status_code=502, detail=f"No se pudo contactar con el backend: {exc}") from exc

    if resp.status_code == 401:
        raise HTTPException(status_code=401, detail="JWT invalido o expirado")
    if resp.is_error:
        raise HTTPException(status_code=502, detail=f"Error del backend al cargar perfil: {resp.text}")
    return resp.json()


def build_message(history: List[ChatHistoryMessage], message: str) -> str:
    trimmed_history = history[-12:]
    if not trimmed_history:
        return message

    lines = []
    for item in trimmed_history:
        prefix = "Usuario" if item.role == "user" else "Asistente"
        lines.append(f"{prefix}: {item.content}")

    return (
        "Contexto reciente de la conversación:\n"
        + "\n".join(lines)
        + "\n\nNueva petición del usuario:\n"
        + message
    )


@lru_cache(maxsize=1)
def get_session_service():
    if settings.FIRESTORE_PROJECT:
        return FirestoreSessionService(
            project=settings.FIRESTORE_PROJECT,
            database=settings.FIRESTORE_DATABASE,
            root_collection=settings.FIRESTORE_COLLECTION,
        )
    return InMemorySessionService()


def build_runtime_state(jwt_token: str, profile: dict) -> dict:
    user_id = profile["id"]
    user_role = profile.get("rol") or "desconocido"
    user_name = f"{profile.get('nombre', '')} {profile.get('apellido', '')}".strip()
    return {
        "jwt": jwt_token,
        "user_id": user_id,
        "user_role": user_role,
        "user_name": user_name,
    }


async def ensure_session(jwt_token: str, profile: dict, session_id: Optional[str]):
    session_service = get_session_service()
    runtime_state = build_runtime_state(jwt_token, profile)
    user_id = profile["id"]

    if hasattr(session_service, "set_volatile_state") and session_id:
        session_service.set_volatile_state(
            app_name=APP_NAME,
            user_id=user_id,
            session_id=session_id,
            state=runtime_state,
        )

    if session_id:
        session = await session_service.get_session(
            app_name=APP_NAME,
            user_id=user_id,
            session_id=session_id,
        )
        if session is not None:
            session.state.update(runtime_state)
            return session_service, session

    session = await session_service.create_session(
        app_name=APP_NAME,
        user_id=user_id,
        session_id=session_id or str(uuid.uuid4()),
        state=runtime_state,
    )
    if hasattr(session_service, "set_volatile_state"):
        session_service.set_volatile_state(
            app_name=APP_NAME,
            user_id=user_id,
            session_id=session.id,
            state=runtime_state,
        )
    return session_service, session


async def run_agent(jwt_token: str, profile: dict, message: str, session_id: Optional[str]) -> tuple[str, str]:
    session_service, session = await ensure_session(jwt_token=jwt_token, profile=profile, session_id=session_id)
    user_id = profile["id"]
    user_role = profile.get("rol") or "desconocido"
    user_name = f"{profile.get('nombre', '')} {profile.get('apellido', '')}".strip()

    runner = Runner(
        agent=create_root_agent(user_role=user_role, user_name=user_name, user_id=user_id),
        app_name=APP_NAME,
        session_service=session_service,
    )
    content = types.Content(role="user", parts=[types.Part(text=message)])
    output_parts: List[str] = []
    async for event in runner.run_async(user_id=user_id, session_id=session.id, new_message=content):
        if event.is_final_response() and event.content and event.content.parts:
            output_parts.append("".join(part.text or "" for part in event.content.parts))

    reply = "\n".join(part for part in output_parts if part).strip()
    if not reply:
        raise HTTPException(status_code=502, detail="El agente no devolvió respuesta")
    return reply, session.id


@app.get("/health")
def health():
    session_backend = "firestore" if settings.FIRESTORE_PROJECT else "memory"
    return {
        "status": "ok",
        "backend_base_url": settings.BACKEND_BASE_URL,
        "model": settings.MODEL,
        "vertex_ai": settings.GOOGLE_GENAI_USE_VERTEXAI,
        "session_backend": session_backend,
        "firestore_project": settings.FIRESTORE_PROJECT or None,
    }


@app.post("/api/v1/agent/chat", response_model=ChatResponse)
async def chat(
    payload: ChatRequest,
    authorization: Optional[str] = Header(default=None),
):
    jwt_token = extract_bearer_token(authorization)
    profile = fetch_profile(jwt_token)
    composed_message = payload.message
    if payload.history and not payload.session_id:
        composed_message = build_message(payload.history, payload.message)

    reply, resolved_session_id = await run_agent(
        jwt_token,
        profile,
        composed_message,
        payload.session_id,
    )
    return ChatResponse(reply=reply, session_id=resolved_session_id)
