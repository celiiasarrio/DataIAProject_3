-- Seed local/manual. Mantiene alumnos personalizados y reutiliza el catálogo canónico.

TRUNCATE TABLE
    alumnos,
    profesores,
    coordinadores,
    grupos,
    bloques,
    sesiones,
    ubicaciones,
    rel_profesores_bloques,
    rel_alumnos_grupos,
    rel_bloques_grupos,
    rel_coordinadores_grupos,
    tareas,
    rel_alumno_tarea,
    asistencia,
    eventos,
    franja_tutoria,
    reservas,
    notificaciones,
    configuracion_notificaciones,
    correos,
    contenidos
RESTART IDENTITY CASCADE;

INSERT INTO "alumnos" ("id_alumno", "nombre", "apellido", "apellido2", "correo", "contrasena", "url_foto", "rol") VALUES
('daadgi', 'Daniel', 'Adam', 'Giménez', 'daadgi@edem.es', 'Da7!kLm92Q', '', 'Alumno'),
('joallu', 'Jorge', 'Albalat', 'Luengo', 'joallu@edem.es', 'Jo4#vRt81P', '', 'Alumno'),
('gebaad', 'Gemma', 'Balaguer', 'Adell', 'gebaad@edem.es', 'Ge9$uNx34L', '', 'Alumno'),
('cabesa', 'Carlos', 'Beltrán', 'Sanz', 'cabesa@edem.es', 'Ca2@pWd67M', '', 'Alumno'),
('inbupe', 'Iñaki', 'Buj', 'Peris', 'inbupe@edem.es', 'In8!yQs53K', '', 'Alumno'),
('pagaes', 'Pau', 'García', 'Esparter', 'pagaes@edem.es', 'Pa6#zHt28R', '', 'Alumno'),
('maazlo', 'Marina', 'Azul', 'López', 'maazlo@edem.es', 'Ma3$eJv74N', '', 'Alumno'),
('jomama', 'Jorge', 'Martínez', 'Martínez', 'jomama@edem.es', 'Jo1@xBc95T', '', 'Alumno'),
('japlro', 'Javier', 'Plaza', 'Rosique', 'japlro@edem.es', 'Ja5!mYu46H', '', 'Alumno'),
('sareva', 'Salvador', 'Reche', 'Vázquez', 'sareva@edem.es', 'Sa7#nKi83D', '', 'Alumno'),
--('jogrhe', 'Jorge', 'Greus', 'Herrero', 'jogrhe@edem.es', 'Jo8$hPw52C', '', 'Alumno'),
('cesaco', 'Celia', 'Sarrió', 'Colomar', 'cesaco@edem.es', 'Ce4@tLq67B', '', 'Alumno'),
--('jaloru', 'Javier', 'Lopez', 'Ruiz', 'jaloru@edem.es', 'Ja9!rMx31F', '', 'Alumno'),
--('feorma', 'Felix', 'Ortuño', 'Martinez', 'feorma@edem.es', 'Fe2#vNd84S', '', 'Alumno');

INSERT INTO "profesores" ("id_profesor", "nombre", "apellido", "apellido2", "correo", "contrasena", "url_foto", 'rol') VALUES
('penipe', 'Pedro', 'Nieto', 'Pelaez', 'pedronietopelaez@gmail.com', 'PeNiPe2026!', '', 'Profesor');

INSERT INTO "coordinadores" ("id_coordinador", "nombre", "apellido", "correo", "contrasena", "url_foto", "rol") VALUES
('m.herrera', 'Miguel', 'Herrera', 'm.herrera@edem.es', 'MiHe2026!', '', 'Coordinador');

INSERT INTO "grupos" ("id_grupo") VALUES
('MDA A 2526'),
('MIA 2526');

INSERT INTO "bloques" ("id_bloque", "nombre") VALUES
('1-MDA', 'B1. FUNDAMENTOS'),
('2-MDA', 'B2. TRATAMIENTO DEL DATO'),
('3-MDA', 'B3. ENTORNO CLOUD'),
('4-MDA', 'SOFT SKILLS'),
('5-MDA', 'DATA PROJECTS'),
('6-MDA', 'HACKATONES');

