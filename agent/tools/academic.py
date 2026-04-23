from typing import Optional

from google.adk.tools import ToolContext

from agent.tools.http_client import api_get, api_post, api_put


def list_subjects(tool_context: ToolContext) -> list:
    """Lista todas las asignaturas del sistema (id_asignatura, nombre)."""
    return api_get("/api/v1/subjects", tool_context)


def get_subject_detail(tool_context: ToolContext, subject_id: str) -> dict:
    """Obtiene el detalle de una asignatura concreta por su id_asignatura."""
    return api_get(f"/api/v1/subjects/{subject_id}", tool_context)


def list_students_in_subject(tool_context: ToolContext, subject_id: str) -> list:
    """Lista los alumnos matriculados en una asignatura.

    Solo útil para profesores o coordinadores que necesiten ver la clase.
    """
    return api_get(f"/api/v1/subjects/{subject_id}/students", tool_context)


# ---------- Notas ----------

def get_my_grades(tool_context: ToolContext) -> list:
    """Devuelve todas las notas del alumno autenticado.

    Solo funciona si el rol del usuario es 'alumno'. Cada nota incluye
    id_tarea, nombre_tarea, id_asignatura y nota (0-10).
    """
    return api_get("/api/v1/grades/me", tool_context)


def get_my_grades_for_subject(tool_context: ToolContext, subject_id: str) -> list:
    """Devuelve las notas del alumno autenticado filtradas por asignatura.

    Solo funciona si el rol del usuario es 'alumno'.
    """
    return api_get(f"/api/v1/grades/me/subjects/{subject_id}", tool_context)


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
    y la asignatura.
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
    id_asignatura: str,
    fecha: str,
    presente: bool,
) -> dict:
    """Registra o actualiza la asistencia de un alumno en una asignatura para una fecha.

    El campo fecha debe ser ISO-8601 (YYYY-MM-DD). Solo usar si el rol es 'profesor'.
    Si ya existe un registro para (alumno, asignatura, fecha) se actualizará.
    """
    return api_post(
        "/api/v1/attendance",
        tool_context,
        json={
            "id_alumno": id_alumno,
            "id_asignatura": id_asignatura,
            "fecha": fecha,
            "presente": presente,
        },
    )


def get_subject_attendance(tool_context: ToolContext, subject_id: str) -> list:
    """Devuelve todos los registros de asistencia de una asignatura concreta.

    Pensado para profesores o coordinadores que quieren revisar la clase entera.
    """
    return api_get(f"/api/v1/attendance/subjects/{subject_id}", tool_context)
