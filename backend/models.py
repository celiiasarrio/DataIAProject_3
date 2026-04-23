from sqlalchemy import Column, Integer, String, Float, Boolean, Date, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.orm import declarative_base
from datetime import datetime

Base = declarative_base()

# --- ENTIDADES PRINCIPALES ---

class PersonalEdem(Base):
    __tablename__ = 'personal_edem'
    id_personal = Column(String, primary_key=True, index=True)
    nombre = Column(String)
    apellido = Column(String)
    correo = Column(String)
    contrasena = Column(String)
    rol = Column(String)
    url_foto = Column(String)

class Grupo(Base):
    __tablename__ = 'grupos'
    id_grupo = Column(String, primary_key=True, index=True)
    nombre = Column(String)

class Alumno(Base):
    __tablename__ = 'alumnos'
    id_alumno = Column(String, primary_key=True, index=True)
    nombre = Column(String)
    apellido = Column(String)
    correo = Column(String)
    contrasena = Column(String)
    url_foto = Column(String)

class Sesion(Base):
    __tablename__ = 'sesiones'
    id_sesion = Column(String, primary_key=True, index=True)
    nombre = Column(String)

class Profesor(Base):
    __tablename__ = 'profesores'
    id_profesor = Column(String, primary_key=True, index=True)
    nombre = Column(String)
    apellido = Column(String)
    correo = Column(String)
    contrasena = Column(String)
    url_foto = Column(String)

class Tarea(Base):
    __tablename__ = 'tareas'
    id_tarea = Column(Integer, primary_key=True, autoincrement=True, index=True)
    id_sesion = Column(String, ForeignKey('sesiones.id_sesion'))
    nombre = Column(String)
    descripcion = Column(String)

class Asistencia(Base):
    __tablename__ = 'asistencia'
    __table_args__ = (
        UniqueConstraint('id_alumno', 'id_sesion', 'fecha', name='uq_asistencia_alumno_sesion_fecha'),
    )

    id_asistencia = Column(Integer, primary_key=True, autoincrement=True, index=True)
    id_alumno = Column(String, ForeignKey('alumnos.id_alumno'))
    id_sesion = Column(String, ForeignKey('sesiones.id_sesion'))
    fecha = Column(Date)
    presente = Column(Boolean)

# --- TABLAS DE RELACIÓN (Muchos a Muchos) ---

class RelPersonalGrupos(Base):
    __tablename__ = 'rel_personal_grupos'
    id_personal = Column(String, ForeignKey('personal_edem.id_personal'), primary_key=True)
    id_grupo = Column(String, ForeignKey('grupos.id_grupo'), primary_key=True)

class RelAlumnosGrupos(Base):
    __tablename__ = 'rel_alumnos_grupos'
    id_alumno = Column(String, ForeignKey('alumnos.id_alumno'), primary_key=True)
    id_grupo = Column(String, ForeignKey('grupos.id_grupo'), primary_key=True)

class RelSesionesGrupos(Base):
    __tablename__ = 'rel_sesiones_grupos'
    id_sesion = Column(String, ForeignKey('sesiones.id_sesion'), primary_key=True)
    id_grupo = Column(String, ForeignKey('grupos.id_grupo'), primary_key=True)

class RelProfesoresSesiones(Base):
    __tablename__ = 'rel_profesores_sesiones'
    id_profesor = Column(String, ForeignKey('profesores.id_profesor'), primary_key=True)
    id_sesion = Column(String, ForeignKey('sesiones.id_sesion'), primary_key=True)

class RelAlumnoTarea(Base):
    __tablename__ = 'rel_alumno_tarea'
    id_alumno = Column(String, ForeignKey('alumnos.id_alumno'), primary_key=True)
    id_tarea = Column(Integer, ForeignKey('tareas.id_tarea'), primary_key=True)
    nota = Column(Float) # Nota añadida a la tabla intermedia como indica el diagrama

# --- MODELOS ADICIONALES (Calendario, Tutorías, Notificaciones, Correos) ---

class Evento(Base):
    __tablename__ = 'eventos'
    id = Column(String, primary_key=True, index=True)
    tipo = Column(String)  # 'class', 'exam', 'delivery'
    titulo = Column(String)
    id_sesion = Column(String, ForeignKey('sesiones.id_sesion'))
    aula = Column(String)
    id_profesor = Column(String, ForeignKey('profesores.id_profesor'))
    fecha_inicio = Column(DateTime)
    fecha_fin = Column(DateTime)
    descripcion = Column(String)

class FranjaTutoria(Base):
    __tablename__ = 'franja_tutoria'
    id = Column(String, primary_key=True, index=True)
    id_profesor = Column(String, ForeignKey('profesores.id_profesor'))
    id_sesion = Column(String, ForeignKey('sesiones.id_sesion'), nullable=True)
    dia_semana = Column(Integer)  # 0=Lunes, 1=Martes, etc.
    hora_inicio = Column(String)  # HH:MM
    hora_fin = Column(String)     # HH:MM
    ubicacion = Column(String)
    disponible = Column(Boolean, default=True)

class Reserva(Base):
    __tablename__ = 'reservas'
    id = Column(String, primary_key=True, index=True)
    id_alumno = Column(String, ForeignKey('alumnos.id_alumno'))
    id_profesor = Column(String, ForeignKey('profesores.id_profesor'))
    id_franja = Column(String, ForeignKey('franja_tutoria.id'))
    fecha = Column(Date)
    notas = Column(String, nullable=True)
    estado = Column(String, default='pending')  # 'pending', 'confirmed', 'rejected', 'completed'
    fecha_creacion = Column(DateTime, default=datetime.utcnow)

class Notificacion(Base):
    __tablename__ = 'notificaciones'
    id = Column(String, primary_key=True, index=True)
    id_usuario = Column(String)  # Puede ser alumno, profesor o personal
    tipo = Column(String)
    titulo = Column(String)
    mensaje = Column(String)
    leida = Column(Boolean, default=False)
    fecha_creacion = Column(DateTime, default=datetime.utcnow)

class ConfiguracionNotificacion(Base):
    __tablename__ = 'configuracion_notificaciones'
    id_usuario = Column(String, primary_key=True, index=True)
    avisos_calendario = Column(Boolean, default=True)
    avisos_notas = Column(Boolean, default=True)
    avisos_asistencia = Column(Boolean, default=True)

class Correo(Base):
    __tablename__ = 'correos'
    id = Column(String, primary_key=True, index=True)
    id_remitente = Column(String)  # Puede ser cualquier usuario
    id_destinatario = Column(String)  # Puede ser cualquier usuario
    asunto = Column(String)
    cuerpo = Column(String)
    leido = Column(Boolean, default=False)
    fecha_envio = Column(DateTime, default=datetime.utcnow)

class Contenido(Base):
    __tablename__ = 'contenidos'
    id = Column(String, primary_key=True, index=True)
    id_sesion = Column(String, ForeignKey('sesiones.id_sesion'))
    id_profesor = Column(String, ForeignKey('profesores.id_profesor'))
    titulo = Column(String)
    descripcion = Column(String, nullable=True)
    tipo = Column(String)  # 'pdf', 'video', 'enlace', 'otro'
    url = Column(String)
    fecha_subida = Column(DateTime, default=datetime.utcnow)
