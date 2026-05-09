import base64
from datetime import date, datetime, time, timedelta
import hashlib
import hmac
import json
import os
import re
import shutil
import time as time_module
import uuid
from pathlib import Path
from typing import List, Optional
from urllib.parse import urlparse

try:
    import bcrypt as bcrypt_lib
except ModuleNotFoundError:  # pragma: no cover - fallback for thin local envs
    bcrypt_lib = None
from fastapi import Depends, FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import FileResponse, RedirectResponse
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi.staticfiles import StaticFiles
from google.api_core.exceptions import NotFound
from google.cloud import storage
try:
    from jose import JWTError, jwt
except ModuleNotFoundError:  # pragma: no cover - fallback for thin local envs
    class JWTError(Exception):
        pass

    jwt = None
from pydantic import BaseModel, ConfigDict
from sqlalchemy import and_, create_engine, or_
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import NullPool

from config import settings
from models import (
    Alumno,
    Asistencia,
    Base,
    Bloque,
    ConfiguracionNotificacion,
    Contenido,
    Correo,
    Evento,
    FranjaTutoria,
    Grupo,
    Notificacion,
    Coordinador,
    PerfilDetalle,
    PerfilDocumento,
    Profesor,
    RelAlumnoTarea,
    RelAlumnosGrupos,
    RelBloquesGrupos,
    RelCoordinadoresGrupos,
    RelProfesoresBloques,
    Reserva,
    Sesion,
    SolicitudTutoria,
    Tarea,
    Ubicacion,
    UserSession,
)


def build_engine():
    database_url = settings.database_url
    kwargs = {
        "pool_pre_ping": True,
        "echo": False if settings.ENVIRONMENT == "production" else True,
    }
    if database_url.startswith("sqlite"):
        kwargs["connect_args"] = {"check_same_thread": False}
    elif settings.ENVIRONMENT == "production":
        kwargs["poolclass"] = NullPool
    return create_engine(database_url, **kwargs)


engine = build_engine()
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

