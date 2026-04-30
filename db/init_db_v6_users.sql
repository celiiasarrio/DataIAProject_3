-- ============================================================================
-- init_db_v6_users.sql
-- Pobla la tabla users desde las 3 tablas legacy (alumnos, profesores,
-- personal_edem). Equivalente al script Python scripts/seed_users.py pero
-- en SQL puro, idempotente, ejecutable como init script de Postgres.
--
-- Depende de: v2 (schema), v4 (seeds legacy), v5 (tablas de auth).
-- ============================================================================

-- pgcrypto da crypt() y gen_salt('bf') -> bcrypt compatible con Python bcrypt.
CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- ---------------- ALUMNOS ----------------
-- Crea un user por cada alumno con correo. Si la contraseña ya está hasheada
-- ($2b$...) la deja tal cual; si no, la pasa por bcrypt.
INSERT INTO users (id_user, email, password_hash, rol)
SELECT
    'usr_a_' || a.id_alumno,
    a.correo,
    CASE
        WHEN a.contrasena LIKE '$2b$%' THEN a.contrasena
        ELSE crypt(COALESCE(a.contrasena, 'demo'), gen_salt('bf'))
    END,
    'alumno'
FROM alumnos a
WHERE a.correo IS NOT NULL
ON CONFLICT (email) DO NOTHING;

INSERT INTO alumno_profile (id_user, id_alumno)
SELECT u.id_user, a.id_alumno
FROM alumnos a
JOIN users u ON u.email = a.correo AND u.rol = 'alumno'
ON CONFLICT (id_user) DO NOTHING;


-- ---------------- PROFESORES ----------------
INSERT INTO users (id_user, email, password_hash, rol)
SELECT
    'usr_p_' || p.id_profesor,
    p.correo,
    CASE
        WHEN p.contrasena LIKE '$2b$%' THEN p.contrasena
        ELSE crypt(COALESCE(p.contrasena, 'demo'), gen_salt('bf'))
    END,
    'profesor'
FROM profesores p
WHERE p.correo IS NOT NULL
ON CONFLICT (email) DO NOTHING;

INSERT INTO profesor_profile (id_user, id_profesor)
SELECT u.id_user, p.id_profesor
FROM profesores p
JOIN users u ON u.email = p.correo AND u.rol = 'profesor'
ON CONFLICT (id_user) DO NOTHING;


-- ---------------- PERSONAL EDEM ----------------
-- Mapea el campo libre rol a 'director_area' o 'coordinador'.
INSERT INTO users (id_user, email, password_hash, rol)
SELECT
    'usr_s_' || s.id_personal,
    s.correo,
    CASE
        WHEN s.contrasena LIKE '$2b$%' THEN s.contrasena
        ELSE crypt(COALESCE(s.contrasena, 'demo'), gen_salt('bf'))
    END,
    CASE
        WHEN LOWER(COALESCE(s.rol, '')) LIKE '%director%' THEN 'director_area'
        ELSE 'coordinador'
    END
FROM personal_edem s
WHERE s.correo IS NOT NULL
ON CONFLICT (email) DO NOTHING;

INSERT INTO staff_profile (id_user, id_personal, area)
SELECT u.id_user, s.id_personal, s.rol
FROM personal_edem s
JOIN users u ON u.email = s.correo AND u.rol IN ('coordinador', 'director_area')
ON CONFLICT (id_user) DO NOTHING;
