from typing import Any, Optional

import httpx
from google.adk.tools import ToolContext

from agent.audit import log_permission_denied, log_tool_call
from agent.config import settings


_client = httpx.Client(
    base_url=settings.BACKEND_BASE_URL,
    timeout=settings.HTTP_TIMEOUT_SECONDS,
)


def _auth_headers(ctx: ToolContext) -> dict:
    jwt = ctx.state.get("jwt")
    if not jwt:
        raise RuntimeError(
            "No hay JWT en la sesión. El usuario debe autenticarse antes de usar el agente."
        )
    return {"Authorization": f"Bearer {jwt}"}


def _clean_params(params: Optional[dict]) -> Optional[dict]:
    if not params:
        return None
    return {k: v for k, v in params.items() if v is not None}


def _to_result(resp: httpx.Response) -> Any:
    if resp.status_code == 204 or not resp.content:
        return {"ok": True}
    try:
        return resp.json()
    except ValueError:
        return {"raw": resp.text}


def _error_payload(resp: httpx.Response) -> dict:
    detail: Any
    try:
        detail = resp.json()
    except ValueError:
        detail = resp.text
    return {"error": True, "status": resp.status_code, "detail": detail}


def _safe_request(method: str, path: str, ctx: ToolContext, **kwargs) -> Any:
    user_id: str = ctx.state.get("user_id", "unknown")
    user_role: str = ctx.state.get("user_role", "unknown")
    try:
        resp = _client.request(method, path, headers=_auth_headers(ctx), **kwargs)
    except httpx.RequestError as exc:
        log_tool_call(user_id, user_role, method, path, status_code=None, error=True)
        return {"error": True, "status": None, "detail": f"Fallo de red contra el backend: {exc}"}
    log_tool_call(user_id, user_role, method, path, status_code=resp.status_code, error=resp.is_error)
    if resp.status_code == 403:
        log_permission_denied(user_id, user_role, method, path)
    if resp.is_error:
        return _error_payload(resp)
    return _to_result(resp)


def api_get(path: str, ctx: ToolContext, params: Optional[dict] = None) -> Any:
    return _safe_request("GET", path, ctx, params=_clean_params(params))


def api_post(path: str, ctx: ToolContext, json: Optional[dict] = None) -> Any:
    return _safe_request("POST", path, ctx, json=json)


def api_put(path: str, ctx: ToolContext, json: Optional[dict] = None) -> Any:
    return _safe_request("PUT", path, ctx, json=json)


def api_delete(path: str, ctx: ToolContext) -> Any:
    return _safe_request("DELETE", path, ctx)
