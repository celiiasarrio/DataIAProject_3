-- Esquema canónico del backend FastAPI.
-- Mantiene algunas tablas legacy (sesiones, ubicaciones) para compatibilidad
-- con los seeds existentes, pero añade todas las tablas y columnas que hoy
-- necesita la API.

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

CREATE TABLE IF NOT EXISTS asignaturas (
    id_asignatura VARCHAR PRIMARY KEY,
    nombre VARCHAR
);

CREATE TABLE IF NOT EXISTS ubicaciones (
    id_ubicacion VARCHAR PRIMARY KEY,
    descripcion TEXT,
    planta INT,
    aula VARCHAR
);

-- El Motor del Calendario
CREATE TABLE IF NOT EXISTS sesiones (
    id_sesion SERIAL PRIMARY KEY,
    fecha DATE,
    hora_inicio TIME,
    hora_fin TIME,
    id_ubicacion VARCHAR REFERENCES ubicaciones(id_ubicacion),
    id_asignatura VARCHAR REFERENCES asignaturas(id_asignatura),
    id_profesor VARCHAR REFERENCES profesores(id_profesor),
    descripcion TEXT
);

-- Tablas de Relaciones
CREATE TABLE IF NOT EXISTS rel_profesores_asignaturas (
    id_profesor VARCHAR REFERENCES profesores(id_profesor),
    id_asignatura VARCHAR REFERENCES asignaturas(id_asignatura),
    PRIMARY KEY (id_profesor, id_asignatura)
);

CREATE TABLE IF NOT EXISTS rel_alumnos_grupos (
    id_alumno VARCHAR REFERENCES alumnos(id_alumno),
    id_grupo VARCHAR REFERENCES grupos(id_grupo),
    PRIMARY KEY (id_alumno, id_grupo)
);

CREATE TABLE IF NOT EXISTS rel_asignaturas_grupos (
    id_asignatura VARCHAR REFERENCES asignaturas(id_asignatura),
    id_grupo VARCHAR REFERENCES grupos(id_grupo),
    PRIMARY KEY (id_asignatura, id_grupo)
);

CREATE TABLE IF NOT EXISTS rel_personal_grupos (
    id_personal VARCHAR REFERENCES personal_edem(id_personal),
    id_grupo VARCHAR REFERENCES grupos(id_grupo),
    PRIMARY KEY (id_personal, id_grupo)
);

-- Funcionalidades Extra
CREATE TABLE IF NOT EXISTS tareas (
    id_tarea SERIAL PRIMARY KEY,
    id_asignatura VARCHAR REFERENCES asignaturas(id_asignatura),
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
    id_sesion INT REFERENCES sesiones(id_sesion),
    id_asignatura VARCHAR REFERENCES asignaturas(id_asignatura),
    fecha DATE,
    presente BOOLEAN
);

CREATE TABLE IF NOT EXISTS eventos (
    id VARCHAR PRIMARY KEY,
    tipo VARCHAR,
    titulo VARCHAR,
    id_asignatura VARCHAR REFERENCES asignaturas(id_asignatura),
    aula VARCHAR,
    id_profesor VARCHAR REFERENCES profesores(id_profesor),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    descripcion TEXT
);

CREATE TABLE IF NOT EXISTS franja_tutoria (
    id VARCHAR PRIMARY KEY,
    id_profesor VARCHAR REFERENCES profesores(id_profesor),
    id_asignatura VARCHAR REFERENCES asignaturas(id_asignatura),
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
    id_asignatura VARCHAR REFERENCES asignaturas(id_asignatura),
    id_profesor VARCHAR REFERENCES profesores(id_profesor),
    titulo VARCHAR,
    descripcion TEXT,
    tipo VARCHAR,
    url TEXT,
    fecha_subida TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
