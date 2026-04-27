from datetime import date, datetime, time, timedelta
import uuid
from typing import List, Optional

import bcrypt as bcrypt_lib
from fastapi import Depends, FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from pydantic import BaseModel
from sqlalchemy import create_engine, text
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
    Alumno, Profesor, PersonalEdem, Base, Grupo, Bloque, Sesion, Tarea,
    Asistencia, RelPersonalGrupos, RelAlumnosGrupos, RelBloquesGrupos,
    RelProfesoresBloques, RelAlumnoTarea, Evento, FranjaTutoria,
    Reserva, Notificacion, ConfiguracionNotificacion, Correo, Contenido
)


# ==========================================
# 1. CONEXION A LA BASE DE DATOS
# ==========================================

SQLALCHEMY_DATABASE_URL = settings.database_url

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    pool_pre_ping=True,
    echo=False if settings.ENVIRONMENT == "production" else True,
    pool_recycle=3600,
    poolclass=NullPool if settings.ENVIRONMENT == "production" else None,
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


app = FastAPI(
    title="API EDEM Student Hub",
    description="API para gestionar perfiles, calendario, bloques, sesiones, notas y asistencia.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ==========================================
# 2. ESQUEMAS PYDANTIC
# ==========================================


class ProfileUpdate(BaseModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    correo: Optional[str] = None


class Token(BaseModel):
    access_token: str
    token_type: str


class EventBase(BaseModel):
    tipo: str
    titulo: str
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
    id_sesion: Optional[str] = None
    aula: Optional[str] = None
    id_profesor: Optional[str] = None
    fecha_inicio: Optional[datetime] = None
    fecha_fin: Optional[datetime] = None
    descripcion: Optional[str] = None


class EventOut(EventBase):
    id: str

    class Config:
        orm_mode = True


class AlumnoOut(BaseModel):
    id_alumno: str
    nombre: str
    apellido: str
    correo: str

    class Config:
        orm_mode = True


class BlockBase(BaseModel):
    id_bloque: str
    nombre: str


class BlockCreate(BlockBase):
    pass


class BlockOut(BlockBase):
    class Config:
        orm_mode = True


class SessionBase(BaseModel):
    id_sesion: str
    id_bloque: str
    nombre: str
    fecha: date
    hora_inicio: time
    hora_fin: time
    aula: str


class SessionCreate(SessionBase):
    pass


class SessionUpdate(BaseModel):
    id_bloque: Optional[str] = None
    nombre: Optional[str] = None
    fecha: Optional[date] = None
    hora_inicio: Optional[time] = None
    hora_fin: Optional[time] = None
    aula: Optional[str] = None


class SessionOut(SessionBase):
    class Config:
        orm_mode = True


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


class AttendanceBase(BaseModel):
    id_alumno: str
    id_sesion: str
    fecha: Optional[date] = None
    presente: bool


class AttendanceCreate(AttendanceBase):
    pass


class AttendanceOut(BaseModel):
    id_asistencia: int
    id_alumno: str
    id_sesion: str
    fecha: Optional[date] = None
    presente: bool

    class Config:
        orm_mode = True


class AttendanceMetricsOut(BaseModel):
    total_clases: int
    clases_asistidas: int
    porcentaje_asistencia: float


class TutoringSlotBase(BaseModel):
    id_profesor: str
    id_bloque: Optional[str] = None
    dia_semana: int
    hora_inicio: str
    hora_fin: str
    ubicacion: str
    disponible: bool = True


class TutoringSlotCreate(TutoringSlotBase):
    pass


class TutoringSlotOut(TutoringSlotBase):
    id: str

    class Config:
        orm_mode = True


class ReservationBase(BaseModel):
    id_profesor: str
    id_franja: str
    fecha: date
    notas: Optional[str] = None


class ReservationCreate(ReservationBase):
    pass


class ReservationUpdate(BaseModel):
    estado: str


class ReservationOut(ReservationBase):
    id: str
    id_alumno: str
    estado: str
    fecha_creacion: datetime

    class Config:
        orm_mode = True


class NotificationOut(BaseModel):
    id: str
    tipo: str
    titulo: str
    mensaje: str
    leida: bool
    fecha_creacion: datetime

    class Config:
        orm_mode = True


class NotificationSettingsOut(BaseModel):
    avisos_calendario: bool
    avisos_notas: bool
    avisos_asistencia: bool

    class Config:
        orm_mode = True


class EmailCreate(BaseModel):
    id_destinatario: str
    asunto: str
    cuerpo: str


class EmailOut(BaseModel):
    id: str
    id_remitente: str
    id_destinatario: str
    asunto: str
    cuerpo: str
    leido: bool
    fecha_envio: datetime

    class Config:
        orm_mode = True


class UbicacionBase(BaseModel):
    descripcion: str
    planta: int
    aula: str


class UbicacionCreate(UbicacionBase):
    pass


class UbicacionOut(UbicacionBase):
    id_ubicacion: str

    class Config:
        orm_mode = True


class GrupoOut(BaseModel):
    id_grupo: str
    nombre: str

    class Config:
        orm_mode = True


class ContentCreate(BaseModel):
    titulo: str
    descripcion: Optional[str] = None
    tipo: str
    url: str


class ContentOut(ContentCreate):
    id: str
    id_bloque: str
    id_profesor: str
    fecha_subida: datetime

    class Config:
        orm_mode = True


# ==========================================
# 3. AUTENTICACION Y UTILIDADES
# ==========================================


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/token")

SCHEMA_PATCHES = (
    "ALTER TABLE alumnos ADD COLUMN IF NOT EXISTS apellido1 VARCHAR",
    "ALTER TABLE alumnos ADD COLUMN IF NOT EXISTS apellido2 VARCHAR",
    "ALTER TABLE profesores ADD COLUMN IF NOT EXISTS contrasena VARCHAR",
    "ALTER TABLE personal_edem ADD COLUMN IF NOT EXISTS contrasena VARCHAR",
    "ALTER TABLE tareas ADD COLUMN IF NOT EXISTS id_bloque VARCHAR REFERENCES bloques(id_bloque)",
    "ALTER TABLE asistencia ADD COLUMN IF NOT EXISTS id_sesion VARCHAR REFERENCES sesiones(id_sesion)",
    "ALTER TABLE asistencia ADD COLUMN IF NOT EXISTS fecha DATE",
    "ALTER TABLE eventos ADD COLUMN IF NOT EXISTS id_bloque VARCHAR REFERENCES bloques(id_bloque)",
    "ALTER TABLE franja_tutoria ADD COLUMN IF NOT EXISTS id_bloque VARCHAR REFERENCES bloques(id_bloque)",
    """
    DO $$
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_name = 'alumnos' AND column_name = 'apellido'
        ) THEN
            UPDATE alumnos
            SET apellido1 = COALESCE(apellido1, apellido)
            WHERE apellido IS NOT NULL;
        END IF;
    END $$;
    """,
)


def ensure_runtime_schema():
    Base.metadata.create_all(bind=engine)
    with engine.begin() as connection:
        for statement in SCHEMA_PATCHES:
            connection.execute(text(statement))


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=15))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.jwt_secret, algorithm=settings.JWT_ALGORITHM)


