from datetime import datetime

from sqlalchemy import (
    Boolean,
    Column,
    Date,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Time,
    UniqueConstraint,
)
from sqlalchemy.orm import declarative_base

Base = declarative_base()


# --- ENTIDADES PRINCIPALES ---


class PersonalEdem(Base):
    __tablename__ = "personal_edem"

    id_personal = Column(String, primary_key=True, index=True)
    nombre = Column(String)
    apellido = Column(String)
    correo = Column(String)
    contrasena = Column(String)
    rol = Column(String)
    url_foto = Column(String)


class Grupo(Base):
    __tablename__ = "grupos"

    id_grupo = Column(String, primary_key=True, index=True)
    nombre = Column(String)


class Alumno(Base):
    __tablename__ = "alumnos"

    id_alumno = Column(String, primary_key=True, index=True)
    nombre = Column(String)
<<<<<<< Updated upstream
    apellido1 = Column(String)
=======
    apellido = Column(String)
>>>>>>> Stashed changes
    apellido2 = Column(String, nullable=True)
    correo = Column(String)
    contrasena = Column(String)
    url_foto = Column(String)

class Bloque(Base):
    """Concepto amplio: módulo/materia que agrupa sesiones, contenido, tareas y profesores."""
    __tablename__ = 'bloques'
    id_bloque = Column(String, primary_key=True, index=True)
    nombre = Column(String)

class Sesion(Base):
    """Encuentro específico: clase concreta con fecha, hora y aula."""
    __tablename__ = 'sesiones'
    id_sesion = Column(String, primary_key=True, index=True)
    id_bloque = Column(String, ForeignKey('bloques.id_bloque'))
    nombre = Column(String)
    fecha = Column(Date, nullable=True)
    hora_inicio = Column(String, nullable=True)
    hora_fin = Column(String, nullable=True)
    aula = Column(String, nullable=True)
    
        @property
    def apellido(self) -> str:
        return " ".join(part for part in [self.apellido1, self.apellido2] if part)

    @apellido.setter
    def apellido(self, value: str | None) -> None:
        if not value:
            self.apellido1 = None
            self.apellido2 = None
            return

        normalized = " ".join(value.split())
        if not normalized:
            self.apellido1 = None
            self.apellido2 = None
            return

        parts = normalized.split(maxsplit=1)
        self.apellido1 = parts[0]
        self.apellido2 = parts[1] if len(parts) > 1 else None

class Profesor(Base):
    __tablename__ = "profesores"

    id_profesor = Column(String, primary_key=True, index=True)
    nombre = Column(String)
    apellido = Column(String)
    correo = Column(String)
    contrasena = Column(String)
    url_foto = Column(String)


class Ubicacion(Base):
    __tablename__ = "ubicaciones"

    id_ubicacion = Column(String, primary_key=True, index=True)
    descripcion = Column(String)
    planta = Column(Integer)
    aula = Column(String)


class Tarea(Base):
    __tablename__ = "tareas"

    id_tarea = Column(Integer, primary_key=True, autoincrement=True, index=True)
    id_bloque = Column(String, ForeignKey('bloques.id_bloque'))
    nombre = Column(String)
    descripcion = Column(String)


class Asistencia(Base):
    __tablename__ = "asistencia"
    __table_args__ = (
        UniqueConstraint("id_alumno", "id_sesion", name="uq_asistencia_alumno_sesion"),
    )
    id_asistencia = Column(Integer, primary_key=True, autoincrement=True, index=True)
    id_alumno = Column(String, ForeignKey("alumnos.id_alumno"))
    id_sesion = Column(String, ForeignKey("sesiones.id_sesion"))
    fecha = Column(Date)
    presente = Column(Boolean)


# --- TABLAS DE RELACIÓN ---


class RelPersonalGrupos(Base):
    __tablename__ = "rel_personal_grupos"

    id_personal = Column(String, ForeignKey("personal_edem.id_personal"), primary_key=True)
    id_grupo = Column(String, ForeignKey("grupos.id_grupo"), primary_key=True)


