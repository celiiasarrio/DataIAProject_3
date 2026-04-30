-- ============================================================================
-- init_db_v5.sql
-- Capa de autenticación del EDEM Student Hub.
-- Depende de init_db_v2.sql (alumnos, profesores, personal_edem).
-- Orden de ejecución (docker-compose): v2 -> v4 -> v5 -> v6.
-- ----------------------------------------------------------------------------
-- users:        datos comunes de login (email, hash, rol, estado).
-- *_profile:    extiende users con datos por rol y enlaza con las tablas de
--               dominio (alumnos, profesores, personal_edem).
--
-- Roles soportados: alumno, profesor, coordinador, director_area.
-- coordinador y director_area comparten staff_profile (se distinguen por area).
--
-- Integridad: ON DELETE CASCADE limpia el profile al borrar el user.
--             UNIQUE en id_alumno/id_profesor/id_personal evita que un mismo
--             miembro de EDEM tenga dos cuentas distintas.
-- ============================================================================

CREATE TABLE IF NOT EXISTS users (
    id_user        VARCHAR PRIMARY KEY,
    email          VARCHAR NOT NULL UNIQUE,
    password_hash  VARCHAR NOT NULL,
    rol            VARCHAR NOT NULL
                   CHECK (rol IN ('alumno','profesor','coordinador','director_area')),
    is_active      BOOLEAN     NOT NULL DEFAULT TRUE,
    fecha_alta     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_login    TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_rol   ON users(rol);

CREATE TABLE IF NOT EXISTS alumno_profile (
    id_user   VARCHAR PRIMARY KEY REFERENCES users(id_user) ON DELETE CASCADE,
    id_alumno VARCHAR NOT NULL UNIQUE REFERENCES alumnos(id_alumno)
);

CREATE TABLE IF NOT EXISTS profesor_profile (
    id_user     VARCHAR PRIMARY KEY REFERENCES users(id_user) ON DELETE CASCADE,
    id_profesor VARCHAR NOT NULL UNIQUE REFERENCES profesores(id_profesor)
);

CREATE TABLE IF NOT EXISTS staff_profile (
    id_user        VARCHAR PRIMARY KEY REFERENCES users(id_user) ON DELETE CASCADE,
    id_coordinador VARCHAR NOT NULL UNIQUE REFERENCES coordinadores(id_coordinador),
    area           VARCHAR
);