def buscar_usuario(db: Session, user_id: str):
    alumno = db.query(Alumno).filter(Alumno.id_alumno == user_id).first()
    if alumno:
        alumno.rol = "alumno"
        return alumno

    profesor = db.query(Profesor).filter(Profesor.id_profesor == user_id).first()
    if profesor:
        profesor.rol = "profesor"
        return profesor

    personal = db.query(PersonalEdem).filter(PersonalEdem.id_personal == user_id).first()
    if personal:
        personal.rol = personal.rol or "personal"
        return personal

    return None


def get_user_id(user) -> str:
    return (
        getattr(user, "id_alumno", None)
        or getattr(user, "id_profesor", None)
        or getattr(user, "id_personal", None)
    )


async def get_current_user(
    db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)
):
    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.JWT_ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = buscar_usuario(db, user_id)
    if user is None:
        raise credentials_exception
    return user


def require_student(current_user=Depends(get_current_user)):
    if current_user.rol != "alumno":
        raise HTTPException(status_code=403, detail="Solo los alumnos pueden acceder.")
    return current_user


@app.on_event("startup")
def startup():
    ensure_runtime_schema()


@app.get("/")
def root():
    return {"message": "EDEM Student Hub API", "docs": "/docs", "health": "/health"}


@app.get("/health")
def health():
    return {"status": "ok", "environment": settings.ENVIRONMENT}


# ==========================================
# 4. PERFIL Y ROLES
# ==========================================


@app.post("/api/v1/token", response_model=Token, tags=["Autenticacion"])
async def login_for_access_token(
    db: Session = Depends(get_db), form_data: OAuth2PasswordRequestForm = Depends()
):
    error = HTTPException(
        status_code=401,
        detail="Correo o contraseña incorrectos",
        headers={"WWW-Authenticate": "Bearer"},
    )

    def check_password(stored: str, provided: str) -> bool:
        if not stored:
            return False
        if stored.startswith("$2b$") or stored.startswith("$2a$"):
            return bcrypt_lib.checkpw(provided.encode("utf-8"), stored.encode("utf-8"))
        return stored == provided

    alumno = db.query(Alumno).filter(Alumno.correo == form_data.username).first()
    if alumno:
        if not check_password(alumno.contrasena, form_data.password):
            raise error
        user_id = alumno.id_alumno
    else:
        profesor = db.query(Profesor).filter(Profesor.correo == form_data.username).first()
        if profesor:
            if not check_password(profesor.contrasena, form_data.password):
                raise error
            user_id = profesor.id_profesor
        else:
            personal = db.query(PersonalEdem).filter(PersonalEdem.correo == form_data.username).first()
            if not personal or not check_password(personal.contrasena, form_data.password):
                raise error
            user_id = personal.id_personal

    access_token = create_access_token(
        data={"sub": user_id},
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
    )
    return {"access_token": access_token, "token_type": "bearer"}


@app.get("/api/v1/users/me", tags=["Perfil y Roles"])
def get_my_profile(current_user=Depends(get_current_user)):
    return {
        "id": get_user_id(current_user),
        "nombre": current_user.nombre,
        "apellido": current_user.apellido,
        "correo": current_user.correo,
        "rol": current_user.rol,
        "url_foto": current_user.url_foto,
    }