class RelAlumnosGrupos(Base):
    __tablename__ = "rel_alumnos_grupos"

    id_alumno = Column(String, ForeignKey("alumnos.id_alumno"), primary_key=True)
    id_grupo = Column(String, ForeignKey("grupos.id_grupo"), primary_key=True)


class RelBloquesGrupos(Base):
    __tablename__ = 'rel_bloques_grupos'
    id_bloque = Column(String, ForeignKey('bloques.id_bloque'), primary_key=True)
    id_grupo = Column(String, ForeignKey('grupos.id_grupo'), primary_key=True)

class RelProfesoresBloques(Base):
    __tablename__ = 'rel_profesores_bloques'
    id_profesor = Column(String, ForeignKey('profesores.id_profesor'), primary_key=True)
    id_bloque = Column(String, ForeignKey('bloques.id_bloque'), primary_key=True)

class RelAlumnoTarea(Base):
    __tablename__ = 'rel_alumno_tarea'
    id_alumno = Column(String, ForeignKey('alumnos.id_alumno'), primary_key=True)
    id_tarea = Column(Integer, ForeignKey('tareas.id_tarea'), primary_key=True)
    nota = Column(Float)


class Evento(Base):
    __tablename__ = "eventos"

    id = Column(String, primary_key=True, index=True)
    tipo = Column(String)
    titulo = Column(String)
    id_bloque = Column(String, ForeignKey('bloques.id_bloque'))
    aula = Column(String)
    id_profesor = Column(String, ForeignKey("profesores.id_profesor"))
    fecha_inicio = Column(DateTime)
    fecha_fin = Column(DateTime)
    descripcion = Column(String)


class FranjaTutoria(Base):
    __tablename__ = "franja_tutoria"

    id = Column(String, primary_key=True, index=True)
    id_profesor = Column(String, ForeignKey('profesores.id_profesor'))
    id_bloque = Column(String, ForeignKey('bloques.id_bloque'), nullable=True)
    dia_semana = Column(Integer)  # 0=Lunes, 1=Martes, etc.
    hora_inicio = Column(String)  # HH:MM
    hora_fin = Column(String)     # HH:MM
    ubicacion = Column(String)
    disponible = Column(Boolean, default=True)


class Reserva(Base):
    __tablename__ = "reservas"

    id = Column(String, primary_key=True, index=True)
    id_alumno = Column(String, ForeignKey("alumnos.id_alumno"))
    id_profesor = Column(String, ForeignKey("profesores.id_profesor"))
    id_franja = Column(String, ForeignKey("franja_tutoria.id"))
    fecha = Column(Date)
    notas = Column(String, nullable=True)
    estado = Column(String, default="pending")
    fecha_creacion = Column(DateTime, default=datetime.utcnow)


class Notificacion(Base):
    __tablename__ = "notificaciones"

    id = Column(String, primary_key=True, index=True)
    id_usuario = Column(String)
    tipo = Column(String)
    titulo = Column(String)
    mensaje = Column(String)
    leida = Column(Boolean, default=False)
    fecha_creacion = Column(DateTime, default=datetime.utcnow)


class ConfiguracionNotificacion(Base):
    __tablename__ = "configuracion_notificaciones"

    id_usuario = Column(String, primary_key=True, index=True)
    avisos_calendario = Column(Boolean, default=True)
    avisos_notas = Column(Boolean, default=True)
    avisos_asistencia = Column(Boolean, default=True)


class Correo(Base):
    __tablename__ = "correos"

    id = Column(String, primary_key=True, index=True)
    id_remitente = Column(String)
    id_destinatario = Column(String)
    asunto = Column(String)
    cuerpo = Column(String)
    leido = Column(Boolean, default=False)
    fecha_envio = Column(DateTime, default=datetime.utcnow)


class Contenido(Base):
    __tablename__ = "contenidos"

    id = Column(String, primary_key=True, index=True)
    id_bloque = Column(String, ForeignKey('bloques.id_bloque'))
    id_profesor = Column(String, ForeignKey('profesores.id_profesor'))
    titulo = Column(String)
    descripcion = Column(String, nullable=True)
    tipo = Column(String)
    url = Column(String)
    fecha_subida = Column(DateTime, default=datetime.utcnow)