app = FastAPI(
    title="API EDEM Student Hub",
    description="API para perfiles, bloques, sesiones, notas, asistencia y utilidades del hub.",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(GZipMiddleware, minimum_size=1024)

UPLOAD_ROOT_RAW = os.getenv("UPLOAD_ROOT", "/app/uploads")
PUBLIC_UPLOAD_PREFIX = os.getenv("PUBLIC_UPLOAD_PREFIX", "/uploads").rstrip("/")
GCS_UPLOAD_BUCKET: Optional[str] = None
GCS_UPLOAD_PREFIX = ""
UPLOAD_ROOT: Optional[Path] = None

if UPLOAD_ROOT_RAW.startswith("gs://"):
    parsed_upload_root = urlparse(UPLOAD_ROOT_RAW)
    GCS_UPLOAD_BUCKET = parsed_upload_root.netloc
    GCS_UPLOAD_PREFIX = parsed_upload_root.path.strip("/")
    if not GCS_UPLOAD_BUCKET:
        raise ValueError("UPLOAD_ROOT gs:// debe incluir un bucket")
else:
    UPLOAD_ROOT = Path(UPLOAD_ROOT_RAW)
    UPLOAD_ROOT.mkdir(parents=True, exist_ok=True)
    app.mount(PUBLIC_UPLOAD_PREFIX, StaticFiles(directory=str(UPLOAD_ROOT)), name="uploads")


def gcs_client() -> storage.Client:
    return storage.Client()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/token")


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class Token(BaseModel):
    access_token: str
    token_type: str


class ProfileUpdate(BaseModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    correo: Optional[str] = None


class UserProfileOut(BaseModel):
    id: str
    nombre: str
    apellido: str
    correo: str
    rol: str
    url_foto: Optional[str] = None


class ProfilePersonalUpdate(BaseModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    telefono: Optional[str] = None
    ciudad: Optional[str] = None
    idioma_preferido: Optional[str] = None
    contacto_emergencia: Optional[str] = None


class ProfileContactUpdate(BaseModel):
    correo_personal: Optional[str] = None
    telefono: Optional[str] = None
    linkedin: Optional[str] = None
    github: Optional[str] = None
    portfolio: Optional[str] = None
    preferencia_contacto: Optional[str] = None


class ProfileProfessionalUpdate(BaseModel):
    area_interes: Optional[str] = None
    stack_tecnologico: Optional[str] = None
    experiencia_actual: Optional[str] = None
    disponibilidad: Optional[str] = None
    preferencia_jornada: Optional[str] = None
    linkedin: Optional[str] = None
    github: Optional[str] = None
    portfolio: Optional[str] = None


class ProfilePreferencesUpdate(BaseModel):
    idioma_app: Optional[str] = None
    notificaciones_email: Optional[bool] = None
    notificaciones_push: Optional[bool] = None
    visibilidad_profesional: Optional[bool] = None
    permitir_cv_empleabilidad: Optional[bool] = None
    permitir_links_profesores: Optional[bool] = None
    tema: Optional[str] = None


class PasswordChangeIn(BaseModel):
    current_password: str
    new_password: str


class ProfileDocumentOut(BaseModel):
    id: str
    nombre: str
    tipo: str
    url: str
    content_type: str
    estado: str
    fecha_subida: datetime


class ProfileCvOut(BaseModel):
    nombre: Optional[str] = None
    url: Optional[str] = None
    fecha_subida: Optional[datetime] = None


class ProfileFullOut(BaseModel):
    id: str
    nombre: str
    apellido: str
    correo: str
    rol: str
    url_foto: Optional[str] = None
    estado: str
    programa_area: Optional[str] = None
    grupo: Optional[str] = None
    curso_academico: Optional[str] = None
    promocion: Optional[str] = None
    campus: Optional[str] = None
    modalidad: Optional[str] = None
    coordinador_asignado: Optional[str] = None
    tutor_academico: Optional[str] = None
    fecha_inicio: Optional[str] = None
    fecha_fin_estimada: Optional[str] = None
    departamento_area: Optional[str] = None
    asignaturas: List[str] = []
    especialidad: Optional[str] = None
    horario_tutorias: Optional[str] = None
    disponibilidad_contacto: Optional[str] = None
    programas_coordina: List[str] = []
    grupos_asignados: List[str] = []
    area_coordinacion: Optional[str] = None
    horario_atencion: Optional[str] = None
    permisos_administrativos: List[str] = []
    telefono: Optional[str] = None
    ciudad: Optional[str] = None
    idioma_preferido: Optional[str] = None
    contacto_emergencia: Optional[str] = None
    correo_personal: Optional[str] = None
    linkedin: Optional[str] = None
    github: Optional[str] = None
    portfolio: Optional[str] = None
    preferencia_contacto: Optional[str] = None
    area_interes: Optional[str] = None
    stack_tecnologico: Optional[str] = None
    experiencia_actual: Optional[str] = None
    disponibilidad: Optional[str] = None
    preferencia_jornada: Optional[str] = None
    cv: ProfileCvOut
    documentos: List[ProfileDocumentOut]
    idioma_app: str
    notificaciones_email: bool
    notificaciones_push: bool
    visibilidad_profesional: bool
    permitir_cv_empleabilidad: bool
    permitir_links_profesores: bool
    tema: str
    ultimo_acceso: Optional[datetime] = None


class AlumnoOut(ORMModel):
    id_alumno: str
    nombre: str
    apellido: str
    correo: str


class BloqueCreate(BaseModel):
    id_bloque: Optional[str] = None
    nombre: str


class BloqueOut(ORMModel):
    id_bloque: str
    nombre: str


class ProfesorListOut(ORMModel):
    id_profesor: str
    nombre: str
    apellido: str
    correo: str


class SesionCreate(BaseModel):
    id_sesion: Optional[str] = None
    id_bloque: Optional[str] = None
    nombre: str
    fecha: Optional[date] = None
    hora_inicio: Optional[time] = None
    hora_fin: Optional[time] = None
    aula: Optional[str] = None
    edificio: Optional[str] = None
    planta: Optional[str] = None


class SesionUpdate(BaseModel):
    id_bloque: Optional[str] = None
    nombre: Optional[str] = None
    fecha: Optional[date] = None
    hora_inicio: Optional[time] = None
    hora_fin: Optional[time] = None
    aula: Optional[str] = None
    edificio: Optional[str] = None
    planta: Optional[str] = None


class SesionOut(ORMModel):
    id_sesion: str
    id_bloque: str
    nombre: str
    fecha: Optional[date] = None
    hora_inicio: Optional[time] = None
    hora_fin: Optional[time] = None
    aula: Optional[str] = None
    edificio: Optional[str] = None
    planta: Optional[str] = None


class EventBase(BaseModel):
    tipo: str
    titulo: str
    id_bloque: Optional[str] = None
    id_sesion: Optional[str] = None
    aula: Optional[str] = None
    id_profesor: Optional[str] = None
    fecha_inicio: datetime
    fecha_fin: datetime
    descripcion: Optional[str] = None


class EventCreate(EventBase):
    pass


class EventUpdate(BaseModel):
    tipo: Optional[str] = None
    titulo: Optional[str] = None
    id_bloque: Optional[str] = None
    id_sesion: Optional[str] = None
    aula: Optional[str] = None
    id_profesor: Optional[str] = None
    fecha_inicio: Optional[datetime] = None
    fecha_fin: Optional[datetime] = None
    descripcion: Optional[str] = None


class EventOut(ORMModel):
    id: str
    tipo: str
    titulo: str
    id_bloque: Optional[str] = None
    bloque_nombre: Optional[str] = None
    id_sesion: Optional[str] = None
    aula: Optional[str] = None
    edificio: Optional[str] = None
    planta: Optional[str] = None
    id_profesor: Optional[str] = None
    profesor_nombre: Optional[str] = None
    fecha_inicio: datetime
    fecha_fin: datetime
    descripcion: Optional[str] = None


class GradeCreate(BaseModel):
    id_alumno: str
    id_tarea: int
    nota: float


class GradeUpdate(BaseModel):
    id_alumno: str
    nota: float


class GradeOut(BaseModel):
    id_tarea: int
    nombre_tarea: str
    id_bloque: str
    nota: Optional[float] = None
    categoria: str
    peso: float


class TaskOut(ORMModel):
    id_tarea: int
    id_bloque: str
    nombre: str
    descripcion: Optional[str] = None
    fecha: Optional[date] = None


class GradeRosterRow(BaseModel):
    id_alumno: str
    nombre: str
    apellido: str
    id_tarea: int
    nombre_tarea: str
    id_bloque: str
    nota: Optional[float] = None


GRADE_CATEGORY_WEIGHTS = {
    "entregables": 20.0,
    "data_projects": 30.0,
    "actitud": 10.0,
    "tfm": 40.0,
}


def clean_grade_task_name(name: str) -> str:
    cleaned = re.sub(r"^\s*deadline\s+", "", name, flags=re.IGNORECASE)
    cleaned = re.sub(r"^\s*entrega\s+", "", cleaned, flags=re.IGNORECASE)
    return " ".join(cleaned.split())


def get_grade_category(task: Tarea) -> str:
    normalized = task.nombre.lower()
    if "tfm" in normalized:
        return "tfm"
    if task.id_tarea in {7, 13, 18} or "dp1" in normalized or "dp2" in normalized or "dp3" in normalized:
        return "data_projects"
    return "entregables"


def build_grade_out(task: Tarea, nota: Optional[float]) -> GradeOut:
    category = get_grade_category(task)
    return GradeOut(
        id_tarea=task.id_tarea,
        nombre_tarea=clean_grade_task_name(task.nombre),
        id_bloque=task.id_bloque,
        nota=nota,
        categoria=category,
        peso=GRADE_CATEGORY_WEIGHTS[category],
    )


def attitude_grade_for_student(student_id: str) -> GradeOut:
    seed = sum(ord(char) for char in student_id)
    nota = round(7.4 + ((seed % 9) * 0.2), 2)
    return GradeOut(
        id_tarea=-1,
        nombre_tarea="Actitud y valores",
        id_bloque="ACTITUD",
        nota=min(nota, 10.0),
        categoria="actitud",
        peso=GRADE_CATEGORY_WEIGHTS["actitud"],
    )


def is_mandatory_attendance_session(session: Sesion) -> bool:
    if not session.fecha:
        return False
    normalized = session.nombre.lower()
    excluded_fragments = [
        "tfm",
        "visita",
        "empleabilidad",
        "experiencia internacional",
        "foto orla",
    ]
    return not any(fragment in normalized for fragment in excluded_fragments)


def mandatory_attendance_sessions(db: Session, until: Optional[date] = None) -> List[Sesion]:
    query = db.query(Sesion).filter(Sesion.fecha.isnot(None))
    if until:
        query = query.filter(Sesion.fecha < until)
    return [
        session
        for session in query.order_by(Sesion.fecha, Sesion.hora_inicio, Sesion.id_sesion).all()
        if is_mandatory_attendance_session(session)
    ]


def build_attendance_metrics(db: Session, user_id: str) -> "AttendanceMetricsOut":
    sessions = mandatory_attendance_sessions(db, date.today())
    session_ids = [session.id_sesion for session in sessions]
    records = {
        record.id_sesion: record
        for record in db.query(Asistencia)
        .filter(Asistencia.id_alumno == user_id, Asistencia.id_sesion.in_(session_ids))
        .all()
    }
    total = len(sessions)
    attended = sum(1 for session_id in session_ids if records.get(session_id) and records[session_id].presente)
    absences = total - attended
    percentage = round((attended / total) * 100, 2) if total else 0.0
    allowed_80 = int(total * 0.2)
    remaining_80 = max(allowed_80 - absences, 0)
    if percentage >= 80:
        grade = 10.0
        status = "ok"
    elif percentage >= 50:
        grade = 5.0
        status = "warning"
    else:
        grade = 0.0
        status = "critical"

    aviso = None
    if total:
        if percentage < 50:
            aviso = "Has bajado del 50% de asistencia obligatoria."
        elif percentage < 80:
            aviso = "Has bajado del 80% de asistencia obligatoria."
        elif remaining_80 <= 2:
            aviso = f"Estas rozando el limite del 80%: te quedan {remaining_80} faltas."

    return AttendanceMetricsOut(
        total_clases=total,
        clases_asistidas=attended,
        porcentaje_asistencia=percentage,
        faltas=absences,
        faltas_permitidas_80=allowed_80,
        faltas_restantes_80=remaining_80,
        nota_asistencia=grade,
        estado=status,
        aviso=aviso,
    )


def attendance_grade_for_user(db: Session, user_id: str) -> GradeOut:
    metrics = build_attendance_metrics(db, user_id)
    return GradeOut(
        id_tarea=-2,
        nombre_tarea="Asistencia",
        id_bloque="ACTITUD",
        nota=metrics.nota_asistencia,
        categoria="actitud",
        peso=GRADE_CATEGORY_WEIGHTS["actitud"],
    )


def is_visible_grade_task(task: Tarea) -> bool:
    if not task.fecha or task.fecha > date.today():
        return False
    normalized = task.nombre.lower()
    excluded_fragments = [
        "ppt",
        "pptx",
        "tfm",
        "experiencia internacional",
        "confirmación experiencia internacional",
        "confirmaci",
    ]
    if any(fragment in normalized for fragment in excluded_fragments):
        return False
    if task.id_tarea in {7, 13, 18}:
        return True
    return not any(fragment in normalized for fragment in ["dp1", "dp2", "dp3", "data project", "hito"])


class AttendanceCreate(BaseModel):
    id_alumno: str
    id_sesion: str
    fecha: Optional[date] = None
    presente: bool


class StudentAttendanceCreate(BaseModel):
    id_sesion: str


class AttendanceOut(ORMModel):
    id_asistencia: int
    id_alumno: str
    id_sesion: str
    fecha: Optional[date] = None
    presente: bool


class AttendanceRosterRow(BaseModel):
    id_alumno: str
    nombre: str
    apellido: str
    id_sesion: str
    fecha: Optional[date] = None
    presente: Optional[bool] = None
    id_asistencia: Optional[int] = None


class AttendanceMetricsOut(BaseModel):
    total_clases: int
    clases_asistidas: int
    porcentaje_asistencia: float
    faltas: int
    faltas_permitidas_80: int
    faltas_restantes_80: int
    nota_asistencia: float
    estado: str
    aviso: Optional[str] = None


class DashboardOut(BaseModel):
    grades: List[GradeOut]
    attendance: Optional[AttendanceMetricsOut] = None
    events: List[EventOut]


class TutoringSlotCreate(BaseModel):
    id_profesor: Optional[str] = None
    id_bloque: Optional[str] = None
    dia_semana: int
    hora_inicio: time
    hora_fin: time
    ubicacion: str
    disponible: bool = True


class TutoringSlotOut(ORMModel):
    id: str
    id_profesor: str
    id_bloque: Optional[str] = None
    dia_semana: int
    hora_inicio: time
    hora_fin: time
    ubicacion: str
    disponible: bool


class ReservationCreate(BaseModel):
    id_profesor: str
    id_franja: str
    fecha: date
    notas: Optional[str] = None


class ReservationUpdate(BaseModel):
    estado: str
    id_franja: Optional[str] = None
    fecha: Optional[date] = None
    notas: Optional[str] = None


class ReservationOut(ORMModel):
    id: str
    id_alumno: str
    id_profesor: str
    id_franja: str
    fecha: date
    notas: Optional[str] = None
    estado: str
    fecha_creacion: datetime


class SolicitudTutoriaCreate(BaseModel):
    id_profesor: str
    motivo: str
    opcion1_fecha_hora: datetime
    opcion2_fecha_hora: datetime
    opcion3_fecha_hora: Optional[datetime] = None
    comentario_alumno: Optional[str] = None


class SolicitudTutoriaOut(ORMModel):
    id: str
    id_alumno: str
    id_profesor: str
    motivo: str
    estado: str
    opcion1_fecha_hora: datetime
    opcion2_fecha_hora: datetime
    opcion3_fecha_hora: Optional[datetime] = None
    fecha_hora_confirmada: Optional[datetime] = None
    propuesta_alternativa_fecha_hora: Optional[datetime] = None
    comentario_profesor: Optional[str] = None
    comentario_alumno: Optional[str] = None
    fecha_creacion: datetime
    fecha_actualizacion: datetime


class NotificationOut(ORMModel):
    id: str
    tipo: str
    titulo: str
    mensaje: str
    leida: bool
    fecha_creacion: datetime


class NotificationSettingsOut(ORMModel):
    avisos_calendario: bool
    avisos_notas: bool
    avisos_asistencia: bool


class EmailCreate(BaseModel):
    id_destinatario: str
    asunto: str
    cuerpo: str


class EmailOut(ORMModel):
    id: str
    id_remitente: str
    id_destinatario: str
    asunto: str
    cuerpo: str
    leido: bool
    fecha_envio: datetime


class UbicacionCreate(BaseModel):
    descripcion: str
    planta: Optional[int] = None
    aula: Optional[str] = None


class UbicacionOut(ORMModel):
    id_ubicacion: str
    descripcion: str
    planta: Optional[int] = None
    aula: Optional[str] = None


class GrupoOut(ORMModel):
    id_grupo: str
    nombre: str


class ContentCreate(BaseModel):
    titulo: str
    descripcion: Optional[str] = None
    tipo: str
    url: str


class ContentOut(ORMModel):
    id: str
    id_bloque: str
    id_profesor: str
    titulo: str
    descripcion: Optional[str] = None
    tipo: str
    url: str
    fecha_subida: datetime


def model_dump(instance: BaseModel, **kwargs):
    if hasattr(instance, "model_dump"):
        return instance.model_dump(**kwargs)
    return instance.dict(**kwargs)


def verify_password(stored_password: str, provided_password: str) -> bool:
    if not stored_password:
        return False
    if (stored_password.startswith("$2a$") or stored_password.startswith("$2b$")) and bcrypt_lib:
        return bcrypt_lib.checkpw(provided_password.encode("utf-8"), stored_password.encode("utf-8"))
    return stored_password == provided_password


def hash_password(password: str) -> str:
    if bcrypt_lib:
        salt = bcrypt_lib.gensalt()
        return bcrypt_lib.hashpw(password.encode("utf-8"), salt).decode("utf-8")
    return password


def _b64url_encode(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode("utf-8")


def _b64url_decode(value: str) -> bytes:
    padding = "=" * (-len(value) % 4)
    return base64.urlsafe_b64decode((value + padding).encode("utf-8"))


def jwt_encode(payload: dict, key: str, algorithm: str) -> str:
    if jwt:
        return jwt.encode(payload, key, algorithm=algorithm)

    if algorithm != "HS256":
        raise ValueError("Fallback JWT solo soporta HS256")
    header = {"alg": algorithm, "typ": "JWT"}
    signing_input = ".".join(
        [
            _b64url_encode(json.dumps(header, separators=(",", ":"), sort_keys=True).encode("utf-8")),
            _b64url_encode(json.dumps(payload, separators=(",", ":"), sort_keys=True).encode("utf-8")),
        ]
    )
    signature = hmac.new(key.encode("utf-8"), signing_input.encode("utf-8"), hashlib.sha256).digest()
    return f"{signing_input}.{_b64url_encode(signature)}"


def jwt_decode(token: str, key: str, algorithms: List[str]) -> dict:
    if jwt:
        return jwt.decode(token, key, algorithms=algorithms)

    if "HS256" not in algorithms:
        raise JWTError("Algoritmo no soportado")
    try:
        header_b64, payload_b64, signature_b64 = token.split(".")
    except ValueError as exc:
        raise JWTError("Token malformado") from exc

    signing_input = f"{header_b64}.{payload_b64}"
    expected_signature = hmac.new(
        key.encode("utf-8"),
        signing_input.encode("utf-8"),
        hashlib.sha256,
    ).digest()
    if not hmac.compare_digest(_b64url_encode(expected_signature), signature_b64):
        raise JWTError("Firma invalida")

    payload = json.loads(_b64url_decode(payload_b64))
    exp = payload.get("exp")
    if exp is not None and float(exp) < datetime.utcnow().timestamp():
        raise JWTError("Token expirado")
    return payload


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=15))
    to_encode.update({"exp": int(expire.timestamp())})
    return jwt_encode(to_encode, settings.jwt_secret, algorithm=settings.JWT_ALGORITHM)


def get_user_id(user) -> str:
    return (
        getattr(user, "id_alumno", None)
        or getattr(user, "id_profesor", None)
        or getattr(user, "id_coordinador", None)
    )


def get_user_role(user) -> str:
    if getattr(user, "id_alumno", None):
        return "alumno"
    if getattr(user, "id_profesor", None):
        return "profesor"
    if getattr(user, "id_coordinador", None):
        return "personal"
    return "desconocido"


def get_user_last_name(user) -> str:
    if getattr(user, "id_alumno", None):
        return user.apellido1 or ""
    return user.apellido or ""


def serialize_profile(user) -> UserProfileOut:
    return UserProfileOut(
        id=get_user_id(user),
        nombre=user.nombre,
        apellido=get_user_last_name(user),
        correo=user.correo,
        rol=get_user_role(user),
        url_foto=user.url_foto,
    )


def ensure_profile_detail(db: Session, user_id: str) -> PerfilDetalle:
    detail = db.query(PerfilDetalle).filter(PerfilDetalle.id_usuario == user_id).first()
    if detail:
        return detail
    detail = PerfilDetalle(id_usuario=user_id)
    db.add(detail)
    db.commit()
    db.refresh(detail)
    return detail


def safe_upload_user_id(user_id: str) -> str:
    return re.sub(r"[^a-zA-Z0-9_.-]", "_", user_id)


def user_upload_dir(user_id: str) -> Path:
    if UPLOAD_ROOT is None:
        raise RuntimeError("user_upload_dir solo se usa con almacenamiento local")
    safe_id = re.sub(r"[^a-zA-Z0-9_.-]", "_", user_id)
    path = UPLOAD_ROOT / "profiles" / safe_id
    path.mkdir(parents=True, exist_ok=True)
    return path


def public_upload_url(path: Path) -> str:
    if UPLOAD_ROOT is None:
        raise RuntimeError("public_upload_url solo se usa con almacenamiento local")
    relative = path.relative_to(UPLOAD_ROOT).as_posix()
    return f"{PUBLIC_UPLOAD_PREFIX}/{relative}"


def gcs_object_name(relative_path: str) -> str:
    return "/".join(part for part in [GCS_UPLOAD_PREFIX, relative_path.strip("/")] if part)


def public_gcs_upload_url(relative_path: str) -> str:
    return f"{PUBLIC_UPLOAD_PREFIX}/{relative_path.strip('/')}"


def delete_public_upload(url: Optional[str]) -> None:
    if not url or not url.startswith(f"{PUBLIC_UPLOAD_PREFIX}/"):
        return
    relative = url.removeprefix(f"{PUBLIC_UPLOAD_PREFIX}/")
    if GCS_UPLOAD_BUCKET:
        bucket = gcs_client().bucket(GCS_UPLOAD_BUCKET)
        try:
            bucket.blob(gcs_object_name(relative)).delete(if_generation_match=None)
        except NotFound:
            pass
        return
    if UPLOAD_ROOT is None:
        return
    target = (UPLOAD_ROOT / url.removeprefix(f"{PUBLIC_UPLOAD_PREFIX}/")).resolve()
    if UPLOAD_ROOT.resolve() in target.parents and target.exists():
        target.unlink()


def validate_upload(file: UploadFile, allowed_extensions: set[str], allowed_content_types: set[str], max_mb: int) -> str:
    filename = file.filename or ""
    ext = filename.rsplit(".", 1)[-1].lower() if "." in filename else ""
    if ext not in allowed_extensions:
        raise HTTPException(status_code=422, detail=f"Formato no permitido. Usa: {', '.join(sorted(allowed_extensions))}")
    if file.content_type not in allowed_content_types:
        raise HTTPException(status_code=422, detail="Tipo de archivo no permitido.")
    max_bytes = max_mb * 1024 * 1024
    file.file.seek(0, os.SEEK_END)
    size = file.file.tell()
    file.file.seek(0)
    if size > max_bytes:
        raise HTTPException(status_code=413, detail=f"El archivo supera el limite de {max_mb} MB.")
    return ext


def store_upload(user_id: str, file: UploadFile, folder: str, basename: str, ext: str) -> str:
    if GCS_UPLOAD_BUCKET:
        relative = f"profiles/{safe_upload_user_id(user_id)}/{folder}/{basename}.{ext}"
        bucket = gcs_client().bucket(GCS_UPLOAD_BUCKET)
        blob = bucket.blob(gcs_object_name(relative))
        file.file.seek(0)
        blob.upload_from_file(file.file, content_type=file.content_type)
        return public_gcs_upload_url(relative)

    target_dir = user_upload_dir(user_id) / folder
    target_dir.mkdir(parents=True, exist_ok=True)
    target = target_dir / f"{basename}.{ext}"
    with target.open("wb") as out:
        shutil.copyfileobj(file.file, out)
    return public_upload_url(target)


def apply_detail_update(detail: PerfilDetalle, payload: BaseModel, fields: list[str]) -> None:
    data = model_dump(payload, exclude_unset=True)
    for field in fields:
        if field in data:
            setattr(detail, field, data[field])
    detail.fecha_actualizacion = datetime.utcnow()


def role_display(role: str) -> str:
    if role == "profesor":
        return "Profesor"
    if role == "personal":
        return "Coordinador"
    return "Alumno"


def serialize_document(document: PerfilDocumento) -> ProfileDocumentOut:
    return ProfileDocumentOut(
        id=document.id,
        nombre=document.nombre,
        tipo=document.tipo,
        url=document.url,
        content_type=document.content_type,
        estado=document.estado,
        fecha_subida=document.fecha_subida,
    )


def build_full_profile(db: Session, user) -> ProfileFullOut:
    user_id = get_user_id(user)
    role = get_user_role(user)
    detail = ensure_profile_detail(db, user_id)
    documents = (
        db.query(PerfilDocumento)
        .filter(PerfilDocumento.id_usuario == user_id)
        .order_by(PerfilDocumento.fecha_subida.desc())
        .all()
    )

    common = {
        "id": user_id,
        "nombre": user.nombre,
        "apellido": get_user_last_name(user),
        "correo": user.correo,
        "rol": role_display(role),
        "url_foto": user.url_foto or None,
        "estado": detail.estado,
        "telefono": detail.telefono,
        "ciudad": detail.ciudad,
        "idioma_preferido": detail.idioma_preferido,
        "contacto_emergencia": detail.contacto_emergencia,
        "correo_personal": detail.correo_personal,
        "linkedin": detail.linkedin,
        "github": detail.github,
        "portfolio": detail.portfolio,
        "preferencia_contacto": detail.preferencia_contacto,
        "area_interes": detail.area_interes,
        "stack_tecnologico": detail.stack_tecnologico,
        "experiencia_actual": detail.experiencia_actual,
        "disponibilidad": detail.disponibilidad,
        "preferencia_jornada": detail.preferencia_jornada,
        "cv": ProfileCvOut(nombre=detail.cv_nombre, url=detail.cv_url, fecha_subida=detail.cv_fecha_subida),
        "documentos": [serialize_document(document) for document in documents],
        "idioma_app": detail.idioma_app,
        "notificaciones_email": detail.notificaciones_email,
        "notificaciones_push": detail.notificaciones_push,
        "visibilidad_profesional": detail.visibilidad_profesional,
        "permitir_cv_empleabilidad": detail.permitir_cv_empleabilidad,
        "permitir_links_profesores": detail.permitir_links_profesores,
        "tema": detail.tema,
        "ultimo_acceso": detail.ultimo_acceso,
    }

    if role == "alumno":
        group_names = [rel.id_grupo for rel in db.query(RelAlumnosGrupos).filter(RelAlumnosGrupos.id_alumno == user_id).all()]
        coordinator = None
        if group_names:
            coordinator_link = db.query(RelCoordinadoresGrupos).filter(RelCoordinadoresGrupos.id_grupo == group_names[0]).first()
            if coordinator_link:
                coordinator = db.query(Coordinador).filter(Coordinador.id_coordinador == coordinator_link.id_coordinador).first()
        return ProfileFullOut(
            **common,
            programa_area="Master Big Data & Cloud",
            grupo=user.grupo or (group_names[0] if group_names else None),
            curso_academico="2025-26",
            promocion="MDA 2025-26",
            campus="EDEM Escuela de Empresarios",
            modalidad="Presencial",
            coordinador_asignado=f"{coordinator.nombre} {coordinator.apellido}" if coordinator else None,
            tutor_academico="Pedro Nieto Pelaez",
            fecha_inicio="2025-09-29",
            fecha_fin_estimada="17-07-2026",
        )

    if role == "profesor":
        block_ids = [rel.id_bloque for rel in db.query(RelProfesoresBloques).filter(RelProfesoresBloques.id_profesor == user_id).all()]
        blocks = db.query(Bloque).filter(Bloque.id_bloque.in_(block_ids)).all() if block_ids else []
        slots = db.query(FranjaTutoria).filter(FranjaTutoria.id_profesor == user_id).order_by(FranjaTutoria.dia_semana, FranjaTutoria.hora_inicio).all()
        schedule = ", ".join(f"Dia {slot.dia_semana} {slot.hora_inicio.strftime('%H:%M')}-{slot.hora_fin.strftime('%H:%M')}" for slot in slots) or None
        return ProfileFullOut(
            **common,
            programa_area="Docencia",
            departamento_area="Data & AI",
            asignaturas=[block.nombre for block in blocks],
            especialidad=detail.area_interes or "Data Analytics",
            horario_tutorias=schedule,
            disponibilidad_contacto=detail.preferencia_contacto or "email",
        )

    group_ids = [rel.id_grupo for rel in db.query(RelCoordinadoresGrupos).filter(RelCoordinadoresGrupos.id_coordinador == user_id).all()]
    programs = sorted({group.split()[0] for group in group_ids}) if group_ids else []
    return ProfileFullOut(
        **common,
        programa_area="Coordinacion academica",
        programas_coordina=programs,
        grupos_asignados=group_ids,
        area_coordinacion="Programas Data",
        horario_atencion="Lunes a viernes, 9:00-18:00",
        permisos_administrativos=["Documentacion", "Asistencia", "Notas", "Calendario"],
    )


def find_user_by_id(db: Session, user_id: str):
    user = db.query(Alumno).filter(Alumno.id_alumno == user_id).first()
    if user:
        return user
    user = db.query(Profesor).filter(Profesor.id_profesor == user_id).first()
    if user:
        return user
    return db.query(Coordinador).filter(Coordinador.id_coordinador == user_id).first()


def find_user_by_email(db: Session, email: str):
    user = db.query(Alumno).filter(Alumno.correo == email).first()
    if user:
        return user
    user = db.query(Profesor).filter(Profesor.correo == email).first()
    if user:
        return user
    return db.query(Coordinador).filter(Coordinador.correo == email).first()


def ensure_notification_settings(db: Session, user_id: str) -> ConfiguracionNotificacion:
    config = db.query(ConfiguracionNotificacion).filter(
        ConfiguracionNotificacion.id_usuario == user_id
    ).first()
    if config:
        return config
    config = ConfiguracionNotificacion(id_usuario=user_id)
    db.add(config)
    db.commit()
    db.refresh(config)
    return config


def enrich_event_block(session: Session, event_payload: dict) -> dict:
    id_sesion = event_payload.get("id_sesion")
    if id_sesion and not event_payload.get("id_bloque"):
        sesion = session.query(Sesion).filter(Sesion.id_sesion == id_sesion).first()
        if not sesion:
            raise HTTPException(status_code=404, detail="Sesion no encontrada")
        event_payload["id_bloque"] = sesion.id_bloque
        if not event_payload.get("aula"):
            event_payload["aula"] = sesion.aula
    return event_payload


def serialize_calendar_event(
    db: Session,
    event: Evento,
    block_map: Optional[dict[str, Bloque]] = None,
    professor_map: Optional[dict[str, Profesor]] = None,
    session_map: Optional[dict[str, Sesion]] = None,
) -> EventOut:
    block = None
    if event.id_bloque:
        block = block_map.get(event.id_bloque) if block_map is not None else db.query(Bloque).filter(Bloque.id_bloque == event.id_bloque).first()

    session_row = None
    if event.id_sesion:
        session_row = (
            session_map.get(event.id_sesion)
            if session_map is not None
            else db.query(Sesion).filter(Sesion.id_sesion == event.id_sesion).first()
        )

    professor = None
    if event.id_profesor:
        professor = (
            professor_map.get(event.id_profesor)
            if professor_map is not None
            else db.query(Profesor).filter(Profesor.id_profesor == event.id_profesor).first()
        )
    return EventOut(
        id=event.id,
        tipo=event.tipo,
        titulo=event.titulo,
        id_bloque=event.id_bloque,
        bloque_nombre=block.nombre if block else None,
        id_sesion=event.id_sesion,
        aula=event.aula,
        edificio=session_row.edificio if session_row else None,
        planta=session_row.planta if session_row else None,
        id_profesor=event.id_profesor,
        profesor_nombre=f"{professor.nombre} {professor.apellido}" if professor else None,
        fecha_inicio=event.fecha_inicio,
        fecha_fin=event.fecha_fin,
        descripcion=event.descripcion,
    )


def serialize_calendar_events(db: Session, events: List[Evento]) -> List[EventOut]:
    block_ids = sorted({event.id_bloque for event in events if event.id_bloque})
    professor_ids = sorted({event.id_profesor for event in events if event.id_profesor})
    session_ids = sorted({event.id_sesion for event in events if event.id_sesion})
    block_map = {
        block.id_bloque: block
        for block in db.query(Bloque).filter(Bloque.id_bloque.in_(block_ids)).all()
    } if block_ids else {}
    professor_map = {
        professor.id_profesor: professor
        for professor in db.query(Profesor).filter(Profesor.id_profesor.in_(professor_ids)).all()
    } if professor_ids else {}
    session_map = {
        session_row.id_sesion: session_row
        for session_row in db.query(Sesion).filter(Sesion.id_sesion.in_(session_ids)).all()
    } if session_ids else {}
    return [serialize_calendar_event(db, event, block_map, professor_map, session_map) for event in events]


CALENDAR_CACHE_TTL_SECONDS = 60
_calendar_events_cache: dict[str, object] = {"expires_at": 0.0, "events": None}
_dashboard_events_cache: dict[str, object] = {"expires_at": 0.0, "events": None}


def invalidate_calendar_cache() -> None:
    _calendar_events_cache["events"] = None
    _calendar_events_cache["expires_at"] = 0.0
    _dashboard_events_cache["events"] = None
    _dashboard_events_cache["expires_at"] = 0.0


def cached_calendar_events(db: Session) -> List[EventOut]:
    now = time_module.monotonic()
    cached = _calendar_events_cache.get("events")
    if cached is not None and float(_calendar_events_cache.get("expires_at", 0.0)) > now:
        return cached  # type: ignore[return-value]

    events = db.query(Evento).order_by(Evento.fecha_inicio).all()
    serialized = serialize_calendar_events(db, events)
    _calendar_events_cache["events"] = serialized
    _calendar_events_cache["expires_at"] = now + CALENDAR_CACHE_TTL_SECONDS
    return serialized


def cached_dashboard_events(db: Session) -> List[EventOut]:
    now = time_module.monotonic()
    cached = _dashboard_events_cache.get("events")
    if cached is not None and float(_dashboard_events_cache.get("expires_at", 0.0)) > now:
        return cached  # type: ignore[return-value]

    current_time = datetime.now()
    day_window_start = datetime.combine(date.today() - timedelta(days=1), time.min)
    day_window_end = datetime.combine(date.today() + timedelta(days=1), time.max)
    deliveries_end = current_time + timedelta(days=14)
    events = (
        db.query(Evento)
        .filter(
            or_(
                and_(Evento.fecha_inicio <= day_window_end, Evento.fecha_fin >= day_window_start),
                and_(
                    Evento.tipo == "delivery",
                    Evento.fecha_inicio > current_time,
                    Evento.fecha_inicio < deliveries_end,
                ),
            )
        )
        .order_by(Evento.fecha_inicio)
        .all()
    )
    serialized = serialize_calendar_events(db, events)
    _dashboard_events_cache["events"] = serialized
    _dashboard_events_cache["expires_at"] = now + CALENDAR_CACHE_TTL_SECONDS
    return serialized


def dashboard_events_for_user(db: Session, current_user) -> List[EventOut]:
    query = restrict_events_to_current_user(db.query(Evento), current_user)
    events = (
        query
        .filter(Evento.fecha_fin >= datetime.utcnow())
        .order_by(Evento.fecha_inicio)
        .limit(30)
        .all()
    )
    return serialize_calendar_events(db, events)


def build_my_grades(db: Session, current_user) -> List[GradeOut]:
    if get_user_role(current_user) != "alumno":
        return []
    tasks = (
        db.query(Tarea)
        .join(RelBloquesGrupos, RelBloquesGrupos.id_bloque == Tarea.id_bloque)
        .join(RelAlumnosGrupos, RelAlumnosGrupos.id_grupo == RelBloquesGrupos.id_grupo)
        .filter(RelAlumnosGrupos.id_alumno == current_user.id_alumno)
        .order_by(Tarea.fecha, Tarea.id_tarea)
        .all()
    )
    grade_map = {
        grade.id_tarea: grade.nota
        for grade in db.query(RelAlumnoTarea)
        .filter(RelAlumnoTarea.id_alumno == current_user.id_alumno)
        .all()
    }
    grades = [
        build_grade_out(task, grade_map.get(task.id_tarea))
        for task in tasks
        if is_visible_grade_task(task)
    ]
    grades.append(attendance_grade_for_user(db, current_user.id_alumno))
    grades.append(attitude_grade_for_student(current_user.id_alumno))
    return grades


async def get_current_user(
    db: Session = Depends(get_db),
    token: str = Depends(oauth2_scheme),
):
    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt_decode(token, settings.jwt_secret, algorithms=[settings.JWT_ALGORITHM])
        user_id = payload.get("sub")
        if not user_id:
            raise credentials_exception
    except JWTError as exc:
        raise credentials_exception from exc

    user = find_user_by_id(db, user_id)
    if not user:
        raise credentials_exception
    return user


def require_student(current_user=Depends(get_current_user)):
    if get_user_role(current_user) != "alumno":
        raise HTTPException(status_code=403, detail="Solo los alumnos pueden acceder.")
    return current_user


def require_professor(current_user=Depends(get_current_user)):
    if get_user_role(current_user) != "profesor":
        raise HTTPException(status_code=403, detail="Solo los profesores pueden acceder.")
    return current_user


def require_staff(current_user=Depends(get_current_user)):
    if get_user_role(current_user) != "personal":
        raise HTTPException(status_code=403, detail="Solo el personal puede acceder.")
    return current_user


def require_professor_or_staff(current_user=Depends(get_current_user)):
    if get_user_role(current_user) not in {"profesor", "personal"}:
        raise HTTPException(status_code=403, detail="Solo profesores o personal pueden acceder.")
    return current_user


def professor_teaches_block(db: Session, professor_id: str, block_id: str) -> bool:
    return db.query(RelProfesoresBloques).filter(
        RelProfesoresBloques.id_profesor == professor_id,
        RelProfesoresBloques.id_bloque == block_id,
    ).first() is not None


def assert_professor_teaches_block(db: Session, current_user, block_id: Optional[str]) -> None:
    if get_user_role(current_user) != "profesor" or not block_id:
        return
    if not professor_teaches_block(db, current_user.id_profesor, block_id):
        raise HTTPException(status_code=403, detail="No puedes acceder a este bloque")


def restrict_events_to_current_user(query, current_user):
    role = get_user_role(current_user)
    if role == "profesor":
        query = query.filter(Evento.id_profesor == current_user.id_profesor)
    elif role == "alumno":
        query = (
            query
            .join(RelBloquesGrupos, RelBloquesGrupos.id_bloque == Evento.id_bloque)
            .join(RelAlumnosGrupos, RelAlumnosGrupos.id_grupo == RelBloquesGrupos.id_grupo)
            .filter(RelAlumnosGrupos.id_alumno == current_user.id_alumno)
        )
    elif role == "personal":
        query = (
            query
            .join(RelBloquesGrupos, RelBloquesGrupos.id_bloque == Evento.id_bloque)
            .join(RelCoordinadoresGrupos, RelCoordinadoresGrupos.id_grupo == RelBloquesGrupos.id_grupo)
            .filter(RelCoordinadoresGrupos.id_coordinador == current_user.id_coordinador)
        )
    return query


def ensure_event_write_allowed(db: Session, event: Evento, current_user, creating: bool = False) -> None:
    role = get_user_role(current_user)
    if role == "personal":
        return
    if role != "profesor":
        raise HTTPException(status_code=403, detail="No puedes modificar eventos")
    if event.id_sesion:
        raise HTTPException(status_code=403, detail="No puedes modificar sesiones oficiales")
    if event.tipo not in {"delivery", "exam", "notice"}:
        raise HTTPException(status_code=403, detail="Solo puedes gestionar entregas, examenes o avisos")
    if event.id_profesor != current_user.id_profesor:
        raise HTTPException(status_code=403, detail="No puedes modificar eventos de otro profesor")
    if event.id_bloque and not professor_teaches_block(db, current_user.id_profesor, event.id_bloque):
        raise HTTPException(status_code=403, detail="No puedes crear eventos en este bloque")


@app.on_event("startup")
def startup():
    Base.metadata.create_all(bind=engine)


@app.get("/")
def root():
    return {"message": "EDEM Student Hub API", "docs": "/docs", "health": "/health"}


@app.get("/health")
def health():
    return {"status": "ok", "environment": settings.ENVIRONMENT}


@app.post("/api/v1/token", response_model=Token, tags=["Autenticacion"])
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    user = find_user_by_email(db, form_data.username)
    if not user or not verify_password(user.contrasena, form_data.password):
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
            headers={"WWW-Authenticate": "Bearer"},
        )

    expires_delta = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": get_user_id(user)},
        expires_delta=expires_delta,
    )

    # Registrar la sesión en la base de datos
    token_hash = hashlib.sha256(access_token.encode()).hexdigest()
    session = UserSession(
        id=generate_id(),
        id_usuario=get_user_id(user),
        token_hash=token_hash,
        fecha_expiracion=datetime.utcnow() + expires_delta,
        activa=True,
    )
    db.add(session)
    db.commit()

    return {"access_token": access_token, "token_type": "bearer"}