INSERT INTO "sesiones" ("id_sesion", "id_bloque", "nombre", "fecha", "hora_inicio", "hora_fin", "edificio", "planta", "aula") VALUES
-- B1. FUNDAMENTOS: Python, Git, Docker, SQL (EDEM PLANTA 1 AULA 102)
('SES-1',  'B1. FUNDAMENTOS', 'Introducción + Instalación de Software', '2025-09-29', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-2',  'B1. FUNDAMENTOS', 'Git',                                    '2025-09-30', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-3',  'B1. FUNDAMENTOS', 'Python',                                 '2025-10-01', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-4',  'B1. FUNDAMENTOS', 'Git',                                    '2025-10-02', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-5',  'B1. FUNDAMENTOS', 'Python',                                 '2025-10-06', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-6',  'B1. FUNDAMENTOS', 'Python',                                 '2025-10-07', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-7',  'B1. FUNDAMENTOS', 'Python',                                 '2025-10-08', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-8',  'B1. FUNDAMENTOS', 'Docker',                                 '2025-10-13', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-9',  'B1. FUNDAMENTOS', 'Linux',                                  '2025-10-14', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-10', 'B1. FUNDAMENTOS', 'Docker',                                 '2025-10-15', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-11', 'B1. FUNDAMENTOS', 'Docker',                                 '2025-10-16', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-12', 'B1. FUNDAMENTOS', 'SQL',                                    '2025-10-20', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-13', 'B1. FUNDAMENTOS', 'Docker Compose',                         '2025-10-21', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-14', 'B1. FUNDAMENTOS', 'SQL',                                    '2025-10-22', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-15', 'B1. FUNDAMENTOS', 'SQL',                                    '2025-10-23', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-16', 'B1. FUNDAMENTOS', 'Python',                                 '2025-10-27', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-17', 'B1. FUNDAMENTOS', 'E2E Módulo 0',                           '2025-10-28', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
-- B2. TRATAMIENTO DEL DATO: PySpark, Kafka, DBT... (LZD PLANTA 1 AULA 115)
('SES-18', 'B2. TRATAMIENTO DEL DATO', 'Intro Módulo + Origen del Dato', '2025-10-29', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-19', 'B2. TRATAMIENTO DEL DATO', 'Visualización de datos',        '2025-10-30', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-20', 'B2. TRATAMIENTO DEL DATO', 'Visualización de datos',        '2025-11-03', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-21', 'B2. TRATAMIENTO DEL DATO', 'Ingesta de Datos y NoSQL',      '2025-11-05', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-22', 'B2. TRATAMIENTO DEL DATO', 'Ingesta de Datos y NoSQL',      '2025-11-06', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-23', 'B2. TRATAMIENTO DEL DATO', 'Ingesta de Datos y NoSQL',      '2025-11-10', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-24', 'B2. TRATAMIENTO DEL DATO', 'DBT',                           '2025-11-11', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-25', 'B2. TRATAMIENTO DEL DATO', 'DBT',                           '2025-11-12', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-26', 'B2. TRATAMIENTO DEL DATO', 'Kafka',                         '2025-11-18', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-28', 'B2. TRATAMIENTO DEL DATO', 'Kafka avanzado',                '2025-11-21', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-29', 'B2. TRATAMIENTO DEL DATO', 'API Management',                '2025-11-24', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-30', 'B2. TRATAMIENTO DEL DATO', 'API Management',                '2025-11-25', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-31', 'B2. TRATAMIENTO DEL DATO', 'PySpark',                       '2025-11-26', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-32', 'B2. TRATAMIENTO DEL DATO', 'PySpark',                       '2025-11-27', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-33', 'B2. TRATAMIENTO DEL DATO', 'PySpark',                       '2025-12-01', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-34', 'B2. TRATAMIENTO DEL DATO', 'Blockchain',                    '2025-12-04', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-71', 'B2. TRATAMIENTO DEL DATO', 'Data Products',                 '2026-04-28', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-72', 'B2. TRATAMIENTO DEL DATO', 'Prototipado',                   '2026-04-29', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
-- B3. ENTORNO CLOUD: GCP, Terraform, Cloud Run, Agentes (LZD PLANTA 1 AULA 115)
('SES-36', 'B3. ENTORNO CLOUD', 'Cloud Intro',           '2025-12-11', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-37', 'B3. ENTORNO CLOUD', 'Certificaciones Cloud', '2025-12-15', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-38', 'B3. ENTORNO CLOUD', 'Terraform',             '2025-12-16', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-39', 'B3. ENTORNO CLOUD', 'GCP Project Setup',     '2025-12-17', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-40', 'B3. ENTORNO CLOUD', 'Terraform',             '2025-12-18', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-41', 'B3. ENTORNO CLOUD', 'Terraform',             '2026-01-07', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-42', 'B3. ENTORNO CLOUD', 'GCP Almacenamiento',    '2026-01-08', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-43', 'B3. ENTORNO CLOUD', 'GCP Almacenamiento',    '2026-01-12', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-44', 'B3. ENTORNO CLOUD', 'GCP Almacenamiento',    '2026-01-15', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-45', 'B3. ENTORNO CLOUD', 'GCP PubSub/DataFlow',   '2026-01-19', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-46', 'B3. ENTORNO CLOUD', 'GCP PubSub/DataFlow',   '2026-01-21', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-47', 'B3. ENTORNO CLOUD', 'GCP PubSub/DataFlow',   '2026-01-26', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-48', 'B3. ENTORNO CLOUD', 'GCP DataFlow',          '2026-01-27', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-49', 'B3. ENTORNO CLOUD', 'GCP DataFlow',          '2026-01-28', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-50', 'B3. ENTORNO CLOUD', 'GCP DataFlow',          '2026-01-29', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-52', 'B3. ENTORNO CLOUD', 'GCP Funciones',         '2026-02-03', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-53', 'B3. ENTORNO CLOUD', 'GCP Cloud Run',         '2026-02-04', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-54', 'B3. ENTORNO CLOUD', 'Gobierno del Dato',     '2026-02-05', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-56', 'B3. ENTORNO CLOUD', 'GCP Específicos',       '2026-02-10', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-57', 'B3. ENTORNO CLOUD', 'Git Actions',           '2026-02-11', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-58', 'B3. ENTORNO CLOUD', 'Calidad del Dato',      '2026-02-12', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-65', 'B3. ENTORNO CLOUD', 'Airflow',               '2026-03-23', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-66', 'B3. ENTORNO CLOUD', 'Agentes',               '2026-03-24', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-73', 'B3. ENTORNO CLOUD', 'Gen AI',                '2026-05-14', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
-- SOFT SKILLS: Autoconocimiento, Comunicación, Inteligencia Emocional... (EDEM PLANTA 2 AULA 202 / LZD)
('SES-59', 'SOFT SKILLS', 'Skills Autoconocimiento',               '2025-11-04', '09:00', '13:00', 'EDEM', 'PLANTA 1', 'AULA 101'),
('SES-60', 'SOFT SKILLS', 'Skills Comunicación',                   '2025-11-17', '15:30', '19:30', 'LZD',  'PLANTA 1', 'AULA 115'),
('SES-61', 'SOFT SKILLS', 'Skills Inteligencia Emocional',         '2025-11-19', '09:00', '13:00', 'EDEM', 'PLANTA 2', 'AULA 202'),
('SES-62', 'SOFT SKILLS', 'Skills Comunicación eficaz',            '2026-01-20', '09:00', '13:00', 'EDEM', 'PLANTA 2', 'AULA 202'),
('SES-64', 'SOFT SKILLS', 'Skills Productividad Sana',             '2026-02-18', '09:00', '13:00', 'EDEM', 'PLANTA 2', 'AULA 202'),
('SES-69', 'SOFT SKILLS', 'Skills Gestión de equipos y liderazgo', '2026-04-22', '09:00', '13:00', 'EDEM', 'PLANTA 2', 'AULA 202'),
('SES-70', 'SOFT SKILLS', 'Skills Comunicación',                   '2026-04-27', '15:30', '19:30', 'LZD',  'PLANTA 1', 'AULA 115'),
-- DATA PROJECTS: Lanzamientos y jornadas de trabajo de los Data Projects (LZD PLANTA 1 AULA 115)
('SES-27', 'DATA PROJECTS', 'Lanzamiento DP1 + E2E Módulo 1.1', '2025-11-20', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-35', 'DATA PROJECTS', 'E2E Módulo 1.2',                   '2025-12-09', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-51', 'DATA PROJECTS', 'Lanzamiento DP2',                   '2026-02-02', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-55', 'DATA PROJECTS', 'Jornada trabajo DP2',               '2026-02-09', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
-- HACKATONES (LZD PLANTA 1 AULA 115)
('SES-63', 'HACKATONES', 'Hackatón NTT Data', '2026-02-16', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-67', 'HACKATONES', 'Hackatón GFT',      '2026-03-25', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-68', 'HACKATONES', 'Hackatón GFT',      '2026-03-26', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115');

INSERT INTO "ubicaciones" ("id_ubicacion", "descripcion", "planta", "aula") VALUES
('UBI-101',    'EDEM, PLANTA 1, AULA 101',        1, 'AULA 101'),
('UBI-102',    'EDEM, PLANTA 1, AULA 102',        1, 'AULA 102'),
('UBI-202',    'EDEM, PLANTA 2, AULA 202',        2, 'AULA 202'),
('UBI-A01',    'EDEM, PLANTA BAJA, AUDITORIO 01', 0, 'AUDITORIO 01'),
('UBI-LZD115', 'LZD, PLANTA 1, AULA 115',        1, 'AULA 115');

INSERT INTO "rel_alumnos_grupos" ("id_alumno", "id_grupo") VALUES
('daadgi', 'GRP-003'),
('joallu', 'GRP-003'),
('gebaad', 'GRP-003'),
('cabesa', 'GRP-003'),
('inbupe', 'GRP-003'),
('pagaes', 'GRP-003'),
('maazlo', 'GRP-003'),
('jomama', 'GRP-006'),
('japlro', 'GRP-006'),
('sareva', 'GRP-006'),
('jogrhe', 'GRP-006'),
('cesaco', 'GRP-006'),
('jaloru', 'GRP-006'),
('feorma', 'GRP-006');

INSERT INTO "rel_bloques_grupos" ("id_bloque", "id_grupo") VALUES
('BLQ-101', 'GRP-003'),
('BLQ-101', 'GRP-006'),
('BLQ-102', 'GRP-003'),
('BLQ-102', 'GRP-006'),
('BLQ-103', 'GRP-003'),
('BLQ-104', 'GRP-006'),
('BLQ-105', 'GRP-006'),
('BLQ-106', 'GRP-003'),
('BLQ-106', 'GRP-006');

INSERT INTO "rel_profesores_bloques" ("id_profesor", "id_bloque") VALUES
('PROF-101', 'BLQ-101'),
('PROF-102', 'BLQ-102'),
('PROF-103', 'BLQ-103'),
('PROF-104', 'BLQ-104'),
('PROF-105', 'BLQ-105'),
('PROF-106', 'BLQ-106');

INSERT INTO "rel_coordinadores_grupos" ("id_coordinador", "id_grupo") VALUES
('PER-001', 'GRP-003'),
('PER-002', 'GRP-006');

INSERT INTO "tareas" ("id_tarea", "id_bloque", "nombre", "descripcion") VALUES
(1, 'BLQ-101', 'Notebook Python', 'Entrega individual de fundamentos de Python'),
(2, 'BLQ-102', 'Deploy en Cloud Run', 'Despliegue de una API en GCP'),
(3, 'BLQ-103', 'Pipeline PySpark', 'Transformación y limpieza de datos'),
(4, 'BLQ-104', 'Prototype de agente', 'Prototipo multiagente'),
(5, 'BLQ-105', 'Modelo de regresión', 'Entrega de regresión lineal'),
(6, 'BLQ-106', 'Pitch de comunicación', 'Presentación oral de proyecto');

INSERT INTO "rel_alumno_tarea" ("id_alumno", "id_tarea", "nota")
SELECT
    rag.id_alumno,
    t.id_tarea,
    ROUND((6 + ((ASCII(RIGHT(rag.id_alumno, 1)) % 4) * 0.7) + ((t.id_tarea % 3) * 0.4))::NUMERIC, 2)
FROM rel_alumnos_grupos rag
JOIN rel_bloques_grupos rbg ON rbg.id_grupo = rag.id_grupo
JOIN tareas t ON t.id_bloque = rbg.id_bloque;

INSERT INTO "asistencia" ("id_alumno", "id_sesion", "fecha", "presente")
SELECT
    rag.id_alumno,
    s.id_sesion,
    s.fecha,
    ((ASCII(RIGHT(rag.id_alumno, 1)) + ASCII(RIGHT(s.id_sesion, 1))) % 5) <> 0
FROM rel_alumnos_grupos rag
JOIN rel_bloques_grupos rbg ON rbg.id_grupo = rag.id_grupo
JOIN sesiones s ON s.id_bloque = rbg.id_bloque;

INSERT INTO "eventos" ("id", "tipo", "titulo", "id_bloque", "id_sesion", "aula", "id_profesor", "fecha_inicio", "fecha_fin", "descripcion") VALUES
('EVT-001', 'class', 'Clase Python 1', 'BLQ-101', 'SES-1011', 'AULA 101', 'PROF-101', '2026-05-04 09:00:00', '2026-05-04 11:00:00', 'Primera sesión de fundamentos'),
('EVT-002', 'class', 'Clase Cloud Run 1', 'BLQ-102', 'SES-1021', 'AULA 102', 'PROF-102', '2026-05-05 11:00:00', '2026-05-05 13:00:00', 'Sesión introductoria de despliegue'),
('EVT-003', 'delivery', 'Entrega deploy Cloud Run', 'BLQ-102', NULL, NULL, 'PROF-102', '2026-05-19 23:59:00', '2026-05-19 23:59:00', 'Fecha límite de entrega'),
('EVT-004', 'exam', 'Evaluación ML 1', 'BLQ-105', NULL, 'AULA 203', 'PROF-105', '2026-05-21 10:00:00', '2026-05-21 12:00:00', 'Prueba práctica de regresión'),
('EVT-005', 'class', 'Clase Agentes 1', 'BLQ-104', 'SES-1041', 'AULA 202', 'PROF-104', '2026-05-06 11:00:00', '2026-05-06 13:00:00', 'Arquitecturas de agentes'),
('EVT-006', 'class', 'Clase Comunicación 1', 'BLQ-106', 'SES-1061', 'AUDITORIO 01', 'PROF-106', '2026-05-08 09:00:00', '2026-05-08 11:00:00', 'Storytelling y comunicación');

INSERT INTO "franja_tutoria" ("id", "id_profesor", "id_bloque", "dia_semana", "hora_inicio", "hora_fin", "ubicacion", "disponible") VALUES
('TUT-001', 'PROF-105', 'BLQ-105', 2, '16:00', '17:00', 'AULA 203', TRUE),
('TUT-002', 'PROF-104', 'BLQ-104', 3, '17:00', '18:00', 'AULA 202', TRUE),
('TUT-003', 'PROF-101', 'BLQ-101', 1, '15:00', '16:00', 'AULA 101', TRUE);

INSERT INTO "reservas" ("id", "id_alumno", "id_profesor", "id_franja", "fecha", "notas", "estado", "fecha_creacion") VALUES
('RES-001', 'jogrhe', 'PROF-105', 'TUT-001', '2026-05-20', 'Revisar el modelo final', 'confirmed', '2026-05-18 10:00:00');

INSERT INTO "notificaciones" ("id", "id_usuario", "tipo", "titulo", "mensaje", "leida", "fecha_creacion") VALUES
('NOT-001', 'jogrhe', 'grades', 'Nueva nota publicada', 'Ya tienes disponible la nota del notebook de Python.', FALSE, '2026-05-12 09:00:00'),
('NOT-002', 'daadgi', 'attendance', 'Asistencia actualizada', 'Se ha actualizado tu asistencia de PySpark.', FALSE, '2026-05-13 12:00:00'),
('NOT-003', 'jomama', 'calendar', 'Nueva entrega', 'Recuerda la entrega de Cloud Run el 19 de mayo.', TRUE, '2026-05-14 08:30:00');

INSERT INTO "configuracion_notificaciones" ("id_usuario", "avisos_calendario", "avisos_notas", "avisos_asistencia")
SELECT id_alumno, TRUE, TRUE, TRUE
FROM alumnos;

INSERT INTO "correos" ("id", "id_remitente", "id_destinatario", "asunto", "cuerpo", "leido", "fecha_envio") VALUES
('MAIL-001', 'PER-001', 'jogrhe', 'Bienvenida al hub', 'Ya puedes acceder al portal y revisar tus bloques.', TRUE, '2026-05-01 09:00:00'),
('MAIL-002', 'jogrhe', 'PROF-105', 'Duda sobre la práctica', 'Quería revisar la última entrega antes de la tutoría.', FALSE, '2026-05-18 16:30:00');

INSERT INTO "contenidos" ("id", "id_bloque", "id_profesor", "titulo", "descripcion", "tipo", "url", "fecha_subida") VALUES
('CNT-001', 'BLQ-101', 'PROF-101', 'Guía de Python', 'Material base del bloque de Python.', 'pdf', 'https://example.com/python-guide.pdf', '2026-05-02 08:00:00'),
('CNT-002', 'BLQ-102', 'PROF-102', 'Slides Cloud Run', 'Presentación del despliegue en GCP.', 'slides', 'https://example.com/cloud-run-slides', '2026-05-03 08:00:00'),
('CNT-003', 'BLQ-104', 'PROF-104', 'Plantilla de agentes', 'Repositorio base del workshop.', 'repo', 'https://example.com/agents-template', '2026-05-05 08:00:00');
