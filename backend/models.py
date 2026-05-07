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
    Text,
    Time,
    UniqueConstraint,
)
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class Coordinador(Base):
    __tablename__ = "coordinadores"

    id_coordinador = Column(String, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    apellido = Column(String, nullable=False)
    correo = Column(String, nullable=False, unique=True, index=True)
    contrasena = Column(String, nullable=False)
    rol = Column(String, nullable=False, default="Coordinador")
    url_foto = Column(String, nullable=True)


class Grupo(Base):
    __tablename__ = "grupos"

    id_grupo = Column(String, primary_key=True, index=True)
    nombre = Column(String, nullable=False)


class Alumno(Base):
    __tablename__ = "alumnos"

    id_alumno = Column(String, primary_key=True, index=True)
    nombre = Column(String)
    apellido1 = Column(String)
    apellido2 = Column(String, nullable=True)
    correo = Column(String, nullable=False, unique=True, index=True)
    contrasena = Column(String, nullable=False)
    url_foto = Column(String, nullable=True)
    rol = Column(String, nullable=False, default="Alumno")
    grupo = Column(String, nullable=True)


class Profesor(Base):
    __tablename__ = "profesores"

    id_profesor = Column(String, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    apellido = Column(String, nullable=False)
    correo = Column(String, nullable=False, unique=True, index=True)
    contrasena = Column(String, nullable=False)
    url_foto = Column(String, nullable=True)
    rol = Column(String, nullable=False, default="Profesor")


class Bloque(Base):
    __tablename__ = "bloques"

    id_bloque = Column(String, primary_key=True, index=True)
    nombre = Column(String, nullable=False)


class Sesion(Base):
    __tablename__ = "sesiones"

    id_sesion = Column(String, primary_key=True, index=True)
    id_bloque = Column(String, ForeignKey("bloques.id_bloque"), nullable=False, index=True)
    nombre = Column(String, nullable=False)
    fecha = Column(Date, nullable=True, index=True)
    hora_inicio = Column(Time, nullable=True)
    hora_fin = Column(Time, nullable=True)
    edificio = Column(String, nullable=True)
    planta = Column(String, nullable=True)
    aula = Column(String, nullable=True)


class Ubicacion(Base):
    __tablename__ = "ubicaciones"

    id_ubicacion = Column(String, primary_key=True, index=True)
    descripcion = Column(String, nullable=False)
    planta = Column(Integer, nullable=True)
    aula = Column(String, nullable=True)


class Tarea(Base):
    __tablename__ = "tareas"

    id_tarea = Column(Integer, primary_key=True, autoincrement=True, index=True)
    id_bloque = Column(String, ForeignKey("bloques.id_bloque"), nullable=False, index=True)
    nombre = Column(String, nullable=False)
    descripcion = Column(Text, nullable=True)
    fecha = Column(Date, nullable=True)


class Asistencia(Base):
    __tablename__ = "asistencia"
    __table_args__ = (
        UniqueConstraint("id_alumno", "id_sesion", name="uq_asistencia_alumno_sesion"),
    )

    id_asistencia = Column(Integer, primary_key=True, autoincrement=True, index=True)
    id_alumno = Column(String, nullable=False, index=True)
    id_sesion = Column(String, ForeignKey("sesiones.id_sesion"), nullable=False, index=True)
    fecha = Column(Date, nullable=True)
    presente = Column(Boolean, nullable=False, default=True)


class RelCoordinadoresGrupos(Base):
    __tablename__ = "rel_coordinadores_grupos"

    id_coordinador = Column(String, ForeignKey("coordinadores.id_coordinador"), primary_key=True)
    id_grupo = Column(String, ForeignKey("grupos.id_grupo"), primary_key=True)


RelPersonalGrupos = RelCoordinadoresGrupos


class RelAlumnosGrupos(Base):
    __tablename__ = "rel_alumnos_grupos"

    id_alumno = Column(String, ForeignKey("alumnos.id_alumno"), primary_key=True)
    id_grupo = Column(String, ForeignKey("grupos.id_grupo"), primary_key=True)


class RelBloquesGrupos(Base):
    __tablename__ = "rel_bloques_grupos"

    id_bloque = Column(String, ForeignKey("bloques.id_bloque"), primary_key=True)
    id_grupo = Column(String, ForeignKey("grupos.id_grupo"), primary_key=True)


class RelProfesoresBloques(Base):
    __tablename__ = "rel_profesores_bloques"

    id_profesor = Column(String, ForeignKey("profesores.id_profesor"), primary_key=True)
    id_bloque = Column(String, ForeignKey("bloques.id_bloque"), primary_key=True)


class RelAlumnoTarea(Base):
    __tablename__ = "rel_alumno_tarea"

    id_alumno = Column(String, ForeignKey("alumnos.id_alumno"), primary_key=True)
    id_tarea = Column(Integer, ForeignKey("tareas.id_tarea"), primary_key=True)
    nota = Column(Float, nullable=False)


class Evento(Base):
    __tablename__ = "eventos"

    id = Column(String, primary_key=True, index=True)
    tipo = Column(String, nullable=False)
    titulo = Column(String, nullable=False)
    id_bloque = Column(String, ForeignKey("bloques.id_bloque"), nullable=True, index=True)
    id_sesion = Column(String, ForeignKey("sesiones.id_sesion"), nullable=True, index=True)
    aula = Column(String, nullable=True)
    id_profesor = Column(String, ForeignKey("profesores.id_profesor"), nullable=True, index=True)
    fecha_inicio = Column(DateTime, nullable=False)
    fecha_fin = Column(DateTime, nullable=False)
    descripcion = Column(Text, nullable=True)


class FranjaTutoria(Base):
    __tablename__ = "franja_tutoria"

    id = Column(String, primary_key=True, index=True)
    id_profesor = Column(String, ForeignKey("profesores.id_profesor"), nullable=False, index=True)
    id_bloque = Column(String, ForeignKey("bloques.id_bloque"), nullable=True, index=True)
    dia_semana = Column(Integer, nullable=False)
    hora_inicio = Column(Time, nullable=False)
    hora_fin = Column(Time, nullable=False)
    ubicacion = Column(String, nullable=False)
    disponible = Column(Boolean, default=True, nullable=False)


class Reserva(Base):
    __tablename__ = "reservas"

    id = Column(String, primary_key=True, index=True)
    id_alumno = Column(String, ForeignKey("alumnos.id_alumno"), nullable=False, index=True)
    id_profesor = Column(String, ForeignKey("profesores.id_profesor"), nullable=False, index=True)
    id_franja = Column(String, ForeignKey("franja_tutoria.id"), nullable=False, index=True)
    fecha = Column(Date, nullable=False)
    notas = Column(Text, nullable=True)
    estado = Column(String, default="pending", nullable=False)
    fecha_creacion = Column(DateTime, default=datetime.utcnow, nullable=False)


class Notificacion(Base):
    __tablename__ = "notificaciones"

    id = Column(String, primary_key=True, index=True)
    id_usuario = Column(String, nullable=False, index=True)
    tipo = Column(String, nullable=False)
    titulo = Column(String, nullable=False)
    mensaje = Column(Text, nullable=False)
    leida = Column(Boolean, default=False, nullable=False)
    fecha_creacion = Column(DateTime, default=datetime.utcnow, nullable=False)


class ConfiguracionNotificacion(Base):
    __tablename__ = "configuracion_notificaciones"

    id_usuario = Column(String, primary_key=True, index=True)
    avisos_calendario = Column(Boolean, default=True, nullable=False)
    avisos_notas = Column(Boolean, default=True, nullable=False)
    avisos_asistencia = Column(Boolean, default=True, nullable=False)


class PerfilDetalle(Base):
    __tablename__ = "perfil_detalles"

    id_usuario = Column(String, primary_key=True, index=True)
    telefono = Column(String, nullable=True)
    ciudad = Column(String, nullable=True)
    idioma_preferido = Column(String, nullable=True)
    contacto_emergencia = Column(String, nullable=True)
    correo_personal = Column(String, nullable=True)
    linkedin = Column(String, nullable=True)
    github = Column(String, nullable=True)
    portfolio = Column(String, nullable=True)
    preferencia_contacto = Column(String, nullable=True)
    area_interes = Column(String, nullable=True)
    stack_tecnologico = Column(Text, nullable=True)
    experiencia_actual = Column(Text, nullable=True)
    disponibilidad = Column(String, nullable=True)
    preferencia_jornada = Column(String, nullable=True)
    cv_url = Column(String, nullable=True)
    cv_nombre = Column(String, nullable=True)
    cv_fecha_subida = Column(DateTime, nullable=True)
    idioma_app = Column(String, default="es", nullable=False)
    notificaciones_email = Column(Boolean, default=True, nullable=False)
    notificaciones_push = Column(Boolean, default=True, nullable=False)
    visibilidad_profesional = Column(Boolean, default=True, nullable=False)
    permitir_cv_empleabilidad = Column(Boolean, default=True, nullable=False)
    permitir_links_profesores = Column(Boolean, default=True, nullable=False)
    tema = Column(String, default="claro", nullable=False)
    estado = Column(String, default="Activo", nullable=False)
    ultimo_acceso = Column(DateTime, nullable=True)
    fecha_actualizacion = Column(DateTime, default=datetime.utcnow, nullable=False)


class PerfilDocumento(Base):
    __tablename__ = "perfil_documentos"

    id = Column(String, primary_key=True, index=True)
    id_usuario = Column(String, nullable=False, index=True)
    nombre = Column(String, nullable=False)
    tipo = Column(String, nullable=False)
    url = Column(String, nullable=False)
    content_type = Column(String, nullable=False)
    estado = Column(String, default="Subido", nullable=False)
    fecha_subida = Column(DateTime, default=datetime.utcnow, nullable=False)


class Correo(Base):
    __tablename__ = "correos"

    id = Column(String, primary_key=True, index=True)
    id_remitente = Column(String, nullable=False, index=True)
    id_destinatario = Column(String, nullable=False, index=True)
    asunto = Column(String, nullable=False)
    cuerpo = Column(Text, nullable=False)
    leido = Column(Boolean, default=False, nullable=False)
    fecha_envio = Column(DateTime, default=datetime.utcnow, nullable=False)


class Contenido(Base):
    __tablename__ = "contenidos"

    id = Column(String, primary_key=True, index=True)
    id_bloque = Column(String, ForeignKey("bloques.id_bloque"), nullable=False, index=True)
    id_profesor = Column(String, ForeignKey("profesores.id_profesor"), nullable=False, index=True)
    titulo = Column(String, nullable=False)
    descripcion = Column(Text, nullable=True)
    tipo = Column(String, nullable=False)
    url = Column(String, nullable=False)
    fecha_subida = Column(DateTime, default=datetime.utcnow, nullable=False)
