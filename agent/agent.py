from google.adk.agents import LlmAgent

from agent.config import settings
from agent.prompts import render_instruction
from agent.tools import academic, communication, profile, scheduling


TOOLS = [
    # Perfil
    profile.get_my_profile,
    profile.update_my_profile,
    profile.get_user_by_id,
    # Bloques y sesiones
    academic.list_my_blocks,
    academic.list_blocks,
    academic.list_sessions,
    academic.get_session_detail,
    academic.list_students_in_session,
    # Notas
    academic.get_my_grades,
    academic.get_my_grades_for_block,
    academic.register_grade,
    academic.update_grade,
    # Asistencia
    academic.get_my_attendance,
    academic.get_my_attendance_metrics,
    academic.mark_attendance,
    academic.get_session_attendance,
    # Calendario
    scheduling.list_calendar_events,
    scheduling.get_event_detail,
    scheduling.create_calendar_event,
    scheduling.update_calendar_event,
    scheduling.delete_calendar_event,
    # Tutorías y reservas
    scheduling.list_tutoring_slots,
    scheduling.create_tutoring_slot,
    scheduling.list_my_reservations,
    scheduling.request_tutoring,
    scheduling.update_reservation_status,
    # Notificaciones y correos
    communication.list_notifications,
    communication.mark_notification_read,
    communication.get_notification_settings,
    communication.list_emails,
    communication.read_email,
    communication.send_email,
]


def create_root_agent(user_role: str, user_name: str, user_id: str) -> LlmAgent:
    return LlmAgent(
        name="campus_assistant",
        model=settings.MODEL,
        description=(
            "Asistente personal del campus virtual de EDEM. Adapta su comportamiento "
            "al rol del usuario (alumno, profesor o personal) y opera contra la API "
            "del campus para consultar y gestionar notas, asistencia, calendario, "
            "tutorías, correos y notificaciones."
        ),
        instruction=render_instruction(user_role=user_role, user_name=user_name, user_id=user_id),
        tools=TOOLS,
    )
