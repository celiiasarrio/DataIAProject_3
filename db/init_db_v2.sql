-- Esquema canónico del backend FastAPI.
-- Bloque = concepto amplio (módulo/materia que agrupa sesiones, contenido, tareas y profesores).
-- Sesion = encuentro específico (clase concreta con fecha, hora y aula).
-- Se mantiene "ubicaciones" por compatibilidad con los seeds existentes.

-- Tablas Principales
CREATE TABLE IF NOT EXISTS alumnos (
    id_alumno VARCHAR PRIMARY KEY,
    nombre VARCHAR,
    apellido VARCHAR,
    correo VARCHAR,
    contrasena VARCHAR,
    url_foto VARCHAR
);

CREATE TABLE IF NOT EXISTS profesores (
    id_profesor VARCHAR PRIMARY KEY,
    nombre VARCHAR,
    apellido VARCHAR,
    correo VARCHAR,
    contrasena VARCHAR,
    url_foto VARCHAR
);

CREATE TABLE IF NOT EXISTS personal_edem (
    id_personal VARCHAR PRIMARY KEY,
    nombre VARCHAR,
    apellido VARCHAR,
    correo VARCHAR,
    contrasena VARCHAR,
    rol VARCHAR,
    url_foto VARCHAR
);

CREATE TABLE IF NOT EXISTS grupos (
    id_grupo VARCHAR PRIMARY KEY,
    nombre VARCHAR
);

CREATE TABLE IF NOT EXISTS bloques (
    id_bloque VARCHAR PRIMARY KEY,
    nombre VARCHAR
);

CREATE TABLE IF NOT EXISTS sesiones (
    id_sesion VARCHAR PRIMARY KEY,
    id_bloque VARCHAR REFERENCES bloques(id_bloque),
    nombre VARCHAR,
    fecha DATE,
    hora_inicio VARCHAR,
    hora_fin VARCHAR,
    aula VARCHAR
);

CREATE TABLE IF NOT EXISTS ubicaciones (
    id_ubicacion VARCHAR PRIMARY KEY,
    descripcion TEXT,
    planta INT,
    aula VARCHAR
);

-- Tablas de Relaciones
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

CREATE TABLE IF NOT EXISTS rel_personal_grupos (
    id_personal VARCHAR REFERENCES personal_edem(id_personal),
    id_grupo VARCHAR REFERENCES grupos(id_grupo),
    PRIMARY KEY (id_personal, id_grupo)
);

-- Funcionalidades Extra
CREATE TABLE IF NOT EXISTS tareas (
    id_tarea SERIAL PRIMARY KEY,
    id_bloque VARCHAR REFERENCES bloques(id_bloque),
    nombre VARCHAR,
    descripcion TEXT
);

CREATE TABLE IF NOT EXISTS rel_alumno_tarea (
    id_alumno VARCHAR REFERENCES alumnos(id_alumno),
    id_tarea INT REFERENCES tareas(id_tarea),
    nota NUMERIC(4,2),
    PRIMARY KEY (id_alumno, id_tarea)
);

CREATE TABLE IF NOT EXISTS asistencia (
    id_asistencia SERIAL PRIMARY KEY,
    id_alumno VARCHAR REFERENCES alumnos(id_alumno),
    id_sesion VARCHAR REFERENCES sesiones(id_sesion),
    fecha DATE,
    presente BOOLEAN,
    CONSTRAINT uq_asistencia_alumno_sesion_fecha UNIQUE (id_alumno, id_sesion, fecha)
);

CREATE TABLE IF NOT EXISTS eventos (
    id VARCHAR PRIMARY KEY,
    tipo VARCHAR,
    titulo VARCHAR,
    id_bloque VARCHAR REFERENCES bloques(id_bloque),
    aula VARCHAR,
    id_profesor VARCHAR REFERENCES profesores(id_profesor),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    descripcion TEXT
);

CREATE TABLE IF NOT EXISTS franja_tutoria (
    id VARCHAR PRIMARY KEY,
    id_profesor VARCHAR REFERENCES profesores(id_profesor),
    id_bloque VARCHAR REFERENCES bloques(id_bloque),
    dia_semana INT,
    hora_inicio VARCHAR,
    hora_fin VARCHAR,
    ubicacion VARCHAR,
    disponible BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS reservas (
    id VARCHAR PRIMARY KEY,
    id_alumno VARCHAR REFERENCES alumnos(id_alumno),
    id_profesor VARCHAR REFERENCES profesores(id_profesor),
    id_franja VARCHAR REFERENCES franja_tutoria(id),
    fecha DATE,
    notas TEXT,
    estado VARCHAR DEFAULT 'pending',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS notificaciones (
    id VARCHAR PRIMARY KEY,
    id_usuario VARCHAR,
    tipo VARCHAR,
    titulo VARCHAR,
    mensaje TEXT,
    leida BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS configuracion_notificaciones (
    id_usuario VARCHAR PRIMARY KEY,
    avisos_calendario BOOLEAN DEFAULT TRUE,
    avisos_notas BOOLEAN DEFAULT TRUE,
    avisos_asistencia BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS correos (
    id VARCHAR PRIMARY KEY,
    id_remitente VARCHAR,
    id_destinatario VARCHAR,
    asunto VARCHAR,
    cuerpo TEXT,
    leido BOOLEAN DEFAULT FALSE,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS contenidos (
    id VARCHAR PRIMARY KEY,
    id_bloque VARCHAR REFERENCES bloques(id_bloque),
    id_profesor VARCHAR REFERENCES profesores(id_profesor),
    titulo VARCHAR,
    descripcion TEXT,
    tipo VARCHAR,
    url TEXT,
    fecha_subida TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
