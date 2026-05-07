from typing import Optional

from google.adk.tools import ToolContext

from agent.tools.http_client import api_get, api_post, api_put


# ---------- Bloques y sesiones ----------

def list_blocks(tool_context: ToolContext) -> list:
    """Lista todos los bloques disponibles en el sistema."""
    return api_get("/api/v1/blocks", tool_context)


def list_my_blocks(tool_context: ToolContext) -> list:
    """Lista los bloques asociados al usuario autenticado."""
    return api_get("/api/v1/blocks/me", tool_context)


def list_sessions(tool_context: ToolContext) -> list:
    """Lista sesiones del sistema, opcionalmente filtrables en conversaciones posteriores."""
    return api_get("/api/v1/sessions", tool_context)


def get_session_detail(tool_context: ToolContext, session_id: str) -> dict:
    """Obtiene el detalle de una sesión concreta por su id_sesion."""
    return api_get(f"/api/v1/sessions/{session_id}", tool_context)


def list_students_in_session(tool_context: ToolContext, session_id: str) -> list:
    """Lista los alumnos matriculados en una sesión/asignatura.

    Solo útil para profesores o coordinadores que necesiten ver la clase.
    """
    return api_get(f"/api/v1/sessions/{session_id}/students", tool_context)


# ---------- Notas ----------

def get_my_grades(tool_context: ToolContext) -> list:
    """Devuelve todas las notas del alumno autenticado.

    Solo funciona si el rol del usuario es 'alumno'. Cada nota incluye
    id_tarea, nombre_tarea, id_bloque y nota (0-10).
    """
    return api_get("/api/v1/grades/me", tool_context)


def get_my_grade_summary(tool_context: ToolContext) -> dict:
    """Devuelve un resumen calculado de las notas del alumno autenticado.

    Usa esta tool cuando el usuario pregunte por media, promedio, cómo va de
    notas o resumen académico. Calcula la media simple y la media ponderada con
    los mismos pesos que usa el dashboard del frontend.
    """
    grades = api_get("/api/v1/grades/me", tool_context)
    if isinstance(grades, dict) and grades.get("error"):
        return grades
    if not isinstance(grades, list):
        return {"error": True, "detail": "Respuesta inesperada del backend al consultar notas."}

    graded = [grade for grade in grades if grade.get("nota") is not None]
    if not graded:
        return {
            "total_calificaciones": 0,
            "media_simple": None,
            "media_ponderada": None,
            "por_categoria": {},
            "notas": grades,
        }

    category_weights = {
        "entregables": 20.0,
        "data_projects": 30.0,
        "actitud": 10.0,
        "tfm": 40.0,
    }
    by_category: dict[str, list[float]] = {}
    for grade in graded:
        category = grade.get("categoria") or "sin_categoria"
        by_category.setdefault(category, []).append(float(grade["nota"]))

    simple_average = sum(float(grade["nota"]) for grade in graded) / len(graded)
    weighted_total = 0.0
    weight_total = 0.0
    category_summary = {}
    for category, values in by_category.items():
        average = sum(values) / len(values)
        weight = category_weights.get(category, 0.0)
        category_summary[category] = {
            "media": round(average, 2),
            "peso": weight,
            "num_calificaciones": len(values),
        }
        if weight > 0:
            weighted_total += average * weight
            weight_total += weight

    return {
        "total_calificaciones": len(graded),
        "media_simple": round(simple_average, 2),
        "media_ponderada": round(weighted_total / weight_total, 2) if weight_total else None,
        "por_categoria": category_summary,
        "notas": grades,
    }


def get_my_grades_for_block(tool_context: ToolContext, block_id: str) -> list:
    """Devuelve las notas del alumno autenticado filtradas por bloque.

    Solo funciona si el rol del usuario es 'alumno'.
    """
    return api_get(f"/api/v1/grades/me/blocks/{block_id}", tool_context)


def register_grade(
    tool_context: ToolContext,
    id_alumno: str,
    id_tarea: int,
    nota: float,
) -> dict:
    """Registra una nueva nota para un alumno en una tarea concreta.

    Solo usar si el usuario es 'profesor'. Si ya existe una nota para
    (id_alumno, id_tarea) el backend devolverá un error y debes usar update_grade.
    """
    return api_post(
        "/api/v1/grades",
        tool_context,
        json={"id_alumno": id_alumno, "id_tarea": id_tarea, "nota": nota},
    )


def update_grade(
    tool_context: ToolContext,
    id_tarea: int,
    id_alumno: str,
    nota: float,
) -> dict:
    """Actualiza una nota ya existente de un alumno para una tarea concreta.

    Solo usar si el usuario es 'profesor'. Confirma el cambio con el usuario antes
    de llamar a esta tool.
    """
    return api_put(
        f"/api/v1/grades/{id_tarea}",
        tool_context,
        json={"id_alumno": id_alumno, "nota": nota},
    )


# ---------- Asistencia ----------

def get_my_attendance(tool_context: ToolContext) -> list:
    """Devuelve el historial completo de asistencia del alumno autenticado.

    Solo funciona si el rol es 'alumno'. Cada registro incluye fecha, presente (bool)
    y la sesión/asignatura.
    """
    return api_get("/api/v1/attendance/me", tool_context)


def get_my_attendance_metrics(tool_context: ToolContext) -> dict:
    """Devuelve métricas agregadas de asistencia del alumno autenticado.

    Solo funciona si el rol es 'alumno'. Incluye total_clases, clases_asistidas y
    porcentaje_asistencia.
    """
    return api_get("/api/v1/attendance/me/metrics", tool_context)


def mark_attendance(
    tool_context: ToolContext,
    id_alumno: str,
    id_sesion: str,
    fecha: str,
    presente: bool,
) -> dict:
    """Registra o actualiza la asistencia de un alumno en una sesión para una fecha.

    El campo fecha debe ser ISO-8601 (YYYY-MM-DD). Solo usar si el rol es 'profesor'.
    Si ya existe un registro para (alumno, sesión, fecha) se actualizará.
    """
    return api_post(
        "/api/v1/attendance",
        tool_context,
        json={
            "id_alumno": id_alumno,
            "id_sesion": id_sesion,
            "fecha": fecha,
            "presente": presente,
        },
    )


def get_session_attendance(tool_context: ToolContext, session_id: str) -> list:
    """Devuelve todos los registros de asistencia de una sesión/asignatura concreta.

    Pensado para profesores o coordinadores que quieren revisar la clase entera.
    """
    return api_get(f"/api/v1/attendance/sessions/{session_id}", tool_context)
