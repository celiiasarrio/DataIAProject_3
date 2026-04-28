import base64
from datetime import date, datetime, time, timedelta
import hashlib
import hmac
import json
import uuid
from typing import List, Optional

try:
    import bcrypt as bcrypt_lib
except ModuleNotFoundError:  # pragma: no cover - fallback for thin local envs
    bcrypt_lib = None
from fastapi import Depends, FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
try:
    from jose import JWTError, jwt
except ModuleNotFoundError:  # pragma: no cover - fallback for thin local envs
    class JWTError(Exception):
        pass

    jwt = None
from pydantic import BaseModel, ConfigDict
from sqlalchemy import create_engine, or_
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import NullPool
from pydantic import BaseModel
from typing import Optional
from jose import JWTError, jwt
import bcrypt as bcrypt_lib
import uuid
from datetime import datetime, date, timedelta
from typing import List

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
    PersonalEdem,
    Profesor,
    RelAlumnoTarea,
    RelAlumnosGrupos,
    RelBloquesGrupos,
    RelPersonalGrupos,
    RelProfesoresBloques,
    Reserva,
    Sesion,
    Tarea,
    Ubicacion,
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
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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


class SesionCreate(BaseModel):
    id_sesion: Optional[str] = None
    id_bloque: Optional[str] = None
    nombre: str
    fecha: Optional[date] = None
    hora_inicio: Optional[time] = None
    hora_fin: Optional[time] = None
    aula: Optional[str] = None


class SesionUpdate(BaseModel):
    id_bloque: Optional[str] = None
    nombre: Optional[str] = None
    fecha: Optional[date] = None
    hora_inicio: Optional[time] = None
    hora_fin: Optional[time] = None
    aula: Optional[str] = None


class SesionOut(ORMModel):
    id_sesion: str
    id_bloque: str
    nombre: str
    fecha: Optional[date] = None
    hora_inicio: Optional[time] = None
    hora_fin: Optional[time] = None
    aula: Optional[str] = None


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
    id_sesion: Optional[str] = None
    aula: Optional[str] = None
    id_profesor: Optional[str] = None
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
    nota: float


class AttendanceCreate(BaseModel):
    id_alumno: str
    id_sesion: str
    fecha: Optional[date] = None
    presente: bool


class AttendanceOut(ORMModel):
    id_asistencia: int
    id_alumno: str
    id_sesion: str
    fecha: Optional[date] = None
    presente: bool


class AttendanceMetricsOut(BaseModel):
    total_clases: int
    clases_asistidas: int
    porcentaje_asistencia: float


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


class ReservationOut(ORMModel):
    id: str
    id_alumno: str
    id_profesor: str
    id_franja: str
    fecha: date
    notas: Optional[str] = None
    estado: str
    fecha_creacion: datetime


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
        or getattr(user, "id_personal", None)
    )


def get_user_role(user) -> str:
    if getattr(user, "id_alumno", None):
        return "alumno"
    if getattr(user, "id_profesor", None):
        return "profesor"
    if getattr(user, "id_personal", None):
        return "personal"
    return "desconocido"


def get_user_last_name(user) -> str:
    if getattr(user, "id_alumno", None):
        return user.apellido
    return user.apellido


def serialize_profile(user) -> UserProfileOut:
    return UserProfileOut(
        id=get_user_id(user),
        nombre=user.nombre,
        apellido=get_user_last_name(user),
        correo=user.correo,
        rol=get_user_role(user),
        url_foto=user.url_foto,
    )


def find_user_by_id(db: Session, user_id: str):
    user = db.query(Alumno).filter(Alumno.id_alumno == user_id).first()
    if user:
        return user
    user = db.query(Profesor).filter(Profesor.id_profesor == user_id).first()
    if user:
        return user
    return db.query(PersonalEdem).filter(PersonalEdem.id_personal == user_id).first()


def find_user_by_email(db: Session, email: str):
    user = db.query(Alumno).filter(Alumno.correo == email).first()
    if user:
        return user
    user = db.query(Profesor).filter(Profesor.correo == email).first()
    if user:
        return user
    return db.query(PersonalEdem).filter(PersonalEdem.correo == email).first()


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

    access_token = create_access_token(
        data={"sub": get_user_id(user)},
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
    )
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
            current_user.apellido = data["apellido"]
        else:
            current_user.apellido = data["apellido"]
    db.commit()
    db.refresh(current_user)
    return {"mensaje": "Perfil actualizado correctamente"}


