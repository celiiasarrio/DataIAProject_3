from typing import List, Literal, Optional
import uuid

import httpx
from fastapi import FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai import types
from pydantic import BaseModel

from agent.agent import create_root_agent
from agent.config import settings


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
    history: List[ChatHistoryMessage] = []


class ChatResponse(BaseModel):
    reply: str


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


async def run_agent(jwt_token: str, profile: dict, message: str) -> str:
    session_service = InMemorySessionService()
    user_id = profile["id"]
    user_role = profile.get("rol") or "desconocido"
    user_name = f"{profile.get('nombre', '')} {profile.get('apellido', '')}".strip()

    session = await session_service.create_session(
        app_name=APP_NAME,
        user_id=user_id,
        session_id=str(uuid.uuid4()),
        state={
            "jwt": jwt_token,
            "user_id": user_id,
            "user_role": user_role,
            "user_name": user_name,
        },
    )
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
    return reply


@app.get("/health")
def health():
    return {
        "status": "ok",
        "backend_base_url": settings.BACKEND_BASE_URL,
        "model": settings.MODEL,
        "vertex_ai": settings.GOOGLE_GENAI_USE_VERTEXAI,
    }


@app.post("/api/v1/agent/chat", response_model=ChatResponse)
async def chat(
    payload: ChatRequest,
    authorization: Optional[str] = Header(default=None),
):
    jwt_token = extract_bearer_token(authorization)
    profile = fetch_profile(jwt_token)
    composed_message = build_message(payload.history, payload.message)
    reply = await run_agent(jwt_token, profile, composed_message)
    return ChatResponse(reply=reply)