@app.get("/api/v1/users/me", response_model=UserProfileOut, tags=["Perfil y Roles"])
def get_my_profile(current_user=Depends(get_current_user)):
    return serialize_profile(current_user)


@app.put("/api/v1/users/me", tags=["Perfil y Roles"])
def update_my_profile(
    profile_data: ProfileUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    data = model_dump(profile_data, exclude_unset=True)
    if "nombre" in data:
        current_user.nombre = data["nombre"]
    if "correo" in data:
        current_user.correo = data["correo"]
    if "apellido" in data:
        if get_user_role(current_user) == "alumno":
            current_user.apellido1 = data["apellido"]
        else:
            current_user.apellido1 = data["apellido"]
    db.commit()
    db.refresh(current_user)
    return {"mensaje": "Perfil actualizado correctamente"}


@app.post("/api/v1/logout", tags=["Autenticacion"])
def logout(
    db: Session = Depends(get_db),
    token: str = Depends(oauth2_scheme),
    current_user=Depends(get_current_user),
):
    """Cierra la sesión actual marcándola como inactiva"""
    token_hash = hashlib.sha256(token.encode()).hexdigest()
    session = db.query(UserSession).filter(UserSession.token_hash == token_hash).first()
    if session:
        session.activa = False
        db.commit()
    return {"mensaje": "Sesión cerrada correctamente"}


@app.put("/api/v1/users/me/photo", tags=["Perfil y Roles"])
def upload_my_photo(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    ext = validate_upload(file, {"jpg", "jpeg", "png", "webp"}, {"image/jpeg", "image/png", "image/webp"}, 5)
    delete_public_upload(current_user.url_foto)
    current_user.url_foto = store_upload(user_id, file, "avatar", "avatar", ext)
    public_url = current_user.url_foto
    db.commit()
    db.refresh(current_user)
    return {"mensaje": "Foto subida con éxito", "url_foto": public_url}

@app.delete("/api/v1/users/me/photo", tags=["Perfil y Roles"])
def delete_my_photo(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    delete_public_upload(current_user.url_foto)
    current_user.url_foto = None
    db.commit()
    return {"mensaje": "Foto eliminada correctamente"}

@app.get("/api/profile/me", response_model=ProfileFullOut, tags=["Perfil"])
def get_my_full_profile(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    detail = ensure_profile_detail(db, user_id)
    detail.ultimo_acceso = datetime.utcnow()
    db.commit()
    return build_full_profile(db, current_user)


@app.put("/api/profile/me/personal", response_model=ProfileFullOut, tags=["Perfil"])
def update_profile_personal(
    payload: ProfilePersonalUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    data = model_dump(payload, exclude_unset=True)
    if "nombre" in data:
        current_user.nombre = data["nombre"]
    if "apellido" in data:
        current_user.apellido1 = data["apellido"]
    detail = ensure_profile_detail(db, get_user_id(current_user))
    apply_detail_update(detail, payload, ["telefono", "ciudad", "idioma_preferido", "contacto_emergencia"])
    db.commit()
    db.refresh(current_user)
    return build_full_profile(db, current_user)


@app.put("/api/profile/me/contact", response_model=ProfileFullOut, tags=["Perfil"])
def update_profile_contact(
    payload: ProfileContactUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    detail = ensure_profile_detail(db, get_user_id(current_user))
    apply_detail_update(detail, payload, ["correo_personal", "telefono", "linkedin", "github", "portfolio", "preferencia_contacto"])
    db.commit()
    return build_full_profile(db, current_user)


@app.put("/api/profile/me/professional", response_model=ProfileFullOut, tags=["Perfil"])
def update_profile_professional(
    payload: ProfileProfessionalUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    detail = ensure_profile_detail(db, get_user_id(current_user))
    apply_detail_update(
        detail,
        payload,
        ["area_interes", "stack_tecnologico", "experiencia_actual", "disponibilidad", "preferencia_jornada", "linkedin", "github", "portfolio"],
    )
    db.commit()
    return build_full_profile(db, current_user)


@app.put("/api/profile/me/preferences", response_model=ProfileFullOut, tags=["Perfil"])
def update_profile_preferences(
    payload: ProfilePreferencesUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    detail = ensure_profile_detail(db, get_user_id(current_user))
    apply_detail_update(
        detail,
        payload,
        ["idioma_app", "notificaciones_email", "notificaciones_push", "visibilidad_profesional", "permitir_cv_empleabilidad", "permitir_links_profesores", "tema"],
    )
    db.commit()
    return build_full_profile(db, current_user)


@app.post("/api/profile/me/avatar", response_model=UserProfileOut, tags=["Perfil"])
def upload_profile_avatar(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    ext = validate_upload(file, {"jpg", "jpeg", "png", "webp"}, {"image/jpeg", "image/png", "image/webp"}, 5)
    delete_public_upload(current_user.url_foto)
    current_user.url_foto = store_upload(user_id, file, "avatar", "avatar", ext)
    public_url = current_user.url_foto
    db.commit()
    db.refresh(current_user)
    return serialize_profile(current_user)


@app.delete("/api/profile/me/avatar", tags=["Perfil"])
def delete_profile_avatar(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    delete_public_upload(current_user.url_foto)
    current_user.url_foto = None
    db.commit()
    return {"mensaje": "Foto eliminada correctamente"}


@app.post("/api/profile/me/cv", response_model=ProfileFullOut, tags=["Perfil"])
def upload_my_cv(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    detail = ensure_profile_detail(db, user_id)
    ext = validate_upload(file, {"pdf"}, {"application/pdf"}, 10)
    delete_public_upload(detail.cv_url)
    detail.cv_url = store_upload(user_id, file, "cv", "cv", ext)
    detail.cv_nombre = file.filename or "cv.pdf"
    detail.cv_fecha_subida = datetime.utcnow()
    detail.fecha_actualizacion = datetime.utcnow()
    db.commit()
    return build_full_profile(db, current_user)


@app.delete("/api/profile/me/cv", response_model=ProfileFullOut, tags=["Perfil"])
def delete_my_cv(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    detail = ensure_profile_detail(db, get_user_id(current_user))
    delete_public_upload(detail.cv_url)
    detail.cv_url = None
    detail.cv_nombre = None
    detail.cv_fecha_subida = None
    detail.fecha_actualizacion = datetime.utcnow()
    db.commit()
    return build_full_profile(db, current_user)


@app.get("/api/profile/me/documents", response_model=List[ProfileDocumentOut], tags=["Perfil"])
def list_my_documents(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    documents = db.query(PerfilDocumento).filter(PerfilDocumento.id_usuario == user_id).order_by(PerfilDocumento.fecha_subida.desc()).all()
    return [serialize_document(document) for document in documents]


@app.post("/api/profile/me/documents", response_model=ProfileDocumentOut, tags=["Perfil"], status_code=201)
def upload_my_document(
    tipo: str,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    ext = validate_upload(file, {"pdf", "jpg", "jpeg", "png"}, {"application/pdf", "image/jpeg", "image/png"}, 10)
    document_id = str(uuid.uuid4())
    document = PerfilDocumento(
        id=document_id,
        id_usuario=user_id,
        nombre=file.filename or f"documento.{ext}",
        tipo=tipo,
        url=store_upload(user_id, file, "documents", document_id, ext),
        content_type=file.content_type or "application/octet-stream",
        estado="Subido",
    )
    db.add(document)
    db.commit()
    db.refresh(document)
    return serialize_document(document)


@app.put("/api/profile/me/documents/{document_id}", response_model=ProfileDocumentOut, tags=["Perfil"])
def replace_my_document(
    document_id: str,
    tipo: Optional[str] = None,
    file: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    document = db.query(PerfilDocumento).filter(PerfilDocumento.id == document_id, PerfilDocumento.id_usuario == user_id).first()
    if not document:
        raise HTTPException(status_code=404, detail="Documento no encontrado")
    if tipo:
        document.tipo = tipo
    if file:
        ext = validate_upload(file, {"pdf", "jpg", "jpeg", "png"}, {"application/pdf", "image/jpeg", "image/png"}, 10)
        delete_public_upload(document.url)
        document.url = store_upload(user_id, file, "documents", document.id, ext)
        document.nombre = file.filename or document.nombre
        document.content_type = file.content_type or document.content_type
        document.estado = "Subido"
        document.fecha_subida = datetime.utcnow()
    db.commit()
    db.refresh(document)
    return serialize_document(document)


@app.delete("/api/profile/me/documents/{document_id}", tags=["Perfil"])
def delete_my_document(
    document_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    document = db.query(PerfilDocumento).filter(PerfilDocumento.id == document_id, PerfilDocumento.id_usuario == user_id).first()
    if not document:
        raise HTTPException(status_code=404, detail="Documento no encontrado")
    delete_public_upload(document.url)
    db.delete(document)
    db.commit()
    return {"mensaje": "Documento eliminado correctamente"}


@app.put("/api/profile/me/security/password", tags=["Perfil"])
def change_my_password(
    payload: PasswordChangeIn,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if not verify_password(current_user.contrasena, payload.current_password):
        raise HTTPException(status_code=400, detail="La contrasena actual no es correcta")
    if len(payload.new_password) < 8:
        raise HTTPException(status_code=422, detail="La nueva contrasena debe tener al menos 8 caracteres")
    current_user.contrasena = hash_password(payload.new_password)
    db.commit()
    return {"mensaje": "Contrasena actualizada correctamente"}


@app.get("/api/profile/me/documents/{document_id}/download", tags=["Perfil"])
def download_my_document(
    document_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    document = db.query(PerfilDocumento).filter(PerfilDocumento.id == document_id, PerfilDocumento.id_usuario == user_id).first()
    if not document:
        raise HTTPException(status_code=404, detail="Documento no encontrado")
    if GCS_UPLOAD_BUCKET:
        return RedirectResponse(document.url)
    if UPLOAD_ROOT is None:
        raise HTTPException(status_code=404, detail="Archivo no encontrado")
    target = (UPLOAD_ROOT / document.url.removeprefix(f"{PUBLIC_UPLOAD_PREFIX}/")).resolve()
    if not target.exists():
        raise HTTPException(status_code=404, detail="Archivo no encontrado")
    return FileResponse(target, media_type=document.content_type, filename=document.nombre)

@app.get("/api/v1/users/{user_id}", response_model=UserProfileOut, tags=["Perfil y Roles"])
def get_user_profile(
    user_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user = find_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return serialize_profile(user)


@app.get("/api/v1/dashboard/me", response_model=DashboardOut, tags=["Dashboard"])
def get_my_dashboard(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    role = get_user_role(current_user)
    grades = build_my_grades(db, current_user)
    attendance = build_attendance_metrics(db, user_id) if role == "alumno" else None
    return DashboardOut(
        grades=grades,
        attendance=attendance,
        events=dashboard_events_for_user(db, current_user),
    )


@app.get("/api/v1/calendar/events", response_model=List[EventOut], tags=["Calendario"])
def list_events(
    tipo: Optional[str] = None,
    id_bloque: Optional[str] = None,
    id_sesion: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    role = get_user_role(current_user)
    if role not in {"profesor", "alumno", "personal"} and not tipo and not id_bloque and not id_sesion:
        return cached_calendar_events(db)

    query = restrict_events_to_current_user(db.query(Evento), current_user)
    if tipo:
        query = query.filter(Evento.tipo == tipo)
    if id_bloque:
        query = query.filter(Evento.id_bloque == id_bloque)
    if id_sesion:
        query = query.filter(Evento.id_sesion == id_sesion)
    return serialize_calendar_events(db, query.order_by(Evento.fecha_inicio).all())


@app.post("/api/v1/calendar/events", response_model=EventOut, tags=["Calendario"], status_code=201)
def create_event(
    event_in: EventCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    payload = enrich_event_block(db, model_dump(event_in))
    role = get_user_role(current_user)
    if role == "profesor":
        payload["id_profesor"] = current_user.id_profesor
        if payload.get("id_sesion"):
            raise HTTPException(status_code=403, detail="No puedes crear sesiones oficiales")
        if payload.get("tipo") not in {"delivery", "exam", "notice"}:
            raise HTTPException(status_code=403, detail="Solo puedes crear entregas, examenes o avisos")
        assert_professor_teaches_block(db, current_user, payload.get("id_bloque"))
    if payload["fecha_fin"] <= payload["fecha_inicio"]:
        raise HTTPException(status_code=422, detail="La hora de fin debe ser posterior a la hora de inicio")
    event = Evento(id=str(uuid.uuid4()), **payload)
    ensure_event_write_allowed(db, event, current_user, creating=True)
    db.add(event)
    db.commit()
    invalidate_calendar_cache()
    db.refresh(event)
    return serialize_calendar_event(db, event)


@app.get("/api/v1/calendar/events/{event_id}", response_model=EventOut, tags=["Calendario"])
def get_event(
    event_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    event = db.query(Evento).filter(Evento.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Evento no encontrado")
    if get_user_role(current_user) == "profesor" and event.id_profesor != current_user.id_profesor:
        raise HTTPException(status_code=403, detail="No puedes ver eventos de otro profesor")
    return serialize_calendar_event(db, event)


@app.put("/api/v1/calendar/events/{event_id}", response_model=EventOut, tags=["Calendario"])
def update_event(
    event_id: str,
    event_in: EventUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    event = db.query(Evento).filter(Evento.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Evento no encontrado")
    ensure_event_write_allowed(db, event, current_user)
    payload = enrich_event_block(db, model_dump(event_in, exclude_unset=True))
    if get_user_role(current_user) == "profesor":
        payload["id_profesor"] = current_user.id_profesor
        if payload.get("id_sesion") or event.id_sesion:
            raise HTTPException(status_code=403, detail="No puedes modificar sesiones oficiales")
        if payload.get("tipo", event.tipo) not in {"delivery", "exam", "notice"}:
            raise HTTPException(status_code=403, detail="Solo puedes gestionar entregas, examenes o avisos")
        assert_professor_teaches_block(db, current_user, payload.get("id_bloque", event.id_bloque))
    fecha_inicio = payload.get("fecha_inicio", event.fecha_inicio)
    fecha_fin = payload.get("fecha_fin", event.fecha_fin)
    if fecha_inicio and fecha_fin and fecha_fin <= fecha_inicio:
        raise HTTPException(status_code=422, detail="La hora de fin debe ser posterior a la hora de inicio")
    for required in ("titulo",):
        if required in payload and not str(payload[required] or "").strip():
            raise HTTPException(status_code=422, detail="El titulo no puede estar vacio")
    for key, value in payload.items():
        setattr(event, key, value)
    if event.id_sesion:
        session_row = db.query(Sesion).filter(Sesion.id_sesion == event.id_sesion).first()
        if session_row:
            if "titulo" in payload:
                session_row.nombre = event.titulo
            if "id_bloque" in payload and event.id_bloque:
                session_row.id_bloque = event.id_bloque
            if "aula" in payload:
                session_row.aula = event.aula
            if "fecha_inicio" in payload:
                session_row.fecha = event.fecha_inicio.date()
                session_row.hora_inicio = event.fecha_inicio.time().replace(second=0, microsecond=0)
            if "fecha_fin" in payload:
                session_row.hora_fin = event.fecha_fin.time().replace(second=0, microsecond=0)
    db.commit()
    invalidate_calendar_cache()
    db.refresh(event)
    return serialize_calendar_event(db, event)


@app.delete("/api/v1/calendar/events/{event_id}", status_code=204, tags=["Calendario"])
def delete_event(
    event_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    event = db.query(Evento).filter(Evento.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Evento no encontrado")
    ensure_event_write_allowed(db, event, current_user)
    db.delete(event)
    db.commit()
    invalidate_calendar_cache()
    return


@app.get("/api/v1/blocks", response_model=List[BloqueOut], tags=["Bloques"])
def list_blocks(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return db.query(Bloque).order_by(Bloque.nombre).all()


@app.get("/api/v1/blocks/me", response_model=List[BloqueOut], tags=["Bloques"])
def list_my_blocks(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    role = get_user_role(current_user)
    if role == "profesor":
        return (
            db.query(Bloque)
            .join(RelProfesoresBloques, RelProfesoresBloques.id_bloque == Bloque.id_bloque)
            .filter(RelProfesoresBloques.id_profesor == current_user.id_profesor)
            .order_by(Bloque.nombre)
            .all()
        )
    if role == "alumno":
        return (
            db.query(Bloque)
            .join(RelBloquesGrupos, RelBloquesGrupos.id_bloque == Bloque.id_bloque)
            .join(RelAlumnosGrupos, RelAlumnosGrupos.id_grupo == RelBloquesGrupos.id_grupo)
            .filter(RelAlumnosGrupos.id_alumno == current_user.id_alumno)
            .distinct()
            .order_by(Bloque.nombre)
            .all()
        )
    return (
        db.query(Bloque)
        .join(RelBloquesGrupos, RelBloquesGrupos.id_bloque == Bloque.id_bloque)
        .join(RelCoordinadoresGrupos, RelCoordinadoresGrupos.id_grupo == RelBloquesGrupos.id_grupo)
        .filter(RelCoordinadoresGrupos.id_coordinador == current_user.id_coordinador)
        .distinct()
        .order_by(Bloque.nombre)
        .all()
    )


@app.get("/api/v1/blocks/{block_id}", response_model=BloqueOut, tags=["Bloques"])
def get_block(
    block_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    block = db.query(Bloque).filter(Bloque.id_bloque == block_id).first()
    if not block:
        raise HTTPException(status_code=404, detail="Bloque no encontrado")
    return block


@app.post("/api/v1/blocks", response_model=BloqueOut, tags=["Bloques"], status_code=201)
def create_block(
    block_in: BloqueCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_staff),
):
    block_id = block_in.id_bloque or f"BLQ-{uuid.uuid4().hex[:6].upper()}"
    existing = db.query(Bloque).filter(Bloque.id_bloque == block_id).first()
    if existing:
        raise HTTPException(status_code=409, detail="Ya existe un bloque con ese id")
    block = Bloque(id_bloque=block_id, nombre=block_in.nombre)
    db.add(block)
    db.commit()
    db.refresh(block)
    return block


@app.put("/api/v1/blocks/{block_id}", response_model=BloqueOut, tags=["Bloques"])
def update_block(
    block_id: str,
    block_in: BloqueCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_staff),
):
    block = db.query(Bloque).filter(Bloque.id_bloque == block_id).first()
    if not block:
        raise HTTPException(status_code=404, detail="Bloque no encontrado")
    block.nombre = block_in.nombre
    db.commit()
    db.refresh(block)
    return block


@app.delete("/api/v1/blocks/{block_id}", status_code=204, tags=["Bloques"])
def delete_block(
    block_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(require_staff),
):
    block = db.query(Bloque).filter(Bloque.id_bloque == block_id).first()
    if not block:
        raise HTTPException(status_code=404, detail="Bloque no encontrado")
    db.delete(block)
    db.commit()
    return


@app.get("/api/v1/blocks/{block_id}/students", response_model=List[AlumnoOut], tags=["Bloques"])
def list_block_students(
    block_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    students = (
        db.query(Alumno)
        .join(RelAlumnosGrupos, RelAlumnosGrupos.id_alumno == Alumno.id_alumno)
        .join(RelBloquesGrupos, RelBloquesGrupos.id_grupo == RelAlumnosGrupos.id_grupo)
        .filter(RelBloquesGrupos.id_bloque == block_id)
        .distinct()
        .order_by(Alumno.nombre, Alumno.apellido1)
        .all()
    )
    return [
        AlumnoOut(
            id_alumno=student.id_alumno,
            nombre=student.nombre,
            apellido=student.apellido1,
            correo=student.correo,
        )
        for student in students
    ]


@app.get("/api/v1/blocks/{block_id}/sessions", response_model=List[SesionOut], tags=["Sesiones"])
def list_block_sessions(
    block_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return (
        db.query(Sesion)
        .filter(Sesion.id_bloque == block_id)
        .order_by(Sesion.fecha, Sesion.hora_inicio)
        .all()
    )


@app.post("/api/v1/blocks/{block_id}/sessions", response_model=SesionOut, tags=["Sesiones"], status_code=201)
def create_block_session(
    block_id: str,
    session_in: SesionCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    if not db.query(Bloque).filter(Bloque.id_bloque == block_id).first():
        raise HTTPException(status_code=404, detail="Bloque no encontrado")
    session_id = session_in.id_sesion or f"SES-{uuid.uuid4().hex[:8].upper()}"
    session_row = Sesion(
        id_sesion=session_id,
        id_bloque=block_id,
        nombre=session_in.nombre,
        fecha=session_in.fecha,
        hora_inicio=session_in.hora_inicio,
        hora_fin=session_in.hora_fin,
        aula=session_in.aula,
        edificio=session_in.edificio,
        planta=session_in.planta,
    )
    db.add(session_row)
    db.commit()
    db.refresh(session_row)
    return session_row


@app.get("/api/v1/sessions", response_model=List[SesionOut], tags=["Sesiones"])
def list_sessions(
    id_bloque: Optional[str] = None,
    fecha: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    query = db.query(Sesion)
    if id_bloque:
        query = query.filter(Sesion.id_bloque == id_bloque)
    if fecha:
        query = query.filter(Sesion.fecha == fecha)
    return query.order_by(Sesion.fecha, Sesion.hora_inicio).all()


@app.get("/api/v1/sessions/me", response_model=List[SesionOut], tags=["Sesiones"])
def list_my_sessions(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    role = get_user_role(current_user)
    if role == "profesor":
        return (
            db.query(Sesion)
            .join(RelProfesoresBloques, RelProfesoresBloques.id_bloque == Sesion.id_bloque)
            .filter(RelProfesoresBloques.id_profesor == current_user.id_profesor)
            .distinct()
            .order_by(Sesion.fecha, Sesion.hora_inicio)
            .all()
        )
    if role == "alumno":
        return (
            db.query(Sesion)
            .join(RelBloquesGrupos, RelBloquesGrupos.id_bloque == Sesion.id_bloque)
            .join(RelAlumnosGrupos, RelAlumnosGrupos.id_grupo == RelBloquesGrupos.id_grupo)
            .filter(RelAlumnosGrupos.id_alumno == current_user.id_alumno)
            .distinct()
            .order_by(Sesion.fecha, Sesion.hora_inicio)
            .all()
        )
    return (
        db.query(Sesion)
        .join(RelBloquesGrupos, RelBloquesGrupos.id_bloque == Sesion.id_bloque)
        .join(RelCoordinadoresGrupos, RelCoordinadoresGrupos.id_grupo == RelBloquesGrupos.id_grupo)
        .filter(RelCoordinadoresGrupos.id_coordinador == current_user.id_coordinador)
        .distinct()
        .order_by(Sesion.fecha, Sesion.hora_inicio)
        .all()
    )


@app.get("/api/v1/professors", response_model=List[ProfesorListOut], tags=["Profesores"])
def list_professors(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return db.query(Profesor).order_by(Profesor.nombre, Profesor.apellido).all()


@app.post("/api/v1/sessions", response_model=SesionOut, tags=["Sesiones"], status_code=201)
def create_session(
    session_in: SesionCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    if not session_in.id_bloque:
        raise HTTPException(status_code=422, detail="id_bloque es obligatorio")
    if not db.query(Bloque).filter(Bloque.id_bloque == session_in.id_bloque).first():
        raise HTTPException(status_code=404, detail="Bloque no encontrado")
    session_id = session_in.id_sesion or f"SES-{uuid.uuid4().hex[:8].upper()}"
    session_row = Sesion(
        id_sesion=session_id,
        id_bloque=session_in.id_bloque,
        nombre=session_in.nombre,
        fecha=session_in.fecha,
        hora_inicio=session_in.hora_inicio,
        hora_fin=session_in.hora_fin,
        aula=session_in.aula,
        edificio=session_in.edificio,
        planta=session_in.planta,
    )
    db.add(session_row)
    db.commit()
    db.refresh(session_row)
    return session_row


@app.get("/api/v1/sessions/{session_id}", response_model=SesionOut, tags=["Sesiones"])
def get_session(
    session_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    session_row = db.query(Sesion).filter(Sesion.id_sesion == session_id).first()
    if not session_row:
        raise HTTPException(status_code=404, detail="Sesion no encontrada")
    return session_row


@app.put("/api/v1/sessions/{session_id}", response_model=SesionOut, tags=["Sesiones"])
def update_session(
    session_id: str,
    session_in: SesionUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    session_row = db.query(Sesion).filter(Sesion.id_sesion == session_id).first()
    if not session_row:
        raise HTTPException(status_code=404, detail="Sesion no encontrada")
    payload = model_dump(session_in, exclude_unset=True)
    for required in ("id_bloque", "nombre", "aula", "edificio", "planta"):
        if required in payload and not str(payload[required] or "").strip():
            raise HTTPException(status_code=422, detail=f"{required} no puede estar vacio")
    if "id_bloque" in payload and not db.query(Bloque).filter(Bloque.id_bloque == payload["id_bloque"]).first():
        raise HTTPException(status_code=404, detail="Bloque no encontrado")
    hora_inicio = payload.get("hora_inicio", session_row.hora_inicio)
    hora_fin = payload.get("hora_fin", session_row.hora_fin)
    if hora_inicio and hora_fin and hora_fin <= hora_inicio:
        raise HTTPException(status_code=422, detail="La hora de fin debe ser posterior a la hora de inicio")
    for key, value in payload.items():
        setattr(session_row, key, value)
    related_events = db.query(Evento).filter(Evento.id_sesion == session_id).all()
    for event in related_events:
        if "nombre" in payload:
            event.titulo = session_row.nombre
        if "id_bloque" in payload:
            event.id_bloque = session_row.id_bloque
        if "aula" in payload:
            event.aula = session_row.aula
        if session_row.fecha and session_row.hora_inicio and ("fecha" in payload or "hora_inicio" in payload):
            event.fecha_inicio = datetime.combine(session_row.fecha, session_row.hora_inicio)
        if session_row.fecha and session_row.hora_fin and ("fecha" in payload or "hora_fin" in payload):
            event.fecha_fin = datetime.combine(session_row.fecha, session_row.hora_fin)
    db.commit()
    invalidate_calendar_cache()
    db.refresh(session_row)
    return session_row


@app.delete("/api/v1/sessions/{session_id}", status_code=204, tags=["Sesiones"])
def delete_session(
    session_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    session_row = db.query(Sesion).filter(Sesion.id_sesion == session_id).first()
    if not session_row:
        raise HTTPException(status_code=404, detail="Sesion no encontrada")
    db.delete(session_row)
    db.commit()
    return


@app.get("/api/v1/sessions/{session_id}/students", response_model=List[AlumnoOut], tags=["Sesiones"])
def list_session_students(
    session_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    session_row = db.query(Sesion).filter(Sesion.id_sesion == session_id).first()
    if not session_row:
        raise HTTPException(status_code=404, detail="Sesion no encontrada")
    students = (
        db.query(Alumno)
        .join(RelAlumnosGrupos, RelAlumnosGrupos.id_alumno == Alumno.id_alumno)
        .join(RelBloquesGrupos, RelBloquesGrupos.id_grupo == RelAlumnosGrupos.id_grupo)
        .filter(RelBloquesGrupos.id_bloque == session_row.id_bloque)
        .distinct()
        .order_by(Alumno.nombre, Alumno.apellido1)
        .all()
    )
    return [
        AlumnoOut(
            id_alumno=student.id_alumno,
            nombre=student.nombre,
            apellido=student.apellido1,
            correo=student.correo,
        )
        for student in students
    ]


@app.get("/api/v1/blocks/{block_id}/tasks", response_model=List[TaskOut], tags=["Notas"])
def list_block_tasks(
    block_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    block = db.query(Bloque).filter(Bloque.id_bloque == block_id).first()
    if not block:
        raise HTTPException(status_code=404, detail="Bloque no encontrado")
    assert_professor_teaches_block(db, current_user, block_id)
    return (
        db.query(Tarea)
        .filter(Tarea.id_bloque == block_id)
        .order_by(Tarea.fecha, Tarea.id_tarea)
        .all()
    )


@app.get("/api/v1/grades/me", response_model=List[GradeOut], tags=["Notas"])
def list_my_grades(
    db: Session = Depends(get_db),
    current_user=Depends(require_student),
):
    return build_my_grades(db, current_user)


@app.get("/api/v1/grades/me/blocks/{block_id}", response_model=List[GradeOut], tags=["Notas"])
def list_my_grades_for_block(
    block_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(require_student),
):
    tasks = (
        db.query(Tarea)
        .filter(Tarea.id_bloque == block_id)
        .order_by(Tarea.fecha, Tarea.id_tarea)
        .all()
    )
    grade_map = {
        grade.id_tarea: grade.nota
        for grade in db.query(RelAlumnoTarea)
        .filter(RelAlumnoTarea.id_alumno == current_user.id_alumno)
        .all()
    }
    grades = [
        build_grade_out(task, grade_map.get(task.id_tarea))
        for task in tasks
        if is_visible_grade_task(task)
    ]
    if block_id == "ACTITUD":
        grades.append(attendance_grade_for_user(db, current_user.id_alumno))
        grades.append(attitude_grade_for_student(current_user.id_alumno))
    return grades


@app.get("/api/v1/grades/tasks/{task_id}", response_model=List[GradeRosterRow], tags=["Notas"])
def list_task_grades(
    task_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    task = db.query(Tarea).filter(Tarea.id_tarea == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    assert_professor_teaches_block(db, current_user, task.id_bloque)

    students = (
        db.query(Alumno)
        .join(RelAlumnosGrupos, RelAlumnosGrupos.id_alumno == Alumno.id_alumno)
        .join(RelBloquesGrupos, RelBloquesGrupos.id_grupo == RelAlumnosGrupos.id_grupo)
        .filter(RelBloquesGrupos.id_bloque == task.id_bloque)
        .distinct()
        .order_by(Alumno.nombre, Alumno.apellido1)
        .all()
    )
    grades = {
        grade.id_alumno: grade.nota
        for grade in db.query(RelAlumnoTarea).filter(RelAlumnoTarea.id_tarea == task_id).all()
    }
    return [
        GradeRosterRow(
            id_alumno=student.id_alumno,
            nombre=student.nombre,
            apellido=student.apellido1,
            id_tarea=task.id_tarea,
            nombre_tarea=task.nombre,
            id_bloque=task.id_bloque,
            nota=grades.get(student.id_alumno),
        )
        for student in students
    ]


@app.post("/api/v1/grades", tags=["Notas"], status_code=201)
def create_grade(
    grade_in: GradeCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    if grade_in.nota < 0 or grade_in.nota > 10:
        raise HTTPException(status_code=422, detail="La nota debe estar entre 0 y 10")
    if not db.query(Alumno).filter(Alumno.id_alumno == grade_in.id_alumno).first():
        raise HTTPException(status_code=404, detail="Alumno no encontrado")
    task = db.query(Tarea).filter(Tarea.id_tarea == grade_in.id_tarea).first()
    if not task:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    assert_professor_teaches_block(db, current_user, task.id_bloque)
    grade = db.query(RelAlumnoTarea).filter(
        RelAlumnoTarea.id_alumno == grade_in.id_alumno,
        RelAlumnoTarea.id_tarea == grade_in.id_tarea,
    ).first()
    task = db.query(Tarea).filter(Tarea.id_tarea == tarea_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    assert_professor_teaches_block(db, current_user, task.id_bloque)
    if grade:
        grade.nota = grade_in.nota
    else:
        grade = RelAlumnoTarea(
            id_alumno=grade_in.id_alumno,
            id_tarea=grade_in.id_tarea,
            nota=grade_in.nota,
        )
        db.add(grade)
    db.commit()
    return {"mensaje": "Nota guardada correctamente"}


@app.put("/api/v1/grades/{tarea_id}", tags=["Notas"])
def update_grade(
    tarea_id: int,
    grade_in: GradeUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    if grade_in.nota < 0 or grade_in.nota > 10:
        raise HTTPException(status_code=422, detail="La nota debe estar entre 0 y 10")
    grade = db.query(RelAlumnoTarea).filter(
        RelAlumnoTarea.id_alumno == grade_in.id_alumno,
        RelAlumnoTarea.id_tarea == tarea_id,
    ).first()
    if not grade:
        raise HTTPException(status_code=404, detail="Nota no encontrada")
    grade.nota = grade_in.nota
    db.commit()
    return {"mensaje": "Nota actualizada correctamente"}


@app.get("/api/v1/attendance/me", response_model=List[AttendanceOut], tags=["Asistencia"])
def list_my_attendance(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    return (
        db.query(Asistencia)
        .filter(Asistencia.id_alumno == user_id)
        .order_by(Asistencia.fecha)
        .all()
    )


@app.get("/api/v1/attendance/me/metrics", response_model=AttendanceMetricsOut, tags=["Asistencia"])
def get_my_attendance_metrics(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    metrics = build_attendance_metrics(db, user_id)
    if metrics.aviso:
        existing = db.query(Notificacion).filter(
            Notificacion.id_usuario == user_id,
            Notificacion.tipo == "attendance",
            Notificacion.titulo == "Aviso de asistencia",
            Notificacion.leida == False,  # noqa: E712
        ).first()
        if not existing:
            db.add(Notificacion(
                id=str(uuid.uuid4()),
                id_usuario=user_id,
                tipo="attendance",
                titulo="Aviso de asistencia",
                mensaje=metrics.aviso,
            ))
            db.commit()
    return metrics


@app.post("/api/v1/attendance", response_model=AttendanceOut, tags=["Asistencia"], status_code=201)
def upsert_attendance(
    attendance_in: AttendanceCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_staff),
):
    if not db.query(Alumno).filter(Alumno.id_alumno == attendance_in.id_alumno).first():
        raise HTTPException(status_code=404, detail="Alumno no encontrado")
    session_row = db.query(Sesion).filter(Sesion.id_sesion == attendance_in.id_sesion).first()
    if not session_row:
        raise HTTPException(status_code=404, detail="Sesion no encontrada")

    attendance_date = attendance_in.fecha or session_row.fecha or date.today()
    record = db.query(Asistencia).filter(
        Asistencia.id_alumno == attendance_in.id_alumno,
        Asistencia.id_sesion == attendance_in.id_sesion,
    ).first()
    if record:
        record.fecha = attendance_date
        record.presente = attendance_in.presente
    else:
        record = Asistencia(
            id_alumno=attendance_in.id_alumno,
            id_sesion=attendance_in.id_sesion,
            fecha=attendance_date,
            presente=attendance_in.presente,
        )
        db.add(record)
    db.commit()
    db.refresh(record)
    return record


@app.post("/api/v1/attendance/me/check-in", response_model=AttendanceOut, tags=["Asistencia"], status_code=201)
def student_check_in(
    attendance_in: StudentAttendanceCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    session_row = db.query(Sesion).filter(Sesion.id_sesion == attendance_in.id_sesion).first()
    if not session_row:
        raise HTTPException(status_code=404, detail="Sesion no encontrada")

    if not is_mandatory_attendance_session(session_row):
        raise HTTPException(status_code=403, detail="Esta sesion no computa para asistencia")

    role = get_user_role(current_user)
    user_id = get_user_id(current_user)
    if role == "alumno":
        belongs_to_session_block = (
            db.query(RelAlumnosGrupos)
            .join(RelBloquesGrupos, RelBloquesGrupos.id_grupo == RelAlumnosGrupos.id_grupo)
            .filter(
                RelAlumnosGrupos.id_alumno == user_id,
                RelBloquesGrupos.id_bloque == session_row.id_bloque,
            )
            .first()
        )
    elif role == "profesor":
        belongs_to_session_block = session_row.id_profesor == user_id
    else:
        belongs_to_session_block = db.query(RelCoordinadoresGrupos).first()

    if not belongs_to_session_block:
        raise HTTPException(status_code=403, detail="No puedes registrar asistencia en esta sesion")

    attendance_date = session_row.fecha or date.today()
    record = db.query(Asistencia).filter(
        Asistencia.id_alumno == user_id,
        Asistencia.id_sesion == session_row.id_sesion,
    ).first()
    if record:
        record.fecha = attendance_date
        record.presente = True
    else:
        record = Asistencia(
            id_alumno=user_id,
            id_sesion=session_row.id_sesion,
            fecha=attendance_date,
            presente=True,
        )
        db.add(record)
    db.commit()
    db.refresh(record)
    return record


@app.get("/api/v1/attendance/sessions/{session_id}", response_model=List[AttendanceOut], tags=["Asistencia"])
def list_session_attendance(
    session_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return (
        db.query(Asistencia)
        .filter(Asistencia.id_sesion == session_id)
        .order_by(Asistencia.id_alumno)
        .all()
    )


@app.get("/api/v1/attendance/sessions/{session_id}/roster", response_model=List[AttendanceRosterRow], tags=["Asistencia"])
def list_session_attendance_roster(
    session_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(require_staff),
):
    session_row = db.query(Sesion).filter(Sesion.id_sesion == session_id).first()
    if not session_row:
        raise HTTPException(status_code=404, detail="Sesion no encontrada")

    students = (
        db.query(Alumno)
        .join(RelAlumnosGrupos, RelAlumnosGrupos.id_alumno == Alumno.id_alumno)
        .join(RelBloquesGrupos, RelBloquesGrupos.id_grupo == RelAlumnosGrupos.id_grupo)
        .filter(RelBloquesGrupos.id_bloque == session_row.id_bloque)
        .distinct()
        .order_by(Alumno.nombre, Alumno.apellido1)
        .all()
    )
    attendance_records = {
        record.id_alumno: record
        for record in db.query(Asistencia).filter(Asistencia.id_sesion == session_id).all()
    }
    return [
        AttendanceRosterRow(
            id_alumno=student.id_alumno,
            nombre=student.nombre,
            apellido=student.apellido1,
            id_sesion=session_id,
            fecha=attendance_records[student.id_alumno].fecha if student.id_alumno in attendance_records else session_row.fecha,
            presente=attendance_records[student.id_alumno].presente if student.id_alumno in attendance_records else None,
            id_asistencia=attendance_records[student.id_alumno].id_asistencia if student.id_alumno in attendance_records else None,
        )
        for student in students
    ]


@app.get("/api/v1/tutorings/slots", response_model=List[TutoringSlotOut], tags=["Reservas y Tutorias"])
def list_tutoring_slots(
    id_profesor: Optional[str] = None,
    id_bloque: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    query = db.query(FranjaTutoria)
    role = get_user_role(current_user)
    if role == "profesor":
        query = query.filter(FranjaTutoria.id_profesor == current_user.id_profesor)
    if id_profesor:
        query = query.filter(FranjaTutoria.id_profesor == id_profesor)
    if id_bloque:
        query = query.filter(FranjaTutoria.id_bloque == id_bloque)
    return query.order_by(FranjaTutoria.dia_semana, FranjaTutoria.hora_inicio).all()


@app.post("/api/v1/tutorings/slots", response_model=TutoringSlotOut, tags=["Reservas y Tutorias"], status_code=201)
def create_tutoring_slot(
    slot_in: TutoringSlotCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    role = get_user_role(current_user)
    professor_id = slot_in.id_profesor or getattr(current_user, "id_profesor", None)
    if role == "profesor":
        professor_id = current_user.id_profesor
    if not professor_id:
        raise HTTPException(status_code=422, detail="id_profesor es obligatorio")
    if not db.query(Profesor).filter(Profesor.id_profesor == professor_id).first():
        raise HTTPException(status_code=404, detail="Profesor no encontrado")
    slot = FranjaTutoria(
        id=str(uuid.uuid4()),
        id_profesor=professor_id,
        id_bloque=slot_in.id_bloque,
        dia_semana=slot_in.dia_semana,
        hora_inicio=slot_in.hora_inicio,
        hora_fin=slot_in.hora_fin,
        ubicacion=slot_in.ubicacion,
        disponible=slot_in.disponible,
    )
    db.add(slot)
    db.commit()
    db.refresh(slot)
    return slot


@app.get("/api/v1/reservations", response_model=List[ReservationOut], tags=["Reservas y Tutorias"])
def list_my_reservations(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    query = db.query(Reserva)
    role = get_user_role(current_user)
    if role == "alumno":
        query = query.filter(Reserva.id_alumno == user_id)
    elif role == "profesor":
        query = query.filter(Reserva.id_profesor == user_id)
    return query.order_by(Reserva.fecha.desc(), Reserva.fecha_creacion.desc()).all()


@app.post("/api/v1/reservations", response_model=ReservationOut, tags=["Reservas y Tutorias"], status_code=201)
def create_reservation(
    reservation_in: ReservationCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_student),
):
    slot = db.query(FranjaTutoria).filter(FranjaTutoria.id == reservation_in.id_franja).first()
    if not slot:
        raise HTTPException(status_code=404, detail="Franja no encontrada")
    if not slot.disponible:
        raise HTTPException(status_code=422, detail="Franja no disponible")
    if slot.id_profesor != reservation_in.id_profesor:
        raise HTTPException(status_code=422, detail="La franja no pertenece al profesor seleccionado")
    if reservation_in.fecha.weekday() != slot.dia_semana:
        raise HTTPException(status_code=422, detail="La fecha no coincide con el dia disponible")
    existing = db.query(Reserva).filter(
        Reserva.id_franja == reservation_in.id_franja,
        Reserva.fecha == reservation_in.fecha,
        Reserva.estado.in_(["pending", "approved", "alternative"]),
    ).first()
    if existing:
        raise HTTPException(status_code=409, detail="Esa franja ya tiene una solicitud activa")
    reservation = Reserva(
        id=str(uuid.uuid4()),
        id_alumno=current_user.id_alumno,
        id_profesor=reservation_in.id_profesor,
        id_franja=reservation_in.id_franja,
        fecha=reservation_in.fecha,
        notas=reservation_in.notas,
        estado="pending",
    )
    db.add(reservation)
    db.commit()
    db.refresh(reservation)
    return reservation


@app.put("/api/v1/reservations/{reservation_id}", response_model=ReservationOut, tags=["Reservas y Tutorias"])
def update_reservation(
    reservation_id: str,
    reservation_in: ReservationUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    reservation = db.query(Reserva).filter(Reserva.id == reservation_id).first()
    if not reservation:
        raise HTTPException(status_code=404, detail="Reserva no encontrada")
    role = get_user_role(current_user)
    user_id = get_user_id(current_user)
    allowed_states = {"pending", "approved", "rejected", "alternative", "cancelled"}
    if reservation_in.estado not in allowed_states:
        raise HTTPException(status_code=422, detail="Estado no permitido")
    if role == "profesor" and reservation.id_profesor != user_id:
        raise HTTPException(status_code=403, detail="No puedes gestionar esta tutoria")
    if role == "alumno":
        if reservation.id_alumno != user_id:
            raise HTTPException(status_code=403, detail="No puedes gestionar esta tutoria")
        if reservation_in.estado not in {"approved", "cancelled", "rejected"}:
            raise HTTPException(status_code=403, detail="Estado no permitido para alumno")
        if reservation.estado == "alternative" and reservation_in.estado in {"approved", "rejected"}:
            reservation.estado = reservation_in.estado
        elif reservation.estado == "pending" and reservation_in.estado == "cancelled":
            reservation.estado = "cancelled"
        else:
            raise HTTPException(status_code=422, detail="No se puede aplicar ese cambio")
        db.commit()
        db.refresh(reservation)
        return reservation

    if reservation_in.estado == "alternative":
        if not reservation_in.id_franja or not reservation_in.fecha:
            raise HTTPException(status_code=422, detail="La propuesta alternativa necesita franja y fecha")
        slot = db.query(FranjaTutoria).filter(FranjaTutoria.id == reservation_in.id_franja).first()
        if not slot:
            raise HTTPException(status_code=404, detail="Franja no encontrada")
        if slot.id_profesor != reservation.id_profesor:
            raise HTTPException(status_code=422, detail="La franja no pertenece al profesor de la tutoria")
        if reservation_in.fecha.weekday() != slot.dia_semana:
            raise HTTPException(status_code=422, detail="La fecha no coincide con el dia disponible")
        existing = db.query(Reserva).filter(
            Reserva.id != reservation.id,
            Reserva.id_franja == reservation_in.id_franja,
            Reserva.fecha == reservation_in.fecha,
            Reserva.estado.in_(["pending", "approved", "alternative"]),
        ).first()
        if existing:
            raise HTTPException(status_code=409, detail="Esa franja ya tiene una solicitud activa")
        reservation.id_franja = reservation_in.id_franja
        reservation.fecha = reservation_in.fecha
    reservation.estado = reservation_in.estado
    if reservation_in.notas is not None:
        reservation.notas = reservation_in.notas
    db.commit()
    db.refresh(reservation)
    return reservation


@app.post("/api/v1/tutoring-requests", response_model=SolicitudTutoriaOut, tags=["Solicitudes de Tutoría"], status_code=201)
def create_tutoring_request(
    request_in: SolicitudTutoriaCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    new_id = generate_id()
    solicitud = SolicitudTutoria(
        id=new_id,
        id_alumno=user_id,
        id_profesor=request_in.id_profesor,
        motivo=request_in.motivo,
        estado="Pendiente",
        opcion1_fecha_hora=request_in.opcion1_fecha_hora,
        opcion2_fecha_hora=request_in.opcion2_fecha_hora,
        opcion3_fecha_hora=request_in.opcion3_fecha_hora,
        comentario_alumno=request_in.comentario_alumno,
    )
    db.add(solicitud)
    db.commit()
    db.refresh(solicitud)
    return solicitud


@app.get("/api/v1/tutoring-requests/me", response_model=List[SolicitudTutoriaOut], tags=["Solicitudes de Tutoría"])
def list_my_tutoring_requests(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    return db.query(SolicitudTutoria).filter(SolicitudTutoria.id_alumno == user_id).order_by(SolicitudTutoria.fecha_creacion.desc()).all()


@app.get("/api/v1/tutoring-requests/received", response_model=List[SolicitudTutoriaOut], tags=["Solicitudes de Tutoría"])
def list_received_tutoring_requests(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    return db.query(SolicitudTutoria).filter(SolicitudTutoria.id_profesor == user_id).order_by(SolicitudTutoria.fecha_creacion.desc()).all()


@app.post("/api/v1/tutoring-requests/{request_id}/accept/{option}", response_model=SolicitudTutoriaOut, tags=["Solicitudes de Tutoría"])
def accept_tutoring_request(
    request_id: str,
    option: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    solicitud = db.query(SolicitudTutoria).filter(SolicitudTutoria.id == request_id).first()
    if not solicitud:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")
    if solicitud.id_profesor != get_user_id(current_user):
        raise HTTPException(status_code=403, detail="No puedes aceptar esta solicitud")
    if solicitud.estado != "Pendiente":
        raise HTTPException(status_code=422, detail="La solicitud no está pendiente")
    if option == 1:
        solicitud.fecha_hora_confirmada = solicitud.opcion1_fecha_hora
    elif option == 2:
        solicitud.fecha_hora_confirmada = solicitud.opcion2_fecha_hora
    elif option == 3:
        if not solicitud.opcion3_fecha_hora:
            raise HTTPException(status_code=422, detail="No existe opción 3")
        solicitud.fecha_hora_confirmada = solicitud.opcion3_fecha_hora
    else:
        raise HTTPException(status_code=422, detail="Opción no válida")
    solicitud.estado = "Aceptada"
    db.commit()
    db.refresh(solicitud)
    return solicitud


@app.post("/api/v1/tutoring-requests/{request_id}/reject", response_model=SolicitudTutoriaOut, tags=["Solicitudes de Tutoría"])
def reject_tutoring_request(
    request_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    solicitud = db.query(SolicitudTutoria).filter(SolicitudTutoria.id == request_id).first()
    if not solicitud:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")
    if solicitud.id_profesor != get_user_id(current_user):
        raise HTTPException(status_code=403, detail="No puedes rechazar esta solicitud")
    if solicitud.estado != "Pendiente":
        raise HTTPException(status_code=422, detail="La solicitud no está pendiente")
    solicitud.estado = "Rechazada"
    db.commit()
    db.refresh(solicitud)
    return solicitud


@app.post("/api/v1/tutoring-requests/{request_id}/propose-alternative", response_model=SolicitudTutoriaOut, tags=["Solicitudes de Tutoría"])
def propose_alternative_tutoring(
    request_id: str,
    propuesta: datetime,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    solicitud = db.query(SolicitudTutoria).filter(SolicitudTutoria.id == request_id).first()
    if not solicitud:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")
    if solicitud.id_profesor != get_user_id(current_user):
        raise HTTPException(status_code=403, detail="No puedes proponer alternativa en esta solicitud")
    if solicitud.estado != "Pendiente":
        raise HTTPException(status_code=422, detail="La solicitud no está pendiente")
    solicitud.propuesta_alternativa_fecha_hora = propuesta
    solicitud.estado = "Propuesta alternativa"
    db.commit()
    db.refresh(solicitud)
    return solicitud


@app.post("/api/v1/tutoring-requests/{request_id}/accept-alternative", response_model=SolicitudTutoriaOut, tags=["Solicitudes de Tutoría"])
def accept_alternative_tutoring(
    request_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    solicitud = db.query(SolicitudTutoria).filter(SolicitudTutoria.id == request_id).first()
    if not solicitud:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")
    if solicitud.id_alumno != get_user_id(current_user):
        raise HTTPException(status_code=403, detail="No puedes aceptar esta propuesta")
    if solicitud.estado != "Propuesta alternativa":
        raise HTTPException(status_code=422, detail="No hay propuesta alternativa pendiente")
    solicitud.fecha_hora_confirmada = solicitud.propuesta_alternativa_fecha_hora
    solicitud.estado = "Aceptada"
    db.commit()
    db.refresh(solicitud)
    return solicitud


@app.post("/api/v1/tutoring-requests/{request_id}/reject-alternative", response_model=SolicitudTutoriaOut, tags=["Solicitudes de Tutoría"])
def reject_alternative_tutoring(
    request_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    solicitud = db.query(SolicitudTutoria).filter(SolicitudTutoria.id == request_id).first()
    if not solicitud:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")
    if solicitud.id_alumno != get_user_id(current_user):
        raise HTTPException(status_code=403, detail="No puedes rechazar esta propuesta")
    if solicitud.estado != "Propuesta alternativa":
        raise HTTPException(status_code=422, detail="No hay propuesta alternativa pendiente")
    solicitud.estado = "Rechazada"
    db.commit()
    db.refresh(solicitud)
    return solicitud


@app.post("/api/v1/tutoring-requests/{request_id}/cancel", response_model=SolicitudTutoriaOut, tags=["Solicitudes de Tutoría"])
def cancel_tutoring_request(
    request_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    solicitud = db.query(SolicitudTutoria).filter(SolicitudTutoria.id == request_id).first()
    if not solicitud:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")
    if solicitud.id_alumno != get_user_id(current_user):
        raise HTTPException(status_code=403, detail="No puedes cancelar esta solicitud")
    if solicitud.estado != "Pendiente":
        raise HTTPException(status_code=422, detail="Solo se pueden cancelar solicitudes pendientes")
    solicitud.estado = "Cancelada"
    db.commit()
    db.refresh(solicitud)
    return solicitud


@app.get("/api/v1/notifications", response_model=List[NotificationOut], tags=["Notificaciones"])
def list_my_notifications(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return (
        db.query(Notificacion)
        .filter(Notificacion.id_usuario == get_user_id(current_user))
        .order_by(Notificacion.fecha_creacion.desc())
        .all()
    )


@app.put("/api/v1/notifications/{notis_id}/read", response_model=NotificationOut, tags=["Notificaciones"])
def mark_notification_read(
    notis_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    notification = db.query(Notificacion).filter(
        Notificacion.id == notis_id,
        Notificacion.id_usuario == get_user_id(current_user),
    ).first()
    if not notification:
        raise HTTPException(status_code=404, detail="Notificacion no encontrada")
    notification.leida = True
    db.commit()
    db.refresh(notification)
    return notification


@app.get("/api/v1/notifications/settings", response_model=NotificationSettingsOut, tags=["Notificaciones"])
def get_notification_settings(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return ensure_notification_settings(db, get_user_id(current_user))


@app.get("/api/v1/emails", response_model=List[EmailOut], tags=["Correos"])
def list_my_emails(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    return (
        db.query(Correo)
        .filter(or_(Correo.id_remitente == user_id, Correo.id_destinatario == user_id))
        .order_by(Correo.fecha_envio.desc())
        .all()
    )


@app.post("/api/v1/emails", response_model=EmailOut, tags=["Correos"], status_code=201)
def create_email(
    email_in: EmailCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if not find_user_by_id(db, email_in.id_destinatario):
        raise HTTPException(status_code=404, detail="Destinatario no encontrado")
    email = Correo(
        id=str(uuid.uuid4()),
        id_remitente=get_user_id(current_user),
        id_destinatario=email_in.id_destinatario,
        asunto=email_in.asunto,
        cuerpo=email_in.cuerpo,
    )
    db.add(email)
    db.commit()
    db.refresh(email)
    return email


@app.get("/api/v1/emails/{email_id}", response_model=EmailOut, tags=["Correos"])
def get_email(
    email_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    email = db.query(Correo).filter(
        Correo.id == email_id,
        or_(Correo.id_remitente == user_id, Correo.id_destinatario == user_id),
    ).first()
    if not email:
        raise HTTPException(status_code=404, detail="Correo no encontrado")
    if email.id_destinatario == user_id and not email.leido:
        email.leido = True
        db.commit()
        db.refresh(email)
    return email


@app.get("/api/v1/locations", response_model=List[UbicacionOut], tags=["Ubicaciones"])
def list_locations(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return db.query(Ubicacion).order_by(Ubicacion.descripcion).all()


@app.post("/api/v1/locations", response_model=UbicacionOut, tags=["Ubicaciones"], status_code=201)
def create_location(
    location_in: UbicacionCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_staff),
):
    location = Ubicacion(id_ubicacion=str(uuid.uuid4()), **model_dump(location_in))
    db.add(location)
    db.commit()
    db.refresh(location)
    return location


@app.get("/api/v1/locations/{location_id}", response_model=UbicacionOut, tags=["Ubicaciones"])
def get_location(
    location_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    location = db.query(Ubicacion).filter(Ubicacion.id_ubicacion == location_id).first()
    if not location:
        raise HTTPException(status_code=404, detail="Ubicacion no encontrada")
    return location


@app.get("/api/v1/groups", response_model=List[GrupoOut], tags=["Grupos"])
def list_groups(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return db.query(Grupo).order_by(Grupo.nombre).all()


@app.get("/api/v1/groups/me", response_model=List[GrupoOut], tags=["Grupos"])
def list_my_groups(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    role = get_user_role(current_user)
    if role == "alumno":
        return (
            db.query(Grupo)
            .join(RelAlumnosGrupos, RelAlumnosGrupos.id_grupo == Grupo.id_grupo)
            .filter(RelAlumnosGrupos.id_alumno == current_user.id_alumno)
            .order_by(Grupo.nombre)
            .all()
        )
    if role == "profesor":
        return (
            db.query(Grupo)
            .join(RelBloquesGrupos, RelBloquesGrupos.id_grupo == Grupo.id_grupo)
            .join(RelProfesoresBloques, RelProfesoresBloques.id_bloque == RelBloquesGrupos.id_bloque)
            .filter(RelProfesoresBloques.id_profesor == current_user.id_profesor)
            .distinct()
            .order_by(Grupo.nombre)
            .all()
        )
    return (
        db.query(Grupo)
        .join(RelCoordinadoresGrupos, RelCoordinadoresGrupos.id_grupo == Grupo.id_grupo)
        .filter(RelCoordinadoresGrupos.id_coordinador == current_user.id_coordinador)
        .order_by(Grupo.nombre)
        .all()
    )


@app.get("/api/v1/groups/{group_id}/students", response_model=List[AlumnoOut], tags=["Grupos"])
def list_group_students(
    group_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    students = (
        db.query(Alumno)
        .join(RelAlumnosGrupos, RelAlumnosGrupos.id_alumno == Alumno.id_alumno)
        .filter(RelAlumnosGrupos.id_grupo == group_id)
        .order_by(Alumno.nombre, Alumno.apellido1)
        .all()
    )
    return [
        AlumnoOut(
            id_alumno=student.id_alumno,
            nombre=student.nombre,
            apellido=student.apellido1,
            correo=student.correo,
        )
        for student in students
    ]


@app.get("/api/v1/groups/{group_id}/blocks", response_model=List[BloqueOut], tags=["Grupos"])
def list_group_blocks(
    group_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return (
        db.query(Bloque)
        .join(RelBloquesGrupos, RelBloquesGrupos.id_bloque == Bloque.id_bloque)
        .filter(RelBloquesGrupos.id_grupo == group_id)
        .order_by(Bloque.nombre)
        .all()
    )


@app.get("/api/v1/blocks/{block_id}/content", response_model=List[ContentOut], tags=["Contenido"])
def list_block_content(
    block_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    role = get_user_role(current_user)
    if role == "profesor":
        assert_professor_teaches_block(db, current_user, block_id)
    return (
        db.query(Contenido)
        .filter(Contenido.id_bloque == block_id)
        .order_by(Contenido.fecha_subida.desc())
        .all()
    )


@app.post("/api/v1/blocks/{block_id}/content", response_model=ContentOut, tags=["Contenido"], status_code=201)
def create_block_content(
    block_id: str,
    content_in: ContentCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    if not db.query(Bloque).filter(Bloque.id_bloque == block_id).first():
        raise HTTPException(status_code=404, detail="Bloque no encontrado")
    professor_id = getattr(current_user, "id_profesor", None)
    if not professor_id:
        teacher_link = db.query(RelProfesoresBloques).filter(
            RelProfesoresBloques.id_bloque == block_id
        ).first()
        if not teacher_link:
            raise HTTPException(status_code=400, detail="El bloque no tiene profesor asignado")
        professor_id = teacher_link.id_profesor
    else:
        assert_professor_teaches_block(db, current_user, block_id)
    content = Contenido(
        id=str(uuid.uuid4()),
        id_bloque=block_id,
        id_profesor=professor_id,
        **model_dump(content_in),
    )
    db.add(content)
    db.commit()
    db.refresh(content)
    return content


@app.post("/api/v1/blocks/{block_id}/content/file", response_model=ContentOut, tags=["Contenido"], status_code=201)
def upload_block_content_file(
    block_id: str,
    titulo: str = Form(...),
    descripcion: Optional[str] = Form(None),
    tipo: str = Form("documento"),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    if not db.query(Bloque).filter(Bloque.id_bloque == block_id).first():
        raise HTTPException(status_code=404, detail="Bloque no encontrado")
    if not titulo.strip():
        raise HTTPException(status_code=422, detail="El titulo es obligatorio")

    professor_id = getattr(current_user, "id_profesor", None)
    if professor_id:
        assert_professor_teaches_block(db, current_user, block_id)
    else:
        teacher_link = db.query(RelProfesoresBloques).filter(
            RelProfesoresBloques.id_bloque == block_id
        ).first()
        if not teacher_link:
            raise HTTPException(status_code=400, detail="El bloque no tiene profesor asignado")
        professor_id = teacher_link.id_profesor

    ext = validate_upload(
        file,
        {"pdf", "doc", "docx", "ppt", "pptx", "xls", "xlsx", "txt", "zip"},
        {
            "application/pdf",
            "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "application/vnd.ms-powerpoint",
            "application/vnd.openxmlformats-officedocument.presentationml.presentation",
            "application/vnd.ms-excel",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "text/plain",
            "application/zip",
            "application/x-zip-compressed",
        },
        20,
    )
    url = store_upload(
        get_user_id(current_user),
        file,
        f"content/{safe_upload_user_id(block_id)}",
        uuid.uuid4().hex,
        ext,
    )
    content = Contenido(
        id=str(uuid.uuid4()),
        id_bloque=block_id,
        id_profesor=professor_id,
        titulo=titulo.strip(),
        descripcion=descripcion.strip() if descripcion else None,
        tipo=tipo or "documento",
        url=url,
    )
    db.add(content)
    db.commit()
    db.refresh(content)
    return content


@app.delete("/api/v1/content/{content_id}", status_code=204, tags=["Contenido"])
def delete_content(
    content_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    content = db.query(Contenido).filter(Contenido.id == content_id).first()
    if not content:
        raise HTTPException(status_code=404, detail="Contenido no encontrado")
    if get_user_role(current_user) == "profesor" and content.id_profesor != current_user.id_profesor:
        raise HTTPException(status_code=403, detail="No puedes eliminar contenido de otro profesor")
    db.delete(content)
    db.commit()
    return
