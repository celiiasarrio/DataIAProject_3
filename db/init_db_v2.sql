-- la v2 modifica la tabla sesiones para insertar hora_inicio y hora_fin.

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
    url_foto VARCHAR
);

CREATE TABLE IF NOT EXISTS personal_edem (
    id_personal VARCHAR PRIMARY KEY,
    nombre VARCHAR,
    apellido VARCHAR,
    correo VARCHAR,
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
    presente BOOLEAN
);