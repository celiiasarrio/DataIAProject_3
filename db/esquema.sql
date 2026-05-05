-- Esquema canonico del backend FastAPI.
-- Bloque = modulo docente amplio.
-- Sesion = clase concreta con fecha, hora y aula.

CREATE TABLE IF NOT EXISTS alumnos (
    id_alumno VARCHAR PRIMARY KEY,
    nombre VARCHAR,
    apellido1 VARCHAR,
    apellido2 VARCHAR,
    correo VARCHAR NOT NULL UNIQUE,
    contrasena VARCHAR NOT NULL,
    url_foto VARCHAR,
    rol VARCHAR NOT NULL DEFAULT 'Alumno',
    grupo VARCHAR
);

CREATE INDEX IF NOT EXISTS idx_alumnos_correo ON alumnos(correo);

CREATE TABLE IF NOT EXISTS profesores (
    id_profesor VARCHAR PRIMARY KEY,
    nombre VARCHAR NOT NULL,
    apellido VARCHAR NOT NULL,
    apellido2 VARCHAR,
    correo VARCHAR NOT NULL UNIQUE,
    contrasena VARCHAR NOT NULL,
    url_foto VARCHAR,
    rol VARCHAR NOT NULL DEFAULT 'Profesor'
);

CREATE INDEX IF NOT EXISTS idx_profesores_correo ON profesores(correo);

CREATE TABLE IF NOT EXISTS coordinadores (
    id_coordinador VARCHAR PRIMARY KEY,
    nombre VARCHAR NOT NULL,
    apellido VARCHAR NOT NULL,
    correo VARCHAR NOT NULL UNIQUE,
    contrasena VARCHAR NOT NULL,
    rol VARCHAR NOT NULL,
    url_foto VARCHAR
);

CREATE INDEX IF NOT EXISTS idx_personal_correo ON coordinadores(correo);

CREATE TABLE IF NOT EXISTS grupos (
    id_grupo VARCHAR PRIMARY KEY,
    nombre VARCHAR
);

CREATE TABLE IF NOT EXISTS bloques (
    id_bloque VARCHAR PRIMARY KEY,
    nombre VARCHAR NOT NULL
);

CREATE TABLE IF NOT EXISTS sesiones (
    id_sesion VARCHAR PRIMARY KEY,
    id_bloque VARCHAR NOT NULL REFERENCES bloques(id_bloque),
    nombre VARCHAR NOT NULL,
    fecha DATE,
    hora_inicio TIME,
    hora_fin TIME,
    edificio VARCHAR,
    planta VARCHAR,
    aula VARCHAR
);

CREATE INDEX IF NOT EXISTS idx_sesiones_bloque ON sesiones(id_bloque);
CREATE INDEX IF NOT EXISTS idx_sesiones_fecha ON sesiones(fecha);

CREATE TABLE IF NOT EXISTS ubicaciones (
    id_ubicacion VARCHAR PRIMARY KEY,
    descripcion TEXT NOT NULL,
    planta INT,
    aula VARCHAR
);

CREATE TABLE IF NOT EXISTS rel_profesores_bloques (
    id_profesor VARCHAR REFERENCES profesores(id_profesor),
    id_bloque VARCHAR REFERENCES bloques(id_bloque),
    PRIMARY KEY (id_profesor, id_bloque)
);

CREATE TABLE IF NOT EXISTS rel_alumnos_grupos (
    id_alumno VARCHAR REFERENCES alumnos(id_alumno),
    id_grupo VARCHAR REFERENCES grupos(id_grupo),
    PRIMARY KEY (id_alumno, id_grupo)
);

CREATE TABLE IF NOT EXISTS rel_bloques_grupos (
    id_bloque VARCHAR REFERENCES bloques(id_bloque),
    id_grupo VARCHAR REFERENCES grupos(id_grupo),
    PRIMARY KEY (id_bloque, id_grupo)
);

CREATE TABLE IF NOT EXISTS rel_coordinadores_grupos (
    id_coordinador VARCHAR REFERENCES coordinadores(id_coordinador),
    id_grupo VARCHAR REFERENCES grupos(id_grupo),
    PRIMARY KEY (id_coordinador, id_grupo)
);

CREATE TABLE IF NOT EXISTS tareas (
    id_tarea SERIAL PRIMARY KEY,
    id_bloque VARCHAR NOT NULL REFERENCES bloques(id_bloque),
    nombre VARCHAR NOT NULL,
    descripcion TEXT,
    fecha DATE
);

CREATE INDEX IF NOT EXISTS idx_tareas_bloque ON tareas(id_bloque);

CREATE TABLE IF NOT EXISTS rel_alumno_tarea (
    id_alumno VARCHAR REFERENCES alumnos(id_alumno),
    id_tarea INT REFERENCES tareas(id_tarea),
    nota NUMERIC(4,2) NOT NULL,
    PRIMARY KEY (id_alumno, id_tarea)
);

