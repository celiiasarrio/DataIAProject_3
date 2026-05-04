#!/usr/bin/env python3
"""Smoke test para validar backend + agent del campus.

Flujo principal:
1. Comprueba /health de backend y agent.
2. Hace login real contra /api/v1/token.
3. Lee /api/v1/users/me con el JWT.
4. Abre un chat contra /api/v1/agent/chat.
5. Reutiliza el mismo session_id en un segundo turno.
6. Guarda session_id en disco para reanudarlo con --resume.

Modo persistencia:
- Ejecuta una primera vez sin --resume.
- Reinicia el servicio del agente.
- Ejecuta otra vez con --resume para comprobar que el session_id sigue vivo.
"""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Optional
from urllib import error, parse, request


DEFAULT_BACKEND_URL = "http://localhost:8080"
DEFAULT_AGENT_URL = "http://localhost:8081"
DEFAULT_USERNAME = "ahsoka.tano@edem.es"
DEFAULT_PASSWORD = "demo123"
DEFAULT_MESSAGE_1 = "¿Cómo voy de asistencia?"
DEFAULT_MESSAGE_2 = "¿Y mis notas?"
DEFAULT_RESUME_MESSAGE = "Sigue con el hilo y dime otra vez mi estado general."
DEFAULT_SESSION_FILE = ".smoke_agent_session.json"


class SmokeTestError(RuntimeError):
    """Error de validación del smoke test."""


@dataclass
class SessionSnapshot:
    session_id: str
    user_id: str
    user_role: str
    backend_url: str
    agent_url: str


def pretty_json(payload: Any) -> str:
    return json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True)


def join_url(base_url: str, path: str) -> str:
    return f"{base_url.rstrip('/')}{path}"


def http_json(
    method: str,
    url: str,
    *,
    data: Optional[dict[str, Any]] = None,
    form: Optional[dict[str, str]] = None,
    headers: Optional[dict[str, str]] = None,
    timeout: float = 20.0,
) -> tuple[int, dict[str, Any]]:
    req_headers = dict(headers or {})
    body: Optional[bytes] = None

    if data is not None:
        req_headers["Content-Type"] = "application/json"
        body = json.dumps(data).encode("utf-8")
    elif form is not None:
        req_headers["Content-Type"] = "application/x-www-form-urlencoded"
        body = parse.urlencode(form).encode("utf-8")

    req = request.Request(url, method=method.upper(), data=body, headers=req_headers)

    try:
        with request.urlopen(req, timeout=timeout) as response:
            raw = response.read().decode("utf-8")
            payload = json.loads(raw) if raw else {}
            return response.status, payload
    except error.HTTPError as exc:
        raw = exc.read().decode("utf-8", errors="replace")
        try:
            payload = json.loads(raw) if raw else {}
        except json.JSONDecodeError:
            payload = {"raw": raw}
        return exc.code, payload
    except error.URLError as exc:
        raise SmokeTestError(f"No se pudo conectar con {url}: {exc.reason}") from exc


def print_step(title: str) -> None:
    print(f"\n[{title}]")


def expect_status(status: int, expected: int, context: str, payload: dict[str, Any]) -> None:
    if status != expected:
        raise SmokeTestError(
            f"{context} devolvió HTTP {status}, esperado {expected}.\n"
            f"Respuesta:\n{pretty_json(payload)}"
        )


def expect_truthy(value: Any, context: str) -> None:
    if not value:
        raise SmokeTestError(f"Falta valor esperado en {context}.")


def normalize_role(profile: dict[str, Any]) -> str:
    return str(profile.get("rol") or "desconocido")


def save_session_snapshot(path: Path, snapshot: SessionSnapshot) -> None:
    payload = {
        "session_id": snapshot.session_id,
        "user_id": snapshot.user_id,
        "user_role": snapshot.user_role,
        "backend_url": snapshot.backend_url,
        "agent_url": snapshot.agent_url,
    }
    path.write_text(pretty_json(payload) + "\n", encoding="utf-8")


def load_session_snapshot(path: Path) -> SessionSnapshot:
    if not path.exists():
        raise SmokeTestError(
            f"No existe el fichero de sesión {path}. Ejecuta primero el smoke test sin --resume."
        )
    payload = json.loads(path.read_text(encoding="utf-8"))
    return SessionSnapshot(
        session_id=payload["session_id"],
        user_id=payload["user_id"],
        user_role=payload["user_role"],
        backend_url=payload["backend_url"],
        agent_url=payload["agent_url"],
    )


def check_health(base_url: str, label: str) -> dict[str, Any]:
    print_step(f"health {label}")
    status, payload = http_json("GET", join_url(base_url, "/health"))
    expect_status(status, 200, f"/health de {label}", payload)
    print(pretty_json(payload))
    return payload


def login(backend_url: str, username: str, password: str) -> str:
    print_step("login")
    status, payload = http_json(
        "POST",
        join_url(backend_url, "/api/v1/token"),
        form={"username": username, "password": password},
    )
    expect_status(status, 200, "login", payload)
    token = payload.get("access_token")
    expect_truthy(token, "login.access_token")
    print(f"Usuario autenticado: {username}")
    return str(token)


def get_profile(backend_url: str, token: str) -> dict[str, Any]:
    print_step("profile")
    status, payload = http_json(
        "GET",
        join_url(backend_url, "/api/v1/users/me"),
        headers={"Authorization": f"Bearer {token}"},
    )
    expect_status(status, 200, "perfil", payload)
    print(pretty_json(payload))
    return payload


def chat(
    agent_url: str,
    token: str,
    message: str,
    *,
    session_id: Optional[str] = None,
) -> dict[str, Any]:
    status, payload = http_json(
        "POST",
        join_url(agent_url, "/api/v1/agent/chat"),
        data={"message": message, "session_id": session_id},
        headers={"Authorization": f"Bearer {token}"},
        timeout=60.0,
    )
    expect_status(status, 200, "chat del agente", payload)
    expect_truthy(payload.get("reply"), "chat.reply")
    expect_truthy(payload.get("session_id"), "chat.session_id")
    return payload


def run_new_session(args: argparse.Namespace) -> int:
    check_health(args.backend_url, "backend")
    agent_health = check_health(args.agent_url, "agent")

    if args.expect_session_backend:
        backend_name = agent_health.get("session_backend")
        if backend_name != args.expect_session_backend:
            raise SmokeTestError(
                f"El agent usa session_backend={backend_name!r}, esperado {args.expect_session_backend!r}."
            )

    token = login(args.backend_url, args.username, args.password)
    profile = get_profile(args.backend_url, token)

    print_step("chat turno 1")
    first_chat = chat(args.agent_url, token, args.message_1)
    print(pretty_json(first_chat))

    session_id = str(first_chat["session_id"])

    print_step("chat turno 2")
    second_chat = chat(args.agent_url, token, args.message_2, session_id=session_id)
    print(pretty_json(second_chat))

    if second_chat["session_id"] != session_id:
        raise SmokeTestError(
            "El segundo turno devolvió un session_id distinto. "
            f"Esperado {session_id!r}, recibido {second_chat['session_id']!r}."
        )

    snapshot = SessionSnapshot(
        session_id=session_id,
        user_id=str(profile.get("id") or ""),
        user_role=normalize_role(profile),
        backend_url=args.backend_url,
        agent_url=args.agent_url,
    )
    save_session_snapshot(args.session_file, snapshot)

    print_step("resultado")
    print("Smoke test OK.")
    print(f"session_id guardado en: {args.session_file}")
    print("Para probar persistencia tras reiniciar el agente:")
    print(f"  python3 smoke_test_agent.py --resume --session-file {args.session_file}")
    return 0


def run_resume_session(args: argparse.Namespace) -> int:
    snapshot = load_session_snapshot(args.session_file)

    check_health(args.backend_url, "backend")
    agent_health = check_health(args.agent_url, "agent")

    if args.expect_session_backend:
        backend_name = agent_health.get("session_backend")
        if backend_name != args.expect_session_backend:
            raise SmokeTestError(
                f"El agent usa session_backend={backend_name!r}, esperado {args.expect_session_backend!r}."
            )

    token = login(args.backend_url, args.username, args.password)
    profile = get_profile(args.backend_url, token)

    if str(profile.get("id") or "") != snapshot.user_id:
        raise SmokeTestError(
            "El usuario autenticado no coincide con el de la sesión guardada. "
            f"Esperado {snapshot.user_id!r}, recibido {profile.get('id')!r}."
        )

    print_step("chat resume")
    resumed_chat = chat(
        args.agent_url,
        token,
        args.resume_message,
        session_id=snapshot.session_id,
    )
    print(pretty_json(resumed_chat))

    if resumed_chat["session_id"] != snapshot.session_id:
        raise SmokeTestError(
            "El turno reanudado devolvió un session_id distinto. "
            f"Esperado {snapshot.session_id!r}, recibido {resumed_chat['session_id']!r}."
        )

    print_step("resultado")
    print("Resume smoke test OK.")
    print("Si has reiniciado el agente entre medias y esto ha seguido funcionando, la persistencia está bien.")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Smoke test de backend + agent")
    parser.add_argument("--backend-url", default=DEFAULT_BACKEND_URL)
    parser.add_argument("--agent-url", default=DEFAULT_AGENT_URL)
    parser.add_argument("--username", default=DEFAULT_USERNAME)
    parser.add_argument("--password", default=DEFAULT_PASSWORD)
    parser.add_argument("--message-1", default=DEFAULT_MESSAGE_1)
    parser.add_argument("--message-2", default=DEFAULT_MESSAGE_2)
    parser.add_argument("--resume-message", default=DEFAULT_RESUME_MESSAGE)
    parser.add_argument(
        "--session-file",
        type=Path,
        default=Path(DEFAULT_SESSION_FILE),
    )
    parser.add_argument(
        "--expect-session-backend",
        choices=("memory", "firestore"),
        help="Valida el backend de sesión que reporta /health del agent.",
    )
    parser.add_argument(
        "--resume",
        action="store_true",
        help="Reutiliza el session_id guardado para probar persistencia tras reiniciar el agente.",
    )
    return parser


def main() -> int:
    args = build_parser().parse_args()
    try:
        if args.resume:
            return run_resume_session(args)
        return run_new_session(args)
    except SmokeTestError as exc:
        print(f"\n[ERROR]\n{exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
