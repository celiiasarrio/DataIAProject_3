from fastapi import FastAPI, Depends, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import NullPool
from pydantic import BaseModel
from typing import Optional
from sqlalchemy import Column, String, DateTime
from jose import JWTError, jwt
from passlib.context import CryptContext
import bcrypt as bcrypt_lib
import uuid
from datetime import datetime, date, timedelta
from typing import List
from dotenv import load_dotenv

# Importamos todos los modelos de la BBDD desde models.py
from models import (
    Alumno, Profesor, PersonalEdem, Base, Grupo, Asignatura, Tarea, 
    Asistencia, RelPersonalGrupos, RelAlumnosGrupos, RelAsignaturasGrupos,
    RelProfesoresAsignaturas, RelAlumnoTarea, Evento, FranjaTutoria, 
    Reserva, Notificacion, ConfiguracionNotificacion, Correo
)
from config import settings

# Cargamos las variables de entorno desde el archivo .env
load_dotenv()

# ==========================================
# 1. CONEXIÓN A LA BASE DE DATOS
# ==========================================
# La URL se genera automáticamente desde las variables de entorno en config.py
# Soporta PostgreSQL en Cloud SQL y localhost
SQLALCHEMY_DATABASE_URL = settings.database_url

# Configuración del engine optimizado para Cloud Run + Cloud SQL
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    pool_pre_ping=True,  # Verifica la conexión antes de usar
    echo=False if settings.ENVIRONMENT == "production" else True,  # SQL logging en desarrollo
    pool_recycle=3600,  # Recicla conexiones cada hora (importante para Cloud SQL)
    poolclass=NullPool if settings.ENVIRONMENT == "production" else None,  # Sin pool en producción
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