GCS_BUCKET = "project3grupo6-photos"

@app.put("/api/v1/users/me/photo", tags=["Perfil y Roles"])
def upload_my_photo(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    from google.cloud import storage as gcs_client
    user_id = get_user_id(current_user)
    ext = (file.filename or "jpg").rsplit(".", 1)[-1].lower()
    blob_name = f"fotos/{user_id}.{ext}"
    client = gcs_client.Client()
    bucket = client.bucket(GCS_BUCKET)
    blob = bucket.blob(blob_name)
    blob.upload_from_file(file.file, content_type=file.content_type)
    public_url = f"https://storage.googleapis.com/{GCS_BUCKET}/{blob_name}"
    current_user.url_foto = public_url
    db.commit()
    db.refresh(current_user)
    return {"mensaje": "Foto subida con éxito", "url_foto": public_url}

@app.delete("/api/v1/users/me/photo", tags=["Perfil y Roles"])
def delete_my_photo(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if current_user.url_foto:
        try:
            from google.cloud import storage as gcs_client
            client = gcs_client.Client()
            bucket = client.bucket(GCS_BUCKET)
            blob_name = current_user.url_foto.split(f"{GCS_BUCKET}/")[-1]
            bucket.blob(blob_name).delete()
        except Exception:
            pass
    current_user.url_foto = None
    db.commit()
    return {"mensaje": "Foto eliminada correctamente"}

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


@app.get("/api/v1/calendar/events", response_model=List[EventOut], tags=["Calendario"])
def list_events(
    tipo: Optional[str] = None,
    id_bloque: Optional[str] = None,
    id_sesion: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    query = db.query(Evento)
    if tipo:
        query = query.filter(Evento.tipo == tipo)
    if id_bloque:
        query = query.filter(Evento.id_bloque == id_bloque)
    if id_sesion:
        query = query.filter(Evento.id_sesion == id_sesion)
    return query.order_by(Evento.fecha_inicio).all()


@app.post("/api/v1/calendar/events", response_model=EventOut, tags=["Calendario"], status_code=201)
def create_event(
    event_in: EventCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    payload = enrich_event_block(db, model_dump(event_in))
    event = Evento(id=str(uuid.uuid4()), **payload)
    db.add(event)
    db.commit()
    db.refresh(event)
    return event


@app.get("/api/v1/calendar/events/{event_id}", response_model=EventOut, tags=["Calendario"])
def get_event(
    event_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    event = db.query(Evento).filter(Evento.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Evento no encontrado")
    return event


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
    payload = enrich_event_block(db, model_dump(event_in, exclude_unset=True))
    for key, value in payload.items():
        setattr(event, key, value)
    db.commit()
    db.refresh(event)
    return event


@app.delete("/api/v1/calendar/events/{event_id}", status_code=204, tags=["Calendario"])
def delete_event(
    event_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    event = db.query(Evento).filter(Evento.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Evento no encontrado")
    db.delete(event)
    db.commit()
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
        .join(RelPersonalGrupos, RelPersonalGrupos.id_grupo == RelBloquesGrupos.id_grupo)
        .filter(RelPersonalGrupos.id_personal == current_user.id_personal)
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
            apellido=student.apellido,
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
        .join(RelPersonalGrupos, RelPersonalGrupos.id_grupo == RelBloquesGrupos.id_grupo)
        .filter(RelPersonalGrupos.id_personal == current_user.id_personal)
        .distinct()
        .order_by(Sesion.fecha, Sesion.hora_inicio)
        .all()
    )


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
    for key, value in model_dump(session_in, exclude_unset=True).items():
        setattr(session_row, key, value)
    db.commit()
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
            apellido=student.apellido,
            correo=student.correo,
        )
        for student in students
    ]


@app.get("/api/v1/grades/me", response_model=List[GradeOut], tags=["Notas"])
def list_my_grades(
    db: Session = Depends(get_db),
    current_user=Depends(require_student),
):
    rows = (
        db.query(RelAlumnoTarea, Tarea)
        .join(Tarea, Tarea.id_tarea == RelAlumnoTarea.id_tarea)
        .filter(RelAlumnoTarea.id_alumno == current_user.id_alumno)
        .all()
    )
    return [
        GradeOut(
            id_tarea=task.id_tarea,
            nombre_tarea=task.nombre,
            id_bloque=task.id_bloque,
            nota=grade.nota,
        )
        for grade, task in rows
    ]


@app.get("/api/v1/grades/me/blocks/{block_id}", response_model=List[GradeOut], tags=["Notas"])
def list_my_grades_for_block(
    block_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(require_student),
):
    rows = (
        db.query(RelAlumnoTarea, Tarea)
        .join(Tarea, Tarea.id_tarea == RelAlumnoTarea.id_tarea)
        .filter(RelAlumnoTarea.id_alumno == current_user.id_alumno, Tarea.id_bloque == block_id)
        .all()
    )
    return [
        GradeOut(
            id_tarea=task.id_tarea,
            nombre_tarea=task.nombre,
            id_bloque=task.id_bloque,
            nota=grade.nota,
        )
        for grade, task in rows
    ]


@app.post("/api/v1/grades", tags=["Notas"], status_code=201)
def create_grade(
    grade_in: GradeCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    if not db.query(Alumno).filter(Alumno.id_alumno == grade_in.id_alumno).first():
        raise HTTPException(status_code=404, detail="Alumno no encontrado")
    task = db.query(Tarea).filter(Tarea.id_tarea == grade_in.id_tarea).first()
    if not task:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    grade = db.query(RelAlumnoTarea).filter(
        RelAlumnoTarea.id_alumno == grade_in.id_alumno,
        RelAlumnoTarea.id_tarea == grade_in.id_tarea,
    ).first()
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
    current_user=Depends(require_student),
):
    return (
        db.query(Asistencia)
        .filter(Asistencia.id_alumno == current_user.id_alumno)
        .order_by(Asistencia.fecha)
        .all()
    )


@app.get("/api/v1/attendance/me/metrics", response_model=AttendanceMetricsOut, tags=["Asistencia"])
def get_my_attendance_metrics(
    db: Session = Depends(get_db),
    current_user=Depends(require_student),
):
    records = db.query(Asistencia).filter(Asistencia.id_alumno == current_user.id_alumno).all()
    total = len(records)
    attended = sum(1 for record in records if record.presente)
    percentage = round((attended / total) * 100, 2) if total else 0.0
    return AttendanceMetricsOut(
        total_clases=total,
        clases_asistidas=attended,
        porcentaje_asistencia=percentage,
    )


@app.post("/api/v1/attendance", response_model=AttendanceOut, tags=["Asistencia"], status_code=201)
def upsert_attendance(
    attendance_in: AttendanceCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
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


@app.get("/api/v1/tutorings/slots", response_model=List[TutoringSlotOut], tags=["Reservas y Tutorias"])
def list_tutoring_slots(
    id_profesor: Optional[str] = None,
    id_bloque: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    query = db.query(FranjaTutoria)
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
    return (
        db.query(Reserva)
        .filter(or_(Reserva.id_alumno == user_id, Reserva.id_profesor == user_id))
        .order_by(Reserva.fecha.desc())
        .all()
    )


@app.post("/api/v1/reservations", response_model=ReservationOut, tags=["Reservas y Tutorias"], status_code=201)
def create_reservation(
    reservation_in: ReservationCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_student),
):
    slot = db.query(FranjaTutoria).filter(FranjaTutoria.id == reservation_in.id_franja).first()
    if not slot:
        raise HTTPException(status_code=404, detail="Franja no encontrada")
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
    current_user=Depends(require_professor_or_staff),
):
    reservation = db.query(Reserva).filter(Reserva.id == reservation_id).first()
    if not reservation:
        raise HTTPException(status_code=404, detail="Reserva no encontrada")
    reservation.estado = reservation_in.estado
    db.commit()
    db.refresh(reservation)
    return reservation


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
        .join(RelPersonalGrupos, RelPersonalGrupos.id_grupo == Grupo.id_grupo)
        .filter(RelPersonalGrupos.id_personal == current_user.id_personal)
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
            apellido=student.apellido,
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


@app.delete("/api/v1/content/{content_id}", status_code=204, tags=["Contenido"])
def delete_content(
    content_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(require_professor_or_staff),
):
    content = db.query(Contenido).filter(Contenido.id == content_id).first()
    if not content:
        raise HTTPException(status_code=404, detail="Contenido no encontrado")
    db.delete(content)
    db.commit()
    return
