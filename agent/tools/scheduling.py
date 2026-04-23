from typing import Optional

from google.adk.tools import ToolContext

from agent.tools.http_client import api_delete, api_get, api_post, api_put


# ---------- Calendario ----------

def list_calendar_events(tool_context: ToolContext, tipo: Optional[str] = None) -> list:
    """Lista eventos del calendario (clases, exámenes, entregas).

    tipo: filtrar por 'class', 'exam' o 'delivery'. None = todos.
    """
    return api_get("/api/v1/calendar/events", tool_context, params={"tipo": tipo})


def get_event_detail(tool_context: ToolContext, event_id: str) -> dict:
    """Obtiene el detalle completo de un evento concreto por su id."""
    return api_get(f"/api/v1/calendar/events/{event_id}", tool_context)


def create_calendar_event(
    tool_context: ToolContext,
    tipo: str,
    titulo: str,
    id_sesion: str,
    fecha_inicio: str,
    fecha_fin: str,
    aula: Optional[str] = None,
    id_profesor: Optional[str] = None,
    descripcion: Optional[str] = None,
) -> dict:
    """Crea un nuevo evento en el calendario.

    tipo debe ser 'class', 'exam' o 'delivery'. fecha_inicio y fecha_fin en
    formato ISO-8601 con hora (YYYY-MM-DDTHH:MM:SS). id_sesion es el ID de la
    sesión/asignatura a la que pertenece el evento. Solo usar para profesores o
    coordinadores, y confirmar los datos con el usuario antes de llamar.
    """
    payload = {
        "tipo": tipo,
        "titulo": titulo,
        "id_sesion": id_sesion,
        "fecha_inicio": fecha_inicio,
        "fecha_fin": fecha_fin,
        "aula": aula,
        "id_profesor": id_profesor,
        "descripcion": descripcion,
    }
    return api_post(
        "/api/v1/calendar/events",
        tool_context,
        json={k: v for k, v in payload.items() if v is not None},
    )


def update_calendar_event(
    tool_context: ToolContext,
    event_id: str,
    tipo: Optional[str] = None,
    titulo: Optional[str] = None,
    id_sesion: Optional[str] = None,
    aula: Optional[str] = None,
    id_profesor: Optional[str] = None,
    fecha_inicio: Optional[str] = None,
    fecha_fin: Optional[str] = None,
    descripcion: Optional[str] = None,
) -> dict:
    """Actualiza los campos indicados de un evento del calendario.

    Solo pasa los campos que se quieren cambiar. Confirma el cambio con el usuario
    antes de llamar a esta tool.
    """
    payload = {
        "tipo": tipo,
        "titulo": titulo,
        "id_sesion": id_sesion,
        "aula": aula,
        "id_profesor": id_profesor,
        "fecha_inicio": fecha_inicio,
        "fecha_fin": fecha_fin,
        "descripcion": descripcion,
    }
    payload = {k: v for k, v in payload.items() if v is not None}
    if not payload:
        return {"error": True, "detail": "No hay campos para actualizar."}
    return api_put(f"/api/v1/calendar/events/{event_id}", tool_context, json=payload)


def delete_calendar_event(tool_context: ToolContext, event_id: str) -> dict:
    """Elimina un evento del calendario.

    Operación destructiva: antes de llamar, confirma con el usuario.
    """
    return api_delete(f"/api/v1/calendar/events/{event_id}", tool_context)


# ---------- Tutorías y reservas ----------

def list_tutoring_slots(tool_context: ToolContext, teacher_id: Optional[str] = None) -> list:
    """Lista las franjas de tutoría disponibles, opcionalmente filtradas por profesor."""
    return api_get("/api/v1/tutorings/slots", tool_context, params={"teacher_id": teacher_id})


def create_tutoring_slot(
    tool_context: ToolContext,
    id_profesor: str,
    dia_semana: int,
    hora_inicio: str,
    hora_fin: str,
    ubicacion: str,
    id_sesion: Optional[str] = None,
    disponible: bool = True,
) -> dict:
    """Crea una nueva franja semanal de tutoría para un profesor.

    dia_semana es 0 (lunes) a 6 (domingo). hora_inicio y hora_fin en formato HH:MM.
    id_sesion es la sesión/asignatura asociada (opcional). Solo usar si el usuario
    es 'profesor' y está creando sus propias franjas.
    """
    return api_post(
        "/api/v1/tutorings/slots",
        tool_context,
        json={
            "id_profesor": id_profesor,
            "id_sesion": id_sesion,
            "dia_semana": dia_semana,
            "hora_inicio": hora_inicio,
            "hora_fin": hora_fin,
            "ubicacion": ubicacion,
            "disponible": disponible,
        },
    )


def list_my_reservations(tool_context: ToolContext) -> list:
    """Lista las reservas del usuario autenticado.

    Para alumnos: las tutorías que han solicitado.
    Para profesores: las tutorías que les han solicitado.
    """
    return api_get("/api/v1/reservations", tool_context)


def request_tutoring(
    tool_context: ToolContext,
    id_profesor: str,
    id_franja: str,
    fecha: str,
    notas: Optional[str] = None,
) -> dict:
    """Solicita una reserva de tutoría. Solo alumnos pueden usar esta tool.

    fecha en formato ISO-8601 (YYYY-MM-DD). La reserva se crea en estado 'pending'
    a la espera de que el profesor la confirme.
    """
    return api_post(
        "/api/v1/reservations",
        tool_context,
        json={
            "id_profesor": id_profesor,
            "id_franja": id_franja,
            "fecha": fecha,
            "notas": notas,
        },
    )


def update_reservation_status(
    tool_context: ToolContext,
    reservation_id: str,
    estado: str,
) -> dict:
    """Cambia el estado de una reserva. Solo el profesor implicado puede hacerlo.

    estado: 'confirmed', 'rejected' o 'completed'. Confirma el cambio con el
    usuario antes de llamar.
    """
    return api_put(
        f"/api/v1/reservations/{reservation_id}",
        tool_context,
        json={"estado": estado},
    )
