from typing import Optional

from google.adk.tools import ToolContext

from agent.tools.http_client import api_get, api_put


def get_my_profile(tool_context: ToolContext) -> dict:
    """Devuelve el perfil del usuario autenticado (id, nombre, apellido, correo, rol, url_foto).

    Útil al inicio de la conversación para confirmar quién es el usuario y su rol
    ('alumno', 'profesor' o un rol del staff como 'coordinador').
    """
    return api_get("/api/v1/users/me", tool_context)


def update_my_profile(
    tool_context: ToolContext,
    nombre: Optional[str] = None,
    apellido: Optional[str] = None,
    correo: Optional[str] = None,
) -> dict:
    """Actualiza datos básicos del perfil del usuario autenticado.

    Solo incluye en la llamada los campos que el usuario quiere cambiar.
    Antes de llamar a esta tool, confirma el cambio con el usuario.
    """
    payload = {k: v for k, v in {"nombre": nombre, "apellido": apellido, "correo": correo}.items() if v is not None}
    if not payload:
        return {"error": True, "detail": "No hay campos para actualizar."}
    return api_put("/api/v1/users/me", tool_context, json=payload)


def get_user_by_id(tool_context: ToolContext, user_id: str) -> dict:
    """Busca el perfil público de cualquier usuario del sistema por su ID.

    Útil, por ejemplo, para mostrar el nombre del remitente de un correo o del
    profesor asociado a una tutoría a partir de su id.
    """
    return api_get(f"/api/v1/users/{user_id}", tool_context)