CREATE TABLE IF NOT EXISTS asistencia (
    id_asistencia SERIAL PRIMARY KEY,
    id_alumno VARCHAR NOT NULL,
    id_sesion VARCHAR NOT NULL REFERENCES sesiones(id_sesion),
    fecha DATE,
    presente BOOLEAN NOT NULL,
    CONSTRAINT uq_asistencia_alumno_sesion UNIQUE (id_alumno, id_sesion)
);

CREATE INDEX IF NOT EXISTS idx_asistencia_alumno ON asistencia(id_alumno);
CREATE INDEX IF NOT EXISTS idx_asistencia_sesion ON asistencia(id_sesion);

CREATE TABLE IF NOT EXISTS eventos (
    id VARCHAR PRIMARY KEY,
    tipo VARCHAR NOT NULL,
    titulo VARCHAR NOT NULL,
    id_bloque VARCHAR REFERENCES bloques(id_bloque),
    id_sesion VARCHAR REFERENCES sesiones(id_sesion),
    aula VARCHAR,
    id_profesor VARCHAR REFERENCES profesores(id_profesor),
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP NOT NULL,
    descripcion TEXT
);

CREATE INDEX IF NOT EXISTS idx_eventos_bloque ON eventos(id_bloque);
CREATE INDEX IF NOT EXISTS idx_eventos_sesion ON eventos(id_sesion);

CREATE TABLE IF NOT EXISTS franja_tutoria (
    id VARCHAR PRIMARY KEY,
    id_profesor VARCHAR NOT NULL REFERENCES profesores(id_profesor),
    id_bloque VARCHAR REFERENCES bloques(id_bloque),
    dia_semana INT NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    ubicacion VARCHAR NOT NULL,
    disponible BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS reservas (
    id VARCHAR PRIMARY KEY,
    id_alumno VARCHAR NOT NULL REFERENCES alumnos(id_alumno),
    id_profesor VARCHAR NOT NULL REFERENCES profesores(id_profesor),
    id_franja VARCHAR NOT NULL REFERENCES franja_tutoria(id),
    fecha DATE NOT NULL,
    notas TEXT,
    estado VARCHAR NOT NULL DEFAULT 'pending',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS notificaciones (
    id VARCHAR PRIMARY KEY,
    id_usuario VARCHAR NOT NULL,
    tipo VARCHAR NOT NULL,
    titulo VARCHAR NOT NULL,
    mensaje TEXT NOT NULL,
    leida BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS configuracion_notificaciones (
    id_usuario VARCHAR PRIMARY KEY,
    avisos_calendario BOOLEAN NOT NULL DEFAULT TRUE,
    avisos_notas BOOLEAN NOT NULL DEFAULT TRUE,
    avisos_asistencia BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS perfil_detalles (
    id_usuario VARCHAR PRIMARY KEY,
    telefono VARCHAR,
    ciudad VARCHAR,
    idioma_preferido VARCHAR,
    contacto_emergencia VARCHAR,
    correo_personal VARCHAR,
    linkedin VARCHAR,
    github VARCHAR,
    portfolio VARCHAR,
    preferencia_contacto VARCHAR,
    area_interes VARCHAR,
    stack_tecnologico TEXT,
    experiencia_actual TEXT,
    disponibilidad VARCHAR,
    preferencia_jornada VARCHAR,
    cv_url VARCHAR,
    cv_nombre VARCHAR,
    cv_fecha_subida TIMESTAMP,
    idioma_app VARCHAR NOT NULL DEFAULT 'es',
    notificaciones_email BOOLEAN NOT NULL DEFAULT TRUE,
    notificaciones_push BOOLEAN NOT NULL DEFAULT TRUE,
    visibilidad_profesional BOOLEAN NOT NULL DEFAULT TRUE,
    permitir_cv_empleabilidad BOOLEAN NOT NULL DEFAULT TRUE,
    permitir_links_profesores BOOLEAN NOT NULL DEFAULT TRUE,
    tema VARCHAR NOT NULL DEFAULT 'claro',
    estado VARCHAR NOT NULL DEFAULT 'Activo',
    ultimo_acceso TIMESTAMP,
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS perfil_documentos (
    id VARCHAR PRIMARY KEY,
    id_usuario VARCHAR NOT NULL,
    nombre VARCHAR NOT NULL,
    tipo VARCHAR NOT NULL,
    url VARCHAR NOT NULL,
    content_type VARCHAR NOT NULL,
    estado VARCHAR NOT NULL DEFAULT 'Subido',
    fecha_subida TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_perfil_documentos_id_usuario ON perfil_documentos(id_usuario);

CREATE TABLE IF NOT EXISTS correos (
    id VARCHAR PRIMARY KEY,
    id_remitente VARCHAR NOT NULL,
    id_destinatario VARCHAR NOT NULL,
    asunto VARCHAR NOT NULL,
    cuerpo TEXT NOT NULL,
    leido BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_envio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS contenidos (
    id VARCHAR PRIMARY KEY,
    id_bloque VARCHAR NOT NULL REFERENCES bloques(id_bloque),
    id_profesor VARCHAR NOT NULL REFERENCES profesores(id_profesor),
    titulo VARCHAR NOT NULL,
    descripcion TEXT,
    tipo VARCHAR NOT NULL,
    url TEXT NOT NULL,
    fecha_subida TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