app = FastAPI(
    title="API EDEM Student Hub",
    description="API para gestionar perfiles, calendario, notas y más.",
    version="1.0.0",
    tags_metadata=[{"name": "Autenticación", "description": "Login y gestión de tokens."}]
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependencia para tener una sesión de base de datos por cada petición
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ==========================================
# 2. ESQUEMAS PYDANTIC (Validación de datos)
# ==========================================
class ProfileUpdate(BaseModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    correo: Optional[str] = None

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    sub: Optional[str] = None

# ==========================================
# 3. UTILIDADES / MOCK AUTH
# ==========================================

# --- Configuración de Seguridad (OAuth2 + JWT) ---
SECRET_KEY = "tu-clave-secreta-deberia-ser-muy-larga-y-aleatoria-y-estar-en-un-secret-manager"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 8 # 8 horas

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/token")

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# Función vital: Como tienes 3 tablas separadas, buscamos al usuario en todas
def buscar_usuario(db: Session, user_id: str):
    alumno = db.query(Alumno).filter(Alumno.id_alumno == user_id).first()
    if alumno:
        # Adjuntamos el rol al objeto para usarlo después
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

async def get_current_user(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None: raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = buscar_usuario(db, user_id)
    if user is None: raise credentials_exception
    return user

# ==========================================
# 4. ENDPOINTS: PERFIL Y ROLES
# ==========================================

@app.post("/api/v1/token", response_model=Token, tags=["Autenticación"])
async def login_for_access_token(db: Session = Depends(get_db), form_data: OAuth2PasswordRequestForm = Depends()):
    """
    Endpoint de login. Recibe 'username' (correo) y 'password'.
    Busca en alumnos, profesores y personal. Devuelve un access_token.
    """
    error = HTTPException(status_code=401, detail="Correo o contraseña incorrectos", headers={"WWW-Authenticate": "Bearer"})

    def check_password(stored: str, provided: str) -> bool:
        if not stored:
            return False
        if stored.startswith("$2b$") or stored.startswith("$2a$"):
            return bcrypt_lib.checkpw(provided.encode("utf-8"), stored.encode("utf-8"))
        return stored == provided  # plain text fallback (pre-migration)

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
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/api/v1/users/me", tags=["Perfil y Roles"])
def get_my_profile(current_user: Alumno = Depends(get_current_user)):
    """Obtiene el perfil del usuario autenticado."""
    return {
        "id": getattr(current_user, 'id_alumno', None) or getattr(current_user, 'id_profesor', None) or getattr(current_user, 'id_personal', None),
        "nombre": current_user.nombre,
        "apellido": current_user.apellido,
        "correo": current_user.correo,
        "rol": current_user.rol,
        "url_foto": current_user.url_foto
    }

@app.put("/api/v1/users/me", tags=["Perfil y Roles"])
def update_profile(
    profile_data: ProfileUpdate, 
    db: Session = Depends(get_db),
    current_user: Alumno = Depends(get_current_user)
):
    """Actualiza los datos básicos del perfil."""
    # Actualizamos solo los campos que vengan en la petición
    if profile_data.nombre: current_user.nombre = profile_data.nombre
    if profile_data.apellido: current_user.apellido = profile_data.apellido
    if profile_data.correo: current_user.correo = profile_data.correo

    db.commit()
    db.refresh(current_user)
    
    return {"mensaje": "Perfil actualizado correctamente", "datos": profile_data}

@app.put("/api/v1/users/me/photo", tags=["Perfil y Roles"])
def upload_profile_photo(
    file: UploadFile = File(...), 
    db: Session = Depends(get_db),
    current_user: Alumno = Depends(get_current_user)
):
    """Sube una foto de perfil y actualiza la URL en la BBDD."""
    user_id = getattr(current_user, 'id_alumno', None) or getattr(current_user, 'id_profesor', None) or getattr(current_user, 'id_personal', None)
    # AQUÍ IRÍA LA LÓGICA DE GCP (Google Cloud Storage):
    # 1. Subir el 'file' a tu bucket de GCP
    # 2. Obtener la URL pública de esa imagen
    # Para este ejemplo, simulamos la URL:
    fake_gcp_url = f"https://storage.googleapis.com/tu-bucket/fotos/{user_id}_{file.filename}"
    
    # Guardamos la URL en la tabla correspondiente
    current_user.url_foto = fake_gcp_url
    db.commit()
    db.refresh(current_user)

    return {"mensaje": "Foto subida con éxito", "url_foto": fake_gcp_url}

@app.get("/api/v1/users/{user_id}", tags=["Perfil y Roles"])
def get_user_profile(user_id: str, db: Session = Depends(get_db)):
    """Busca el perfil de CUALQUIER usuario del sistema por su ID."""
    usuario = buscar_usuario(db, user_id)
    
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado en ninguna tabla")

    return {
        "id": user_id,
        "nombre": usuario.nombre,
        "apellido": usuario.apellido,
        "correo": usuario.correo,
        "rol": usuario.rol,
        "url_foto": usuario.url_foto
    }

# ==========================================
# 2. CALENDARIO
# ==========================================

class EventBase(BaseModel):
    tipo: str # 'class', 'exam', 'delivery'
    titulo: str
    id_asignatura: str
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
    id_asignatura: Optional[str] = None
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
# ENDPOINTS: CALENDARIO
# ==========================================

@app.get("/api/v1/calendar/events", response_model=List[EventOut], tags=["Calendario"])
def list_events(
    tipo: Optional[str] = None, 
    db: Session = Depends(get_db)
):
    """Lista todos los eventos del calendario. Permite filtrar por tipo."""
    query = db.query(Evento)
    if tipo:
        query = query.filter(Evento.tipo == tipo)
    return query.all()

@app.post("/api/v1/calendar/events", response_model=EventOut, tags=["Calendario"], status_code=201)
def create_event(
    event_in: EventCreate, 
    db: Session = Depends(get_db)
):
    """Crea un nuevo evento en el calendario."""
    nuevo_evento = Evento(
        id=str(uuid.uuid4()), # Generamos un ID único automáticamente
        tipo=event_in.tipo,
        titulo=event_in.titulo,
        id_asignatura=event_in.id_asignatura,
        aula=event_in.aula,
        id_profesor=event_in.id_profesor,
        fecha_inicio=event_in.fecha_inicio,
        fecha_fin=event_in.fecha_fin,
        descripcion=event_in.descripcion
    )
    db.add(nuevo_evento)
    db.commit()
    db.refresh(nuevo_evento)
    return nuevo_evento

@app.get("/api/v1/calendar/events/{event_id}", response_model=EventOut, tags=["Calendario"])
def get_event_detail(
    event_id: str, 
    db: Session = Depends(get_db)
):
    """Obtiene los detalles completos de un evento específico."""
    evento = db.query(Evento).filter(Evento.id == event_id).first()
    if not evento:
        raise HTTPException(status_code=404, detail="Evento no encontrado")
    return evento

@app.put("/api/v1/calendar/events/{event_id}", response_model=EventOut, tags=["Calendario"])
def update_event(
    event_id: str, 
    event_in: EventUpdate, 
    db: Session = Depends(get_db)
):
    """Actualiza la información de un evento existente."""
    evento = db.query(Evento).filter(Evento.id == event_id).first()
    if not evento:
        raise HTTPException(status_code=404, detail="Evento no encontrado")

    # Actualizamos solo los campos que vengan en la petición (no nulos)
    update_data = event_in.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(evento, key, value)

    db.commit()
    db.refresh(evento)
    return evento

@app.delete("/api/v1/calendar/events/{event_id}", status_code=204, tags=["Calendario"])
def delete_event(
    event_id: str, 
    db: Session = Depends(get_db)
):
    """Elimina un evento del calendario."""
    evento = db.query(Evento).filter(Evento.id == event_id).first()
    if not evento:
        raise HTTPException(status_code=404, detail="Evento no encontrado")
        
    db.delete(evento)
    db.commit()
    return

# ==========================================
# 3. ASIGNATURAS
# ==========================================

class SubjectBase(BaseModel):
    id_asignatura: str
    nombre: str

class SubjectCreate(SubjectBase):
    pass

class SubjectOut(SubjectBase):
    class Config:
        orm_mode = True

class AlumnoOut(BaseModel):
    id_alumno: str
    nombre: str
    apellido: str
    correo: str
    
    class Config:
        orm_mode = True

# --- ESQUEMAS PARA NOTAS (Tareas) ---
class GradeCreate(BaseModel):
    id_alumno: str
    id_tarea: int
    nota: float

class GradeUpdate(BaseModel):
    id_alumno: str # Necesitamos saber de qué alumno es la nota
    nota: float

class GradeOut(BaseModel):
    id_tarea: int
    nombre_tarea: str
    id_asignatura: str
    nota: float


@app.get("/api/v1/subjects", response_model=List[SubjectOut], tags=["Asignaturas"])
def list_subjects(db: Session = Depends(get_db)):
    """Lista todas las asignaturas."""
    return db.query(Asignatura).all()

@app.post("/api/v1/subjects", response_model=SubjectOut, tags=["Asignaturas"], status_code=201)
def create_subject(subject_in: SubjectCreate, db: Session = Depends(get_db)):
    """Crea una nueva asignatura (Endpoint añadido a petición)."""
    db_subject = db.query(Asignatura).filter(Asignatura.id_asignatura == subject_in.id_asignatura).first()
    if db_subject:
        raise HTTPException(status_code=400, detail="El ID de la asignatura ya existe")
        
    nueva_asignatura = Asignatura(
        id_asignatura=subject_in.id_asignatura,
        nombre=subject_in.nombre
    )
    db.add(nueva_asignatura)
    db.commit()
    db.refresh(nueva_asignatura)
    return nueva_asignatura

@app.get("/api/v1/subjects/{subject_id}", response_model=SubjectOut, tags=["Asignaturas"])
def get_subject_detail(subject_id: str, db: Session = Depends(get_db)):
    """Obtiene el detalle de una asignatura."""
    asignatura = db.query(Asignatura).filter(Asignatura.id_asignatura == subject_id).first()
    if not asignatura:
        raise HTTPException(status_code=404, detail="Asignatura no encontrada")
    return asignatura

@app.delete("/api/v1/subjects/{subject_id}", status_code=204, tags=["Asignaturas"])
def delete_subject(subject_id: str, db: Session = Depends(get_db)):
    """Elimina una asignatura (Endpoint añadido a petición)."""
    asignatura = db.query(Asignatura).filter(Asignatura.id_asignatura == subject_id).first()
    if not asignatura:
        raise HTTPException(status_code=404, detail="Asignatura no encontrada")
    
    db.delete(asignatura)
    db.commit()
    return

@app.get("/api/v1/subjects/{subject_id}/students", response_model=List[AlumnoOut], tags=["Asignaturas"])
def get_enrolled_students(subject_id: str, db: Session = Depends(get_db)):
    """Obtiene los alumnos matriculados cruzando con los grupos."""
    alumnos = db.query(Alumno).join(
        RelAlumnosGrupos, Alumno.id_alumno == RelAlumnosGrupos.id_alumno
    ).join(
        Grupo, RelAlumnosGrupos.id_grupo == Grupo.id_grupo
    ).join(
        RelAsignaturasGrupos, Grupo.id_grupo == RelAsignaturasGrupos.id_grupo
    ).filter(
        RelAsignaturasGrupos.id_asignatura == subject_id
    ).all()
    
    return alumnos

# ==========================================
# 4. NOTAS
# ==========================================
# ==========================================
# ENDPOINTS: NOTAS
# ==========================================

@app.get("/api/v1/grades/me", response_model=List[GradeOut], tags=["Notas"])
def get_my_grades(
    db: Session = Depends(get_db), 
    current_user: Alumno = Depends(get_current_user)
):
    """Obtiene todas las notas del alumno autenticado."""
    if current_user.rol != 'alumno': raise HTTPException(status_code=403, detail="Solo los alumnos tienen notas.")
    resultados = db.query(RelAlumnoTarea, Tarea).join(
        Tarea, RelAlumnoTarea.id_tarea == Tarea.id_tarea
    ).filter(
        RelAlumnoTarea.id_alumno == current_user.id_alumno
    ).all()
    
    # Formateamos la salida
    return [
        {
            "id_tarea": tarea.id_tarea,
            "nombre_tarea": tarea.nombre,
            "id_asignatura": tarea.id_asignatura,
            "nota": rel.nota
        }
        for rel, tarea in resultados
    ]

@app.get("/api/v1/grades/me/subjects/{subject_id}", response_model=List[GradeOut], tags=["Notas"])
def get_my_grades_by_subject(
    subject_id: str, 
    db: Session = Depends(get_db), 
    current_user: Alumno = Depends(get_current_user)
):
    """Obtiene las notas del alumno filtradas por asignatura."""
    if current_user.rol != 'alumno': raise HTTPException(status_code=403, detail="Solo los alumnos tienen notas.")
    resultados = db.query(RelAlumnoTarea, Tarea).join(
        Tarea, RelAlumnoTarea.id_tarea == Tarea.id_tarea
    ).filter(
        RelAlumnoTarea.id_alumno == current_user.id_alumno,
        Tarea.id_asignatura == subject_id
    ).all()
    
    return [
        {
            "id_tarea": tarea.id_tarea,
            "nombre_tarea": tarea.nombre,
            "id_asignatura": tarea.id_asignatura,
            "nota": rel.nota
        }
        for rel, tarea in resultados
    ]

@app.post("/api/v1/grades", tags=["Notas"], status_code=201)
def register_grade(grade_in: GradeCreate, db: Session = Depends(get_db)):
    """Registra una nueva nota para un alumno en una tarea."""
    # Verificamos si ya existe una nota para ese alumno y tarea
    nota_existente = db.query(RelAlumnoTarea).filter(
        RelAlumnoTarea.id_alumno == grade_in.id_alumno,
        RelAlumnoTarea.id_tarea == grade_in.id_tarea
    ).first()
    
    if nota_existente:
        raise HTTPException(status_code=400, detail="El alumno ya tiene una nota para esta tarea. Usa PUT para actualizar.")
        
    nueva_nota = RelAlumnoTarea(
        id_alumno=grade_in.id_alumno,
        id_tarea=grade_in.id_tarea,
        nota=grade_in.nota
    )
    db.add(nueva_nota)
    db.commit()
    return {"mensaje": "Nota registrada correctamente", "datos": grade_in}

@app.put("/api/v1/grades/{tarea_id}", tags=["Notas"])
def update_grade(
    tarea_id: int, 
    grade_in: GradeUpdate, 
    db: Session = Depends(get_db)
):
    """Actualiza la nota existente. Requiere ID de tarea en URL e ID de alumno en el Body."""
    nota_db = db.query(RelAlumnoTarea).filter(
        RelAlumnoTarea.id_tarea == tarea_id,
        RelAlumnoTarea.id_alumno == grade_in.id_alumno
    ).first()
    
    if not nota_db:
        raise HTTPException(status_code=404, detail="Registro de nota no encontrado para este alumno y tarea")
        
    nota_db.nota = grade_in.nota
    db.commit()
    db.refresh(nota_db)
    
    return {"mensaje": "Nota actualizada correctamente", "nueva_nota": nota_db.nota}

# ==========================================
# 5. ASISTENCIA
# ==========================================

# ==========================================
# ESQUEMAS PYDANTIC (Validación de Asistencia)
# ==========================================
class AttendanceBase(BaseModel):
    id_alumno: str
    id_asignatura: str
    fecha: date
    presente: bool

class AttendanceCreate(AttendanceBase):
    pass

class AttendanceOut(AttendanceBase):
    id_asistencia: int

    class Config:
        orm_mode = True

class AttendanceMetricsOut(BaseModel):
    total_clases: int
    clases_asistidas: int
    porcentaje_asistencia: float

# ==========================================
# ENDPOINTS: ASISTENCIA
# ==========================================

@app.get("/api/v1/attendance/me", response_model=List[AttendanceOut], tags=["Asistencia"])
def get_my_attendance(
    db: Session = Depends(get_db), 
    current_user: Alumno = Depends(get_current_user)
):
    """Obtiene todo el historial de asistencia del alumno autenticado."""
    if current_user.rol != 'alumno': raise HTTPException(status_code=403, detail="Solo los alumnos tienen registros de asistencia.")
    registros = db.query(Asistencia).filter(Asistencia.id_alumno == current_user.id_alumno).all()
    return registros

@app.get("/api/v1/attendance/me/metrics", response_model=AttendanceMetricsOut, tags=["Asistencia"])
def get_attendance_metrics(
    db: Session = Depends(get_db), 
    current_user: Alumno = Depends(get_current_user)
):
    """Calcula las métricas (% de asistencia) del alumno."""
    if current_user.rol != 'alumno': raise HTTPException(status_code=403, detail="Solo los alumnos tienen métricas de asistencia.")
    registros = db.query(Asistencia).filter(Asistencia.id_alumno == current_user.id_alumno).all()
    
    total_clases = len(registros)
    if total_clases == 0:
        return {"total_clases": 0, "clases_asistidas": 0, "porcentaje_asistencia": 0.0}
        
    clases_asistidas = sum(1 for r in registros if r.presente)
    porcentaje = (clases_asistidas / total_clases) * 100.0
    
    return {
        "total_clases": total_clases,
        "clases_asistidas": clases_asistidas,
        "porcentaje_asistencia": round(porcentaje, 2)
    }

@app.post("/api/v1/attendance", response_model=AttendanceOut, tags=["Asistencia"], status_code=201)
def mark_attendance(
    attendance_in: AttendanceCreate, 
    db: Session = Depends(get_db)
):
    """Registra la asistencia de un alumno a una clase específica."""
    # Verificamos si ya se pasó lista para ese alumno, en esa asignatura, ese día
    registro_existente = db.query(Asistencia).filter(
        Asistencia.id_alumno == attendance_in.id_alumno,
        Asistencia.id_asignatura == attendance_in.id_asignatura,
        Asistencia.fecha == attendance_in.fecha
    ).first()
    
    if registro_existente:
        # Si ya existe, lo actualizamos (útil si el profe se equivocó al pasar lista)
        registro_existente.presente = attendance_in.presente
        db.commit()
        db.refresh(registro_existente)
        return registro_existente
        
    # Si no existe, creamos un registro nuevo
    nuevo_registro = Asistencia(
        id_alumno=attendance_in.id_alumno,
        id_asignatura=attendance_in.id_asignatura,
        fecha=attendance_in.fecha,
        presente=attendance_in.presente
    )
    db.add(nuevo_registro)
    db.commit()
    db.refresh(nuevo_registro)
    return nuevo_registro

@app.get("/api/v1/attendance/subjects/{subject_id}", response_model=List[AttendanceOut], tags=["Asistencia"])
def get_class_attendance(
    subject_id: str, 
    db: Session = Depends(get_db)
):
    """Obtiene los registros de asistencia de todos los alumnos de una asignatura."""
    registros = db.query(Asistencia).filter(Asistencia.id_asignatura == subject_id).all()
    return registros

# ==========================================
# 6. RESERVAS Y TUTORÍAS
# ==========================================
# ==========================================
# ESQUEMAS PYDANTIC (Validación)
# ==========================================
class TutoringSlotBase(BaseModel):
    id_profesor: str
    id_asignatura: Optional[str] = None
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
    estado: str # "confirmed", "rejected", "completed"

class ReservationOut(ReservationBase):
    id: str
    id_alumno: str
    estado: str
    fecha_creacion: datetime
    class Config:
        orm_mode = True

# ==========================================
# ENDPOINTS: RESERVAS Y TUTORÍAS
# ==========================================

@app.get("/api/v1/reservations", response_model=List[ReservationOut], tags=["Reservas y Tutorías"])
def list_my_reservations(
    db: Session = Depends(get_db), 
    current_user: Alumno = Depends(get_current_user)
):
    """Lista las reservas que he solicitado (como alumno) o que me han solicitado (como profesor)."""
    user_id = getattr(current_user, 'id_alumno', None) or getattr(current_user, 'id_profesor', None)
    # Buscamos donde el usuario sea alumno o profesor
    reservas = db.query(Reserva).filter(
        (Reserva.id_alumno == user_id) | (Reserva.id_profesor == user_id)
    ).all()
    return reservas

@app.post("/api/v1/reservations", response_model=ReservationOut, tags=["Reservas y Tutorías"], status_code=201)
def request_tutoring(
    reservation_in: ReservationCreate, 
    db: Session = Depends(get_db), 
    current_user: Alumno = Depends(get_current_user)
):
    """Solicita una nueva reserva o tutoría."""
    # Verificar si la franja existe y está disponible
    franja = db.query(FranjaTutoria).filter(FranjaTutoria.id == reservation_in.id_franja).first()
    if not franja or not franja.disponible:
        raise HTTPException(status_code=400, detail="La franja solicitada no existe o ya no está disponible.")

    if current_user.rol != 'alumno': raise HTTPException(status_code=403, detail="Solo los alumnos pueden solicitar tutorías.")

    nueva_reserva = Reserva(
        id=str(uuid.uuid4()),
        id_alumno=current_user.id_alumno,
        id_profesor=reservation_in.id_profesor,
        id_franja=reservation_in.id_franja,
        fecha=reservation_in.fecha,
        notas=reservation_in.notas,
        estado="pending" # Por defecto, la reserva queda pendiente de confirmación
    )
    
    db.add(nueva_reserva)
    db.commit()
    db.refresh(nueva_reserva)
    return nueva_reserva

@app.put("/api/v1/reservations/{reservation_id}", response_model=ReservationOut, tags=["Reservas y Tutorías"])
def update_reservation(
    reservation_id: str, 
    reservation_in: ReservationUpdate, 
    db: Session = Depends(get_db),
    current_user: Alumno = Depends(get_current_user)
):
    """Actualiza el estado de una reserva (Confirmar/Rechazar)."""
    reserva = db.query(Reserva).filter(Reserva.id == reservation_id).first()
    if not reserva:
        raise HTTPException(status_code=404, detail="Reserva no encontrada")
        
    # Validar que solo el profesor implicado puede cambiar el estado (y que el usuario actual sea un profesor)
    if current_user.rol != 'profesor' or reserva.id_profesor != current_user.id_profesor:
        raise HTTPException(status_code=403, detail="No tienes permiso para gestionar esta reserva")

    reserva.estado = reservation_in.estado
    db.commit()
    db.refresh(reserva)
    return reserva

@app.get("/api/v1/tutorings/slots", response_model=List[TutoringSlotOut], tags=["Reservas y Tutorías"])
def get_tutoring_slots(
    teacher_id: Optional[str] = None, 
    db: Session = Depends(get_db)
):
    """Obtiene las franjas de disponibilidad. Permite filtrar por profesor."""
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
        id_asignatura=slot_in.id_asignatura,
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
# 7. NOTIFICACIONES
# ==========================================
# ==========================================
# ESQUEMAS PYDANTIC (Validación)
# ==========================================
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

# ==========================================
# ENDPOINTS: NOTIFICACIONES
# ==========================================

@app.get("/api/v1/notifications", response_model=List[NotificationOut], tags=["Notificaciones"])
def get_notifications(
    db: Session = Depends(get_db), 
    current_user: Alumno = Depends(get_current_user)
):
    """Obtiene el listado de notificaciones del usuario."""
    user_id = getattr(current_user, 'id_alumno', None) or getattr(current_user, 'id_profesor', None) or getattr(current_user, 'id_personal', None)
    notificaciones = db.query(Notificacion).filter(
        Notificacion.id_usuario == user_id
    ).order_by(Notificacion.fecha_creacion.desc()).all()
    
    return notificaciones

@app.put("/api/v1/notifications/{notis_id}/read", response_model=NotificationOut, tags=["Notificaciones"])
def mark_noti_as_read(
    notis_id: str, 
    db: Session = Depends(get_db), 
    current_user: Alumno = Depends(get_current_user)
):
    """Marca una notificación específica como leída."""
    user_id = getattr(current_user, 'id_alumno', None) or getattr(current_user, 'id_profesor', None) or getattr(current_user, 'id_personal', None)
    notificacion = db.query(Notificacion).filter(
        Notificacion.id == notis_id,
        Notificacion.id_usuario == user_id
    ).first()
    
    if not notificacion:
        raise HTTPException(status_code=404, detail="Notificación no encontrada")
        
    notificacion.leida = True
    db.commit()
    db.refresh(notificacion)
    
    return notificacion

@app.get("/api/v1/notifications/settings", response_model=NotificationSettingsOut, tags=["Notificaciones"])
def get_notification_settings(
    db: Session = Depends(get_db), 
    current_user: Alumno = Depends(get_current_user)
):
    """Obtiene las preferencias de avisos del usuario."""
    user_id = getattr(current_user, 'id_alumno', None) or getattr(current_user, 'id_profesor', None) or getattr(current_user, 'id_personal', None)
    config = db.query(ConfiguracionNotificacion).filter(
        ConfiguracionNotificacion.id_usuario == user_id
    ).first()
    
    # Si no existe configuración, devolvemos una por defecto (todo activado)
    if not config:
        config = ConfiguracionNotificacion(id_usuario=user_id)
        db.add(config)
        db.commit()
        db.refresh(config)
        
    return config

# ==========================================
# 8. CORREOS INTERNOS
# ==========================================
# ==========================================
# ESQUEMAS PYDANTIC (Validación de Correos)
# ==========================================
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

# ==========================================
# ENDPOINTS: CORREOS
# ==========================================

@app.get("/api/v1/emails", response_model=List[EmailOut], tags=["Correos"])
def list_emails(
    folder: str = "inbox", 
    db: Session = Depends(get_db), 
    current_user: Alumno = Depends(get_current_user)
):
    """Lista los correos. Permite filtrar por 'inbox' (recibidos) o 'sent' (enviados)."""
    user_id = getattr(current_user, 'id_alumno', None) or getattr(current_user, 'id_profesor', None) or getattr(current_user, 'id_personal', None)
    if folder == "inbox":
        correos = db.query(Correo).filter(
            Correo.id_destinatario == user_id
        ).order_by(Correo.fecha_envio.desc()).all()
    elif folder == "sent":
        correos = db.query(Correo).filter(
            Correo.id_remitente == user_id
        ).order_by(Correo.fecha_envio.desc()).all()
    else:
        raise HTTPException(status_code=400, detail="Carpeta no válida. Usa 'inbox' o 'sent'.")
        
    return correos

@app.post("/api/v1/emails", response_model=EmailOut, tags=["Correos"], status_code=201)
def send_email(
    email_in: EmailCreate, 
    db: Session = Depends(get_db), 
    current_user: Alumno = Depends(get_current_user)
):
    """Envía un nuevo correo interno a otro usuario."""
    # Aquí podríamos añadir una validación para comprobar que el id_destinatario existe en la BBDD
    user_id = getattr(current_user, 'id_alumno', None) or getattr(current_user, 'id_profesor', None) or getattr(current_user, 'id_personal', None)
    
    nuevo_correo = Correo(
        id=str(uuid.uuid4()),
        id_remitente=user_id, # El remitente es el usuario que hace la petición
        id_destinatario=email_in.id_destinatario,
        asunto=email_in.asunto,
        cuerpo=email_in.cuerpo
    )
    
    db.add(nuevo_correo)
    db.commit()
    db.refresh(nuevo_correo)
    
    return nuevo_correo

@app.get("/api/v1/emails/{email_id}", response_model=EmailOut, tags=["Correos"])
def read_email(
    email_id: str, 
    db: Session = Depends(get_db), 
    current_user: Alumno = Depends(get_current_user)
):
    """Lee un correo específico. Si eres el destinatario, se marca como leído automáticamente."""
    user_id = getattr(current_user, 'id_alumno', None) or getattr(current_user, 'id_profesor', None) or getattr(current_user, 'id_personal', None)
    correo = db.query(Correo).filter(Correo.id == email_id).first()
    
    if not correo:
        raise HTTPException(status_code=404, detail="Correo no encontrado")
        
    # Seguridad: solo el remitente o el destinatario pueden leer el correo
    if correo.id_destinatario != user_id and correo.id_remitente != user_id:
        raise HTTPException(status_code=403, detail="No tienes permiso para leer este correo")
        
    # Si el usuario actual es el destinatario y no lo había leído, lo marcamos como leído
    if correo.id_destinatario == user_id and not correo.leido:
        correo.leido = True
        db.commit()
        db.refresh(correo)
        
    return correo