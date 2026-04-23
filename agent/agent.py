from google.adk.agents import LlmAgent

from agent.config import settings
from agent.prompts import SYSTEM_INSTRUCTION
from agent.tools import academic, communication, profile, scheduling


TOOLS = [
    # Perfil
    profile.get_my_profile,
    profile.update_my_profile,
    profile.get_user_by_id,
    # Académico
    academic.list_subjects,
    academic.get_subject_detail,
    academic.list_students_in_subject,
    academic.get_my_grades,
    academic.get_my_grades_for_subject,
    academic.register_grade,
    academic.update_grade,
    academic.get_my_attendance,
    academic.get_my_attendance_metrics,
    academic.mark_attendance,
    academic.get_subject_attendance,
    # Calendario y tutorías
    scheduling.list_calendar_events,
    scheduling.get_event_detail,
    scheduling.create_calendar_event,
    scheduling.update_calendar_event,
    scheduling.delete_calendar_event,
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


root_agent = LlmAgent(
    name="campus_assistant",
    model=settings.MODEL,
    description=(
        "Asistente personal del campus virtual de EDEM. Adapta su comportamiento "
        "al rol del usuario (alumno, profesor o coordinador) y opera contra la API "
        "del campus para consultar y gestionar notas, asistencia, calendario, "
        "tutorías, correos y notificaciones."
    ),
    instruction=SYSTEM_INSTRUCTION,
    tools=TOOLS,
)