@app.put("/api/v1/users/me", tags=["Perfil y Roles"])
def update_profile(
    profile_data: ProfileUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if profile_data.nombre:
        current_user.nombre = profile_data.nombre
    if profile_data.apellido:
        current_user.apellido = profile_data.apellido
    if profile_data.correo:
        current_user.correo = profile_data.correo

    db.commit()
    db.refresh(current_user)

    return {"mensaje": "Perfil actualizado correctamente"}


@app.put("/api/v1/users/me/photo", tags=["Perfil y Roles"])
def upload_profile_photo(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    fake_gcp_url = f"https://storage.googleapis.com/tu-bucket/fotos/{get_user_id(current_user)}_{file.filename}"
    current_user.url_foto = fake_gcp_url
    db.commit()
    db.refresh(current_user)
    return {"mensaje": "Foto subida con exito", "url_foto": fake_gcp_url}


@app.get("/api/v1/users/{user_id}", tags=["Perfil y Roles"])
def get_user_profile(user_id: str, db: Session = Depends(get_db)):
    usuario = buscar_usuario(db, user_id)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    return {
        "id": user_id,
        "nombre": usuario.nombre,
        "apellido": usuario.apellido,
        "correo": usuario.correo,
        "rol": usuario.rol,
        "url_foto": usuario.url_foto,
    }

# ==========================================
# 2. CALENDARIO
# ==========================================

class EventBase(BaseModel):
    tipo: str # 'class', 'exam', 'delivery'
    titulo: str
    id_bloque: str
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
    aula: Optional[str] = None
    id_profesor: Optional[str] = None
    fecha_inicio: Optional[datetime] = None
    fecha_fin: Optional[datetime] = None
    descripcion: Optional[str] = None

class EventOut(EventBase):
    id: str

    class Config:
        orm_mode = True

# ==========================================
# 5. CALENDARIO
# ==========================================


@app.get("/api/v1/calendar/events", response_model=List[EventOut], tags=["Calendario"])
def list_events(tipo: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Evento)
    if tipo:
        query = query.filter(Evento.tipo == tipo)
    return query.all()


@app.post("/api/v1/calendar/events", response_model=EventOut, tags=["Calendario"], status_code=201)
def create_event(event_in: EventCreate, db: Session = Depends(get_db)):
    nuevo_evento = Evento(
        id=str(uuid.uuid4()),
        tipo=event_in.tipo,
        titulo=event_in.titulo,
        id_bloque=event_in.id_bloque,
        aula=event_in.aula,
        id_profesor=event_in.id_profesor,
        fecha_inicio=event_in.fecha_inicio,
        fecha_fin=event_in.fecha_fin,
        descripcion=event_in.descripcion,
    )
    db.add(nuevo_evento)
    db.commit()
    db.refresh(nuevo_evento)
    return nuevo_evento


@app.get("/api/v1/calendar/events/{event_id}", response_model=EventOut, tags=["Calendario"])
def get_event_detail(event_id: str, db: Session = Depends(get_db)):
    evento = db.query(Evento).filter(Evento.id == event_id).first()
    if not evento:
        raise HTTPException(status_code=404, detail="Evento no encontrado")
    return evento


@app.put("/api/v1/calendar/events/{event_id}", response_model=EventOut, tags=["Calendario"])
def update_event(event_id: str, event_in: EventUpdate, db: Session = Depends(get_db)):
    evento = db.query(Evento).filter(Evento.id == event_id).first()
    if not evento:
        raise HTTPException(status_code=404, detail="Evento no encontrado")

    for key, value in event_in.dict(exclude_unset=True).items():
        setattr(evento, key, value)

    db.commit()
    db.refresh(evento)
    return evento


@app.delete("/api/v1/calendar/events/{event_id}", status_code=204, tags=["Calendario"])
def delete_event(event_id: str, db: Session = Depends(get_db)):
    evento = db.query(Evento).filter(Evento.id == event_id).first()
    if not evento:
        raise HTTPException(status_code=404, detail="Evento no encontrado")
    db.delete(evento)
    db.commit()
    return


# ==========================================
# 3. ESQUEMAS COMPARTIDOS
# ==========================================

class AlumnoOut(BaseModel):
    id_alumno: str
    nombre: str
    apellido: str
    correo: str

    class Config:
        orm_mode = True

    nuevo = Bloque(id_bloque=block_in.id_bloque, nombre=block_in.nombre)
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo

class GradeUpdate(BaseModel):
    id_alumno: str
    nota: float

class GradeOut(BaseModel):
    id_tarea: int
    nombre_tarea: str
    id_bloque: str
    nota: float


@app.get("/api/v1/blocks/{block_id}", response_model=BlockOut, tags=["Bloques"])
def get_block(block_id: str, db: Session = Depends(get_db)):
    bloque = db.query(Bloque).filter(Bloque.id_bloque == block_id).first()
    if not bloque:
        raise HTTPException(status_code=404, detail="Bloque no encontrado")
    return bloque


@app.delete("/api/v1/blocks/{block_id}", status_code=204, tags=["Bloques"])
def delete_block(block_id: str, db: Session = Depends(get_db)):
    bloque = db.query(Bloque).filter(Bloque.id_bloque == block_id).first()
    if not bloque:
        raise HTTPException(status_code=404, detail="Bloque no encontrado")
    db.delete(bloque)
    db.commit()
    return


@app.get("/api/v1/blocks/{block_id}/students", response_model=List[AlumnoOut], tags=["Bloques"])
def get_block_students(block_id: str, db: Session = Depends(get_db)):
    alumnos = (
        db.query(Alumno)
        .join(RelAlumnosGrupos, Alumno.id_alumno == RelAlumnosGrupos.id_alumno)
        .join(RelBloquesGrupos, RelAlumnosGrupos.id_grupo == RelBloquesGrupos.id_grupo)
        .filter(RelBloquesGrupos.id_bloque == block_id)
        .distinct()
        .all()
    )
    return alumnos


# ==========================================
# 7. SESIONES
# ==========================================


@app.get("/api/v1/sessions", response_model=List[SessionOut], tags=["Sesiones"])
def list_sessions(
    id_bloque: Optional[str] = None,
    fecha: Optional[date] = None,
    db: Session = Depends(get_db),
):
    query = db.query(Sesion)
    if id_bloque:
        query = query.filter(Sesion.id_bloque == id_bloque)
    if fecha:
        query = query.filter(Sesion.fecha == fecha)
    return query.order_by(Sesion.fecha, Sesion.hora_inicio).all()


@app.get("/api/v1/sessions/me", response_model=List[SessionOut], tags=["Sesiones"])
def get_my_sessions(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if current_user.rol == "profesor":
        return (
            db.query(Sesion)
            .join(RelProfesoresBloques, Sesion.id_bloque == RelProfesoresBloques.id_bloque)
            .filter(RelProfesoresBloques.id_profesor == current_user.id_profesor)
            .order_by(Sesion.fecha, Sesion.hora_inicio)
            .all()
        )

    if current_user.rol == "alumno":
        return (
            db.query(Sesion)
            .join(RelBloquesGrupos, Sesion.id_bloque == RelBloquesGrupos.id_bloque)
            .join(RelAlumnosGrupos, RelBloquesGrupos.id_grupo == RelAlumnosGrupos.id_grupo)
            .filter(RelAlumnosGrupos.id_alumno == current_user.id_alumno)
            .order_by(Sesion.fecha, Sesion.hora_inicio)
            .distinct()
            .all()
        )

    if current_user.rol in ("coordinador", "personal"):
        return (
            db.query(Sesion)
            .join(RelBloquesGrupos, Sesion.id_bloque == RelBloquesGrupos.id_bloque)
            .join(RelPersonalGrupos, RelBloquesGrupos.id_grupo == RelPersonalGrupos.id_grupo)
            .filter(RelPersonalGrupos.id_personal == current_user.id_personal)
            .order_by(Sesion.fecha, Sesion.hora_inicio)
            .distinct()
            .all()
        )

    raise HTTPException(status_code=403, detail="Sin acceso a sesiones.")


@app.post("/api/v1/sessions", response_model=SessionOut, tags=["Sesiones"], status_code=201)
def create_session(session_in: SessionCreate, db: Session = Depends(get_db)):
    bloque = db.query(Bloque).filter(Bloque.id_bloque == session_in.id_bloque).first()
    if not bloque:
        raise HTTPException(status_code=404, detail="Bloque no encontrado")

    if db.query(Sesion).filter(Sesion.id_sesion == session_in.id_sesion).first():
        raise HTTPException(status_code=400, detail="El ID de la sesion ya existe")

    nueva = Sesion(**session_in.dict())
    db.add(nueva)
    db.commit()
    db.refresh(nueva)
    return nueva


@app.get("/api/v1/sessions/{session_id}", response_model=SessionOut, tags=["Sesiones"])
def get_session_detail(session_id: str, db: Session = Depends(get_db)):
    sesion = db.query(Sesion).filter(Sesion.id_sesion == session_id).first()
    if not sesion:
        raise HTTPException(status_code=404, detail="Sesion no encontrada")
    return sesion


@app.put("/api/v1/sessions/{session_id}", response_model=SessionOut, tags=["Sesiones"])
def update_session(session_id: str, session_in: SessionUpdate, db: Session = Depends(get_db)):
    sesion = db.query(Sesion).filter(Sesion.id_sesion == session_id).first()
    if not sesion:
        raise HTTPException(status_code=404, detail="Sesion no encontrada")

    for key, value in session_in.dict(exclude_unset=True).items():
        setattr(sesion, key, value)

    db.commit()
    db.refresh(sesion)
    return sesion


@app.delete("/api/v1/sessions/{session_id}", status_code=204, tags=["Sesiones"])
def delete_session(session_id: str, db: Session = Depends(get_db)):
    sesion = db.query(Sesion).filter(Sesion.id_sesion == session_id).first()
    if not sesion:
        raise HTTPException(status_code=404, detail="Sesion no encontrada")
    db.delete(sesion)
    db.commit()
    return


@app.get("/api/v1/sessions/{session_id}/students", response_model=List[AlumnoOut], tags=["Sesiones"])
def get_session_students(session_id: str, db: Session = Depends(get_db)):
    sesion = db.query(Sesion).filter(Sesion.id_sesion == session_id).first()
    if not sesion:
        raise HTTPException(status_code=404, detail="Sesion no encontrada")

    alumnos = (
        db.query(Alumno)
        .join(RelAlumnosGrupos, Alumno.id_alumno == RelAlumnosGrupos.id_alumno)
        .join(RelBloquesGrupos, RelAlumnosGrupos.id_grupo == RelBloquesGrupos.id_grupo)
        .filter(RelBloquesGrupos.id_bloque == sesion.id_bloque)
        .distinct()
        .all()
    )
    return alumnos


# ==========================================
# 8. NOTAS
# ==========================================


@app.get("/api/v1/grades/me", response_model=List[GradeOut], tags=["Notas"])
def get_my_grades(db: Session = Depends(get_db), current_user=Depends(require_student)):
    resultados = (
        db.query(RelAlumnoTarea, Tarea)
        .join(Tarea, RelAlumnoTarea.id_tarea == Tarea.id_tarea)
        .filter(RelAlumnoTarea.id_alumno == current_user.id_alumno)
        .all()
    )
    return [
        {
            "id_tarea": tarea.id_tarea,
            "nombre_tarea": tarea.nombre,
            "id_bloque": tarea.id_bloque,
            "nota": rel.nota
        }
        for rel, tarea in resultados
    ]

@app.get("/api/v1/grades/me/blocks/{block_id}", response_model=List[GradeOut], tags=["Notas"])
def get_my_grades_by_block(
    block_id: str,
    db: Session = Depends(get_db),
    current_user: Alumno = Depends(get_current_user)
):
    """Obtiene las notas del alumno filtradas por bloque."""
    if current_user.rol != 'alumno': raise HTTPException(status_code=403, detail="Solo los alumnos tienen notas.")
    resultados = db.query(RelAlumnoTarea, Tarea).join(
        Tarea, RelAlumnoTarea.id_tarea == Tarea.id_tarea
    ).filter(
        RelAlumnoTarea.id_alumno == current_user.id_alumno,
        Tarea.id_bloque == block_id
    ).all()

    return [
        {
            "id_tarea": tarea.id_tarea,
            "nombre_tarea": tarea.nombre,
            "id_bloque": tarea.id_bloque,
            "nota": rel.nota
        }
        for rel, tarea in resultados
    ]


@app.post("/api/v1/grades", tags=["Notas"], status_code=201)
def register_grade(grade_in: GradeCreate, db: Session = Depends(get_db)):
    nota_existente = db.query(RelAlumnoTarea).filter(
        RelAlumnoTarea.id_alumno == grade_in.id_alumno,
        RelAlumnoTarea.id_tarea == grade_in.id_tarea,
    ).first()

    if nota_existente:
        raise HTTPException(status_code=400, detail="El alumno ya tiene una nota para esta tarea")

    nueva_nota = RelAlumnoTarea(
        id_alumno=grade_in.id_alumno,
        id_tarea=grade_in.id_tarea,
        nota=grade_in.nota,
    )
    db.add(nueva_nota)
    db.commit()
    return {"mensaje": "Nota registrada correctamente"}


@app.put("/api/v1/grades/{tarea_id}", tags=["Notas"])
def update_grade(tarea_id: int, grade_in: GradeUpdate, db: Session = Depends(get_db)):
    nota_db = db.query(RelAlumnoTarea).filter(
        RelAlumnoTarea.id_tarea == tarea_id,
        RelAlumnoTarea.id_alumno == grade_in.id_alumno,
    ).first()
    if not nota_db:
        raise HTTPException(status_code=404, detail="Registro de nota no encontrado")

    nota_db.nota = grade_in.nota
    db.commit()
    db.refresh(nota_db)
    return {"mensaje": "Nota actualizada correctamente", "nueva_nota": nota_db.nota}


# ==========================================
# 9. ASISTENCIA
# ==========================================
class AttendanceBase(BaseModel):
    id_alumno: str
    id_sesion: str
    fecha: date
    presente: bool

class AttendanceCreate(AttendanceBase):
    pass

class AttendanceOut(AttendanceBase):
    id_asistencia: int


@app.get("/api/v1/attendance/me", response_model=List[AttendanceOut], tags=["Asistencia"])
def get_my_attendance(db: Session = Depends(get_db), current_user=Depends(require_student)):
    return db.query(Asistencia).filter(Asistencia.id_alumno == current_user.id_alumno).all()


@app.get("/api/v1/attendance/me/metrics", response_model=AttendanceMetricsOut, tags=["Asistencia"])
def get_attendance_metrics(db: Session = Depends(get_db), current_user=Depends(require_student)):
    registros = db.query(Asistencia).filter(Asistencia.id_alumno == current_user.id_alumno).all()
    total_clases = len(registros)
    if total_clases == 0:
        return {"total_clases": 0, "clases_asistidas": 0, "porcentaje_asistencia": 0.0}

    clases_asistidas = sum(1 for registro in registros if registro.presente)
    porcentaje = (clases_asistidas / total_clases) * 100.0
    return {
        "total_clases": total_clases,
        "clases_asistidas": clases_asistidas,
        "porcentaje_asistencia": round(porcentaje, 2),
    }


@app.post("/api/v1/attendance", response_model=AttendanceOut, tags=["Asistencia"], status_code=201)
def mark_attendance(attendance_in: AttendanceCreate, db: Session = Depends(get_db)):
    sesion = db.query(Sesion).filter(Sesion.id_sesion == attendance_in.id_sesion).first()
    if not sesion:
        raise HTTPException(status_code=404, detail="Sesion no encontrada")

    fecha_asistencia = attendance_in.fecha or sesion.fecha

    registro_existente = db.query(Asistencia).filter(
        Asistencia.id_alumno == attendance_in.id_alumno,
        Asistencia.id_sesion == attendance_in.id_sesion,
    ).first()

    if registro_existente:
        registro_existente.fecha = fecha_asistencia
        registro_existente.presente = attendance_in.presente
        db.commit()
        db.refresh(registro_existente)
        return registro_existente

    nuevo_registro = Asistencia(
        id_alumno=attendance_in.id_alumno,
        id_sesion=attendance_in.id_sesion,
        fecha=fecha_asistencia,
        presente=attendance_in.presente,
    )
    db.add(nuevo_registro)
    db.commit()
    db.refresh(nuevo_registro)
    return nuevo_registro

@app.get("/api/v1/attendance/sessions/{session_id}", response_model=List[AttendanceOut], tags=["Asistencia"])
def get_session_attendance(
    session_id: str,
    db: Session = Depends(get_db)
):
    """Obtiene los registros de asistencia de todos los alumnos de una sesión."""
    registros = db.query(Asistencia).filter(Asistencia.id_sesion == session_id).all()
    return registros

# ==========================================
# 6. RESERVAS Y TUTORÍAS
# ==========================================
# ==========================================
# ESQUEMAS PYDANTIC (Validación)
# ==========================================
class TutoringSlotBase(BaseModel):
    id_profesor: str
    id_bloque: Optional[str] = None
    dia_semana: int
    hora_inicio: str
    hora_fin: str
    ubicacion: str
    disponible: bool = True

class TutoringSlotCreate(TutoringSlotBase):
    pass

class TutoringSlotOut(TutoringSlotBase):
    id: str
    class Config:
        orm_mode = True

class ReservationBase(BaseModel):
    id_profesor: str
    id_franja: str
    fecha: date
    notas: Optional[str] = None

class ReservationCreate(ReservationBase):
    pass

@app.get("/api/v1/attendance/sessions/{session_id}", response_model=List[AttendanceOut], tags=["Asistencia"])
def get_session_attendance(session_id: str, db: Session = Depends(get_db)):
    return db.query(Asistencia).filter(Asistencia.id_sesion == session_id).all()


# ==========================================
# 10. RESERVAS Y TUTORIAS
# ==========================================


@app.get("/api/v1/reservations", response_model=List[ReservationOut], tags=["Reservas y Tutorias"])
def list_my_reservations(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    user_id = get_user_id(current_user)
    return db.query(Reserva).filter(
        (Reserva.id_alumno == user_id) | (Reserva.id_profesor == user_id)
    ).all()


@app.post("/api/v1/reservations", response_model=ReservationOut, tags=["Reservas y Tutorias"], status_code=201)
def request_tutoring(
    reservation_in: ReservationCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_student),
):
    franja = db.query(FranjaTutoria).filter(FranjaTutoria.id == reservation_in.id_franja).first()
    if not franja or not franja.disponible:
        raise HTTPException(status_code=400, detail="La franja solicitada no existe o no esta disponible")

    nueva_reserva = Reserva(
        id=str(uuid.uuid4()),
        id_alumno=current_user.id_alumno,
        id_profesor=reservation_in.id_profesor,
        id_franja=reservation_in.id_franja,
        fecha=reservation_in.fecha,
        notas=reservation_in.notas,
        estado="pending",
    )
    db.add(nueva_reserva)
    db.commit()
    db.refresh(nueva_reserva)
    return nueva_reserva


@app.put("/api/v1/reservations/{reservation_id}", response_model=ReservationOut, tags=["Reservas y Tutorias"])
def update_reservation(
    reservation_id: str,
    reservation_in: ReservationUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    reserva = db.query(Reserva).filter(Reserva.id == reservation_id).first()
    if not reserva:
        raise HTTPException(status_code=404, detail="Reserva no encontrada")

    if current_user.rol != "profesor" or reserva.id_profesor != current_user.id_profesor:
        raise HTTPException(status_code=403, detail="No tienes permiso para gestionar esta reserva")

    reserva.estado = reservation_in.estado
    db.commit()
    db.refresh(reserva)
    return reserva


@app.get("/api/v1/tutorings/slots", response_model=List[TutoringSlotOut], tags=["Reservas y Tutorias"])
def get_tutoring_slots(teacher_id: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(FranjaTutoria)
    if teacher_id:
        query = query.filter(FranjaTutoria.id_profesor == teacher_id)
    return query.all()

@app.post("/api/v1/tutorings/slots", response_model=TutoringSlotOut, tags=["Reservas y Tutorías"], status_code=201)
def create_tutoring_slot(
    slot_in: TutoringSlotCreate, 
    db: Session = Depends(get_db)
):
    """El profesor crea una nueva franja de disponibilidad."""
    nueva_franja = FranjaTutoria(
        id=str(uuid.uuid4()),
        id_profesor=slot_in.id_profesor,
        id_bloque=slot_in.id_bloque,
        dia_semana=slot_in.dia_semana,
        hora_inicio=slot_in.hora_inicio,
        hora_fin=slot_in.hora_fin,
        ubicacion=slot_in.ubicacion,
        disponible=slot_in.disponible
    )
    db.add(nueva_franja)
    db.commit()
    db.refresh(nueva_franja)
    return nueva_franja


# ==========================================
# 11. NOTIFICACIONES
# ==========================================


@app.get("/api/v1/notifications", response_model=List[NotificationOut], tags=["Notificaciones"])
def get_notifications(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return (
        db.query(Notificacion)
        .filter(Notificacion.id_usuario == get_user_id(current_user))
        .order_by(Notificacion.fecha_creacion.desc())
        .all()
    )


@app.put("/api/v1/notifications/{notis_id}/read", response_model=NotificationOut, tags=["Notificaciones"])
def mark_noti_as_read(
    notis_id: str, db: Session = Depends(get_db), current_user=Depends(get_current_user)
):
    user_id = get_user_id(current_user)
    notificacion = db.query(Notificacion).filter(
        Notificacion.id == notis_id,
        Notificacion.id_usuario == user_id,
    ).first()
    if not notificacion:
        raise HTTPException(status_code=404, detail="Notificacion no encontrada")

    notificacion.leida = True
    db.commit()
    db.refresh(notificacion)
    return notificacion


@app.get("/api/v1/notifications/settings", response_model=NotificationSettingsOut, tags=["Notificaciones"])
def get_notification_settings(
    db: Session = Depends(get_db), current_user=Depends(get_current_user)
):
    user_id = get_user_id(current_user)
    config = db.query(ConfiguracionNotificacion).filter(
        ConfiguracionNotificacion.id_usuario == user_id
    ).first()
    if not config:
        config = ConfiguracionNotificacion(id_usuario=user_id)
        db.add(config)
        db.commit()
        db.refresh(config)
    return config


# ==========================================
# 12. CORREOS INTERNOS
# ==========================================


@app.get("/api/v1/emails", response_model=List[EmailOut], tags=["Correos"])
def list_emails(
    folder: str = "inbox",
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    if folder == "inbox":
        return (
            db.query(Correo)
            .filter(Correo.id_destinatario == user_id)
            .order_by(Correo.fecha_envio.desc())
            .all()
        )
    if folder == "sent":
        return (
            db.query(Correo)
            .filter(Correo.id_remitente == user_id)
            .order_by(Correo.fecha_envio.desc())
            .all()
        )
    raise HTTPException(status_code=400, detail="Carpeta no valida. Usa 'inbox' o 'sent'.")


@app.post("/api/v1/emails", response_model=EmailOut, tags=["Correos"], status_code=201)
def send_email(
    email_in: EmailCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    nuevo_correo = Correo(
        id=str(uuid.uuid4()),
        id_remitente=get_user_id(current_user),
        id_destinatario=email_in.id_destinatario,
        asunto=email_in.asunto,
        cuerpo=email_in.cuerpo,
    )
    db.add(nuevo_correo)
    db.commit()
    db.refresh(nuevo_correo)
    return nuevo_correo


@app.get("/api/v1/emails/{email_id}", response_model=EmailOut, tags=["Correos"])
def read_email(
    email_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user_id = get_user_id(current_user)
    correo = db.query(Correo).filter(Correo.id == email_id).first()
    if not correo:
        raise HTTPException(status_code=404, detail="Correo no encontrado")
    if correo.id_destinatario != user_id and correo.id_remitente != user_id:
        raise HTTPException(status_code=403, detail="No tienes permiso para leer este correo")

    if correo.id_destinatario == user_id and not correo.leido:
        correo.leido = True
        db.commit()
        db.refresh(correo)
    return correo


# ==========================================
# 9. BLOQUES (concepto amplio: módulo/materia)
# ==========================================

class BloqueBase(BaseModel):
    nombre: str

class BloqueCreate(BloqueBase):
    pass

class BloqueOut(BloqueBase):
    id_bloque: str

    class Config:
        orm_mode = True

@app.get("/api/v1/blocks", response_model=List[BloqueOut], tags=["Bloques"])
def list_blocks(db: Session = Depends(get_db)):
    """Lista todos los bloques/módulos."""
    return db.query(Bloque).all()

@app.get("/api/v1/blocks/me", response_model=List[BloqueOut], tags=["Bloques"])
def get_my_blocks(
    db: Session = Depends(get_db),
    current_user: Alumno = Depends(get_current_user)
):
    """
    Bloques del usuario autenticado.
    - Alumno: bloques de su grupo.
    - Profesor: bloques que imparte.
    """
    if current_user.rol == "profesor":
        return db.query(Bloque).join(
            RelProfesoresBloques, Bloque.id_bloque == RelProfesoresBloques.id_bloque
        ).filter(RelProfesoresBloques.id_profesor == current_user.id_profesor).all()

    if current_user.rol == "alumno":
        return db.query(Bloque).join(
            RelBloquesGrupos, Bloque.id_bloque == RelBloquesGrupos.id_bloque
        ).join(
            RelAlumnosGrupos, RelBloquesGrupos.id_grupo == RelAlumnosGrupos.id_grupo
        ).filter(RelAlumnosGrupos.id_alumno == current_user.id_alumno).all()

    raise HTTPException(status_code=403, detail="Solo alumnos y profesores tienen bloques.")

@app.get("/api/v1/blocks/{block_id}", response_model=BloqueOut, tags=["Bloques"])
def get_block(block_id: str, db: Session = Depends(get_db)):
    """Obtiene el detalle de un bloque."""
    bloque = db.query(Bloque).filter(Bloque.id_bloque == block_id).first()
    if not bloque:
        raise HTTPException(status_code=404, detail="Bloque no encontrado")
    return bloque

@app.post("/api/v1/blocks", response_model=BloqueOut, tags=["Bloques"], status_code=201)
def create_block(block_in: BloqueCreate, db: Session = Depends(get_db)):
    """Crea un nuevo bloque/módulo."""
    nuevo = Bloque(id_bloque=str(uuid.uuid4()), nombre=block_in.nombre)
    db.add(nuevo)
    
# 13. UBICACIONES
# ==========================================


@app.get("/api/v1/locations", response_model=List[UbicacionOut], tags=["Ubicaciones"])
def list_locations(db: Session = Depends(get_db)):
    return db.query(Ubicacion).all()


@app.post("/api/v1/locations", response_model=UbicacionOut, tags=["Ubicaciones"], status_code=201)
def create_location(location_in: UbicacionCreate, db: Session = Depends(get_db)):
    nueva = Ubicacion(id_ubicacion=str(uuid.uuid4()), **location_in.dict())
    db.add(nueva)
    db.commit()
    db.refresh(nuevo)
    return nuevo

@app.put("/api/v1/blocks/{block_id}", response_model=BloqueOut, tags=["Bloques"])
def update_block(block_id: str, block_in: BloqueCreate, db: Session = Depends(get_db)):
    """Actualiza el nombre de un bloque."""
    bloque = db.query(Bloque).filter(Bloque.id_bloque == block_id).first()
    if not bloque:
        raise HTTPException(status_code=404, detail="Bloque no encontrado")
    bloque.nombre = block_in.nombre
    db.commit()
    db.refresh(bloque)
    return bloque

@app.delete("/api/v1/blocks/{block_id}", status_code=204, tags=["Bloques"])
def delete_block(block_id: str, db: Session = Depends(get_db)):
    """Elimina un bloque."""
    bloque = db.query(Bloque).filter(Bloque.id_bloque == block_id).first()
    if not bloque:
        raise HTTPException(status_code=404, detail="Bloque no encontrado")
    db.delete(bloque)
    db.commit()
    return

@app.get("/api/v1/blocks/{block_id}/students", response_model=List[AlumnoOut], tags=["Bloques"])
def get_block_students(block_id: str, db: Session = Depends(get_db)):
    """Obtiene los alumnos matriculados en un bloque cruzando con los grupos."""
    alumnos = db.query(Alumno).join(
        RelAlumnosGrupos, Alumno.id_alumno == RelAlumnosGrupos.id_alumno
    ).join(
        Grupo, RelAlumnosGrupos.id_grupo == Grupo.id_grupo
    ).join(
        RelBloquesGrupos, Grupo.id_grupo == RelBloquesGrupos.id_grupo
    ).filter(
        RelBloquesGrupos.id_bloque == block_id
    ).all()
    return alumnos

# ==========================================
# 12. SESIONES (encuentro específico con fecha y hora)
# ==========================================

class SesionBase(BaseModel):
    id_bloque: str
    nombre: str
    fecha: Optional[date] = None
    hora_inicio: Optional[str] = None
    hora_fin: Optional[str] = None
    aula: Optional[str] = None

class SesionCreate(SesionBase):
    pass

class SesionOut(SesionBase):
    id_sesion: str

    class Config:
        orm_mode = True

@app.get("/api/v1/blocks/{block_id}/sessions", response_model=List[SesionOut], tags=["Sesiones"])
def list_block_sessions(block_id: str, db: Session = Depends(get_db)):
    """Lista todas las sesiones (clases específicas) de un bloque."""
    return db.query(Sesion).filter(Sesion.id_bloque == block_id).order_by(Sesion.fecha).all()

@app.post("/api/v1/blocks/{block_id}/sessions", response_model=SesionOut, tags=["Sesiones"], status_code=201)
def create_session(block_id: str, session_in: SesionCreate, db: Session = Depends(get_db)):
    """Crea una nueva sesión (clase específica) dentro de un bloque."""
    nueva = Sesion(
        id_sesion=str(uuid.uuid4()),
        id_bloque=block_id,
        nombre=session_in.nombre,
        fecha=session_in.fecha,
        hora_inicio=session_in.hora_inicio,
        hora_fin=session_in.hora_fin,
        aula=session_in.aula
    )
    db.add(nueva)
    db.commit()
    db.refresh(nueva)
    return nueva

@app.get("/api/v1/sessions/{session_id}", response_model=SesionOut, tags=["Sesiones"])
def get_session(session_id: str, db: Session = Depends(get_db)):
    """Obtiene el detalle de una sesión específica."""
    sesion = db.query(Sesion).filter(Sesion.id_sesion == session_id).first()
    if not sesion:
        raise HTTPException(status_code=404, detail="Sesión no encontrada")
    return sesion

@app.put("/api/v1/sessions/{session_id}", response_model=SesionOut, tags=["Sesiones"])
def update_session(session_id: str, session_in: SesionCreate, db: Session = Depends(get_db)):
    """Actualiza los datos de una sesión específica."""
    sesion = db.query(Sesion).filter(Sesion.id_sesion == session_id).first()
    if not sesion:
        raise HTTPException(status_code=404, detail="Sesión no encontrada")
    sesion.nombre = session_in.nombre
    sesion.fecha = session_in.fecha
    sesion.hora_inicio = session_in.hora_inicio
    sesion.hora_fin = session_in.hora_fin
    sesion.aula = session_in.aula
    db.commit()
    db.refresh(sesion)
    return sesion

@app.delete("/api/v1/sessions/{session_id}", status_code=204, tags=["Sesiones"])
def delete_session(session_id: str, db: Session = Depends(get_db)):
    """Elimina una sesión específica."""
    sesion = db.query(Sesion).filter(Sesion.id_sesion == session_id).first()
    if not sesion:
        raise HTTPException(status_code=404, detail="Sesión no encontrada")
    db.delete(sesion)
    db.commit()
    return

@app.get("/api/v1/locations/{location_id}", response_model=UbicacionOut, tags=["Ubicaciones"])
def get_location(location_id: str, db: Session = Depends(get_db)):
    ubicacion = db.query(Ubicacion).filter(Ubicacion.id_ubicacion == location_id).first()
    if not ubicacion:
        raise HTTPException(status_code=404, detail="Ubicacion no encontrada")
    return ubicacion


# ==========================================
# 14. GRUPOS
# ==========================================


@app.get("/api/v1/groups", response_model=List[GrupoOut], tags=["Grupos"])
def list_groups(db: Session = Depends(get_db)):
    return db.query(Grupo).all()


@app.get("/api/v1/groups/me", response_model=List[GrupoOut], tags=["Grupos"])
def get_my_groups(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if current_user.rol == "alumno":
        return (
            db.query(Grupo)
            .join(RelAlumnosGrupos, Grupo.id_grupo == RelAlumnosGrupos.id_grupo)
            .filter(RelAlumnosGrupos.id_alumno == current_user.id_alumno)
            .all()
        )

    if current_user.rol in ("coordinador", "personal"):
        return (
            db.query(Grupo)
            .join(RelPersonalGrupos, Grupo.id_grupo == RelPersonalGrupos.id_grupo)
            .filter(RelPersonalGrupos.id_personal == current_user.id_personal)
            .all()
        )

    raise HTTPException(status_code=403, detail="Sin acceso a grupos.")


@app.get("/api/v1/groups/{group_id}/students", response_model=List[AlumnoOut], tags=["Grupos"])
def get_group_students(group_id: str, db: Session = Depends(get_db)):
    grupo = db.query(Grupo).filter(Grupo.id_grupo == group_id).first()
    if not grupo:
        raise HTTPException(status_code=404, detail="Grupo no encontrado")

    return (
        db.query(Alumno)
        .join(RelAlumnosGrupos, Alumno.id_alumno == RelAlumnosGrupos.id_alumno)
        .filter(RelAlumnosGrupos.id_grupo == group_id)
        .all()
    )

@app.get("/api/v1/groups/{group_id}/blocks", response_model=List[BloqueOut], tags=["Grupos"])
def get_group_blocks(group_id: str, db: Session = Depends(get_db)):
    """Lista los bloques asignados a un grupo."""
    grupo = db.query(Grupo).filter(Grupo.id_grupo == group_id).first()
    if not grupo:
        raise HTTPException(status_code=404, detail="Grupo no encontrado")

    return db.query(Bloque).join(
        RelBloquesGrupos, Bloque.id_bloque == RelBloquesGrupos.id_bloque
    ).filter(RelBloquesGrupos.id_grupo == group_id).all()

# ==========================================
# 10. CONTENIDO
# ==========================================

class ContenidoBase(BaseModel):
    id_bloque: str
    titulo: str
    descripcion: Optional[str] = None
    tipo: str  # 'pdf', 'video', 'enlace', 'otro'
    url: str

class ContenidoCreate(ContenidoBase):
    pass

class ContenidoOut(ContenidoBase):
    id: str
    id_profesor: str
    fecha_subida: datetime

@app.get("/api/v1/blocks/{block_id}/content", response_model=List[ContentOut], tags=["Contenido"])
def get_block_content(block_id: str, db: Session = Depends(get_db)):
    return (
        db.query(Contenido)
        .filter(Contenido.id_bloque == block_id)
        .order_by(Contenido.fecha_subida.desc())
        .all()
    )

@app.get("/api/v1/blocks/{block_id}/content", response_model=List[ContenidoOut], tags=["Contenido"])
def get_block_content(block_id: str, db: Session = Depends(get_db)):
    """Lista todos los materiales de un bloque."""
    return db.query(Contenido).filter(
        Contenido.id_bloque == block_id
    ).order_by(Contenido.fecha_subida.desc()).all()

@app.post("/api/v1/blocks/{block_id}/content", response_model=ContenidoOut, tags=["Contenido"], status_code=201)
def upload_content(
    block_id: str,
    content_in: ContenidoCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """Sube un nuevo material a un bloque (profesor o coordinador)."""
    if current_user.rol not in ("profesor", "coordinador", "personal"):
        raise HTTPException(status_code=403, detail="Solo profesores y coordinadores pueden subir contenido.")

    profesor_id = getattr(current_user, "id_profesor", None) or getattr(current_user, "id_personal", None)
    nuevo = Contenido(
        id=str(uuid.uuid4()),
        id_bloque=block_id,
        id_profesor=profesor_id,
        titulo=content_in.titulo,
        descripcion=content_in.descripcion,
        tipo=content_in.tipo,
        url=content_in.url,
    )
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo


@app.delete("/api/v1/content/{content_id}", status_code=204, tags=["Contenido"])
def delete_content(
    content_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    contenido = db.query(Contenido).filter(Contenido.id == content_id).first()
    if not contenido:
        raise HTTPException(status_code=404, detail="Contenido no encontrado")

    profesor_id = getattr(current_user, "id_profesor", None) or getattr(current_user, "id_personal", None)
    if current_user.rol not in ("coordinador", "personal") and contenido.id_profesor != profesor_id:
        raise HTTPException(status_code=403, detail="No tienes permiso para eliminar este contenido.")

    db.delete(contenido)
    db.commit()
    return
