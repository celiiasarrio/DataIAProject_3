CREATE TABLE IF NOT EXISTS users (
    id_user        VARCHAR PRIMARY KEY,
    email          VARCHAR UNIQUE NOT NULL,
    password_hash  VARCHAR NOT NULL,
    rol            VARCHAR NOT NULL
                   CHECK (rol IN ('alumno','profesor','coordinador','director_area')),
    is_active      BOOLEAN DEFAULT TRUE,
    fecha_alta     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_login    TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

CREATE TABLE IF NOT EXISTS alumno_profile (
    id_user   VARCHAR PRIMARY KEY REFERENCES users(id_user) ON DELETE CASCADE,
    id_alumno VARCHAR UNIQUE NOT NULL REFERENCES alumnos(id_alumno)
);

CREATE TABLE IF NOT EXISTS profesor_profile (
    id_user     VARCHAR PRIMARY KEY REFERENCES users(id_user) ON DELETE CASCADE,
    id_profesor VARCHAR UNIQUE NOT NULL REFERENCES profesores(id_profesor)
);

CREATE TABLE IF NOT EXISTS staff_profile (
    id_user      VARCHAR PRIMARY KEY REFERENCES users(id_user) ON DELETE CASCADE,
    id_personal  VARCHAR UNIQUE NOT NULL REFERENCES personal_edem(id_personal),
    area         VARCHAR
);

-- ============================================================================
-- init_db_v5.sql
-- Capa de autenticación del EDEM Student Hub.
-- Depende de init_db_v2.sql (tablas alumnos, profesores, personal_edem).
-- Orden de ejecución: v2 -> v5.
-- ============================================================================
-- AUTENTICACIÓN Y PERFILES POR ROL
-- ----------------------------------------------------------------------------
-- users:           datos comunes de login (email, hash, rol, estado).
-- *_profile:       extiende users con los datos específicos de cada rol y
--                  enlaza con las tablas de dominio (alumnos, profesores,
--                  personal_edem) definidas en init_db_v2.sql.
--
-- Roles soportados: alumno, profesor, coordinador, director_area.
-- coordinador y director_area comparten staff_profile (se distinguen por area).
--
-- Integridad: ON DELETE CASCADE limpia el profile al borrar el user.
--             UNIQUE en id_alumno/id_profesor/id_personal evita que un mismo
--             miembro de EDEM tenga dos cuentas distintas.
-- ============================================================================