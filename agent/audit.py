"""
Audit logging for the campus agent.
Emits structured JSON records for tool calls, permission denials,
security events, and chat requests so that operators can reconstruct
who did what and when.
"""
import json
import logging
from datetime import datetime, timezone
from typing import Optional


_audit_logger = logging.getLogger("agent.audit")

if not _audit_logger.handlers:
    _handler = logging.StreamHandler()
    _handler.setFormatter(
        logging.Formatter("%(asctime)s [AUDIT] %(message)s", datefmt="%Y-%m-%dT%H:%M:%SZ")
    )
    _audit_logger.addHandler(_handler)
    _audit_logger.setLevel(logging.INFO)
    _audit_logger.propagate = False


def _ts() -> str:
    return datetime.now(timezone.utc).isoformat()


def log_chat_request(
    user_id: str,
    user_role: str,
    session_id: str,
    message_length: int,
) -> None:
    _audit_logger.info(
        json.dumps(
            {
                "event": "chat_request",
                "timestamp": _ts(),
                "user_id": user_id,
                "user_role": user_role,
                "session_id": session_id,
                "message_length": message_length,
            },
            ensure_ascii=False,
        )
    )


def log_tool_call(
    user_id: str,
    user_role: str,
    method: str,
    path: str,
    status_code: Optional[int] = None,
    error: bool = False,
) -> None:
    _audit_logger.info(
        json.dumps(
            {
                "event": "tool_call",
                "timestamp": _ts(),
                "user_id": user_id,
                "user_role": user_role,
                "method": method,
                "path": path,
                "status_code": status_code,
                "error": error,
            },
            ensure_ascii=False,
        )
    )


def log_permission_denied(
    user_id: str,
    user_role: str,
    method: str,
    path: str,
) -> None:
    _audit_logger.warning(
        json.dumps(
            {
                "event": "permission_denied",
                "timestamp": _ts(),
                "user_id": user_id,
                "user_role": user_role,
                "method": method,
                "path": path,
            },
            ensure_ascii=False,
        )
    )


def log_security_event(
    user_id: str,
    event_type: str,
    detail: str,
) -> None:
    _audit_logger.warning(
        json.dumps(
            {
                "event": "security",
                "event_type": event_type,
                "timestamp": _ts(),
                "user_id": user_id,
                "detail": detail,
            },
            ensure_ascii=False,
        )
    )
