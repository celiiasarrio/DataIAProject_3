from datetime import datetime, timedelta
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from google.adk.tools import ToolContext

from agent.config import settings


WEEKDAYS_ES = {
    0: "lunes",
    1: "martes",
    2: "miercoles",
    3: "jueves",
    4: "viernes",
    5: "sabado",
    6: "domingo",
}


def _resolve_timezone() -> tuple[ZoneInfo, str]:
    timezone_name = settings.AGENT_TIMEZONE or "Europe/Madrid"
    try:
        return ZoneInfo(timezone_name), timezone_name
    except ZoneInfoNotFoundError:
        fallback = "UTC"
        return ZoneInfo(fallback), fallback


def get_current_datetime(tool_context: ToolContext) -> dict:
    """Devuelve la fecha y hora actuales del agente para resolver referencias relativas.

    Úsala antes de responder preguntas como "hoy", "mañana", "esta semana",
    "la próxima clase" o "qué toca el jueves" cuando necesites saber la fecha
    actual real del sistema.
    """
    del tool_context  # Tool puramente local.

    tz, timezone_name = _resolve_timezone()
    now = datetime.now(tz)
    tomorrow = now + timedelta(days=1)
    yesterday = now - timedelta(days=1)

    return {
        "datetime_iso": now.isoformat(),
        "date_iso": now.date().isoformat(),
        "time_iso": now.time().replace(microsecond=0).isoformat(),
        "timezone": timezone_name,
        "weekday_number": now.weekday(),
        "weekday_name_es": WEEKDAYS_ES[now.weekday()],
        "today_date_iso": now.date().isoformat(),
        "tomorrow_date_iso": tomorrow.date().isoformat(),
        "yesterday_date_iso": yesterday.date().isoformat(),
    }
