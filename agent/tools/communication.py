from google.adk.tools import ToolContext

from agent.tools.http_client import api_get, api_post, api_put


# ---------- Notificaciones ----------

def list_notifications(tool_context: ToolContext) -> list:
    """Lista las notificaciones del usuario autenticado, más recientes primero."""
    return api_get("/api/v1/notifications", tool_context)


def mark_notification_read(tool_context: ToolContext, notification_id: str) -> dict:
    """Marca una notificación concreta como leída."""
    return api_put(f"/api/v1/notifications/{notification_id}/read", tool_context)


def get_notification_settings(tool_context: ToolContext) -> dict:
    """Devuelve las preferencias de notificaciones del usuario (calendario, notas, asistencia)."""
    return api_get("/api/v1/notifications/settings", tool_context)


# ---------- Correos internos ----------

def list_emails(tool_context: ToolContext, folder: str = "inbox") -> list:
    """Lista los correos internos del usuario.

    folder: 'inbox' (recibidos) o 'sent' (enviados). Por defecto 'inbox'.
    """
    return api_get("/api/v1/emails", tool_context, params={"folder": folder})


def read_email(tool_context: ToolContext, email_id: str) -> dict:
    """Lee un correo concreto.

    Si el usuario es el destinatario, el backend lo marca automáticamente como leído.
    """
    return api_get(f"/api/v1/emails/{email_id}", tool_context)


def send_email(
    tool_context: ToolContext,
    id_destinatario: str,
    asunto: str,
    cuerpo: str,
) -> dict:
    """Envía un correo interno a otro usuario del sistema.

    Antes de llamar, confirma al usuario el destinatario, asunto y cuerpo.
    """
    return api_post(
        "/api/v1/emails",
        tool_context,
        json={"id_destinatario": id_destinatario, "asunto": asunto, "cuerpo": cuerpo},
    )
