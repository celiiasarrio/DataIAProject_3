"""PoC local del agente: login contra el backend FastAPI + chat interactivo.

Uso interactivo (recomendado):
    python -m agent.run_local

Uso one-shot (útil para tests):
    python -m agent.run_local --message "¿Cómo voy de notas?"

Credenciales:
    Por defecto se piden por stdin (getpass). También se pueden definir
    AGENT_EMAIL y AGENT_PASSWORD en agent/.env para saltarse el prompt.
"""

import argparse
import asyncio
import getpass
import sys
import uuid

import httpx
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai import types

from agent.agent import create_root_agent
from agent.config import settings


APP_NAME = "campus_assistant"


def login(email: str, password: str) -> str:
    with httpx.Client(base_url=settings.BACKEND_BASE_URL, timeout=settings.HTTP_TIMEOUT_SECONDS) as client:
        resp = client.post(
            "/api/v1/token",
            data={"username": email, "password": password},
            headers={"Content-Type": "application/x-www-form-urlencoded"},
        )
        if resp.is_error:
            raise RuntimeError(f"Login falló ({resp.status_code}): {resp.text}")
        return resp.json()["access_token"]


def fetch_profile(jwt: str) -> dict:
    with httpx.Client(base_url=settings.BACKEND_BASE_URL, timeout=settings.HTTP_TIMEOUT_SECONDS) as client:
        resp = client.get("/api/v1/users/me", headers={"Authorization": f"Bearer {jwt}"})
        resp.raise_for_status()
        return resp.json()


async def _build_session(jwt: str, profile: dict):
    user_id = profile["id"]
    user_role = profile.get("rol") or "desconocido"
    user_name = f"{profile.get('nombre', '')} {profile.get('apellido', '')}".strip()
    session_service = InMemorySessionService()
    session = await session_service.create_session(
        app_name=APP_NAME,
        user_id=user_id,
        session_id=str(uuid.uuid4()),
        state={
            "jwt": jwt,
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
    return runner, session, user_id


async def _send(runner: Runner, user_id: str, session_id: str, text: str) -> str:
    content = types.Content(role="user", parts=[types.Part(text=text)])
    output = []
    async for event in runner.run_async(user_id=user_id, session_id=session_id, new_message=content):
        if event.is_final_response() and event.content and event.content.parts:
            output.append("".join(p.text or "" for p in event.content.parts))
    return "\n".join(output).strip()


async def one_shot(jwt: str, profile: dict, message: str) -> None:
    runner, session, user_id = await _build_session(jwt, profile)
    reply = await _send(runner, user_id, session.id, message)
    print(f"\nAsistente > {reply}\n")


async def chat_loop(jwt: str, profile: dict) -> None:
    runner, session, user_id = await _build_session(jwt, profile)
    print(f"\nHola {session.state['user_name']} ({session.state['user_role']}). Escribe 'salir' para terminar.\n")

    while True:
        try:
            user_msg = input("Tú > ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            return
        if not user_msg:
            continue
        if user_msg.lower() in {"salir", "exit", "quit"}:
            return
        reply = await _send(runner, user_id, session.id, user_msg)
        if reply:
            print(f"\nAsistente > {reply}\n")


def resolve_credentials() -> tuple[str, str]:
    email = settings.AGENT_EMAIL or input("Email: ").strip()
    password = settings.AGENT_PASSWORD or getpass.getpass("Contraseña: ")
    return email, password


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--message", "-m", help="Enviar un único mensaje y salir (modo no-interactivo)")
    args = parser.parse_args()

    email, password = resolve_credentials()

    try:
        jwt = login(email, password)
    except Exception as exc:
        print(f"Error de login: {exc}", file=sys.stderr)
        sys.exit(1)

    profile = fetch_profile(jwt)

    if args.message:
        asyncio.run(one_shot(jwt, profile, args.message))
    else:
        asyncio.run(chat_loop(jwt, profile))


if __name__ == "__main__":
    main()
