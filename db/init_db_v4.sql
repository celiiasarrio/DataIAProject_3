-- Seed oficial de ejemplo para el esquema canónico.

TRUNCATE TABLE
    alumnos,
    profesores,
    personal_edem,
    grupos,
    bloques,
    sesiones,
    ubicaciones,
    rel_profesores_bloques,
    rel_alumnos_grupos,
    rel_bloques_grupos,
    rel_personal_grupos,
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

INSERT INTO "alumnos" ("id_alumno", "nombre", "apellido1", "apellido2", "correo", "contrasena", "url_foto") VALUES
('ALU-001', 'Ahsoka', 'Tano', NULL, 'ahsoka.tano@edem.es', 'demo123', 'https://ui-avatars.com/api/?name=Ahsoka%20Tano&size=200'),
('ALU-002', 'Aladdin', 'Ababwa', NULL, 'aladdin.ababwa@edem.es', 'demo123', 'https://ui-avatars.com/api/?name=Aladdin%20Ababwa&size=200'),
('ALU-003', 'Anakin', 'Skywalker', NULL, 'anakin.skywalker@edem.es', 'demo123', 'https://ui-avatars.com/api/?name=Anakin%20Skywalker&size=200'),
('ALU-004', 'Arya', 'Stark', NULL, 'arya.stark@edem.es', 'demo123', 'https://ui-avatars.com/api/?name=Arya%20Stark&size=200'),
('ALU-005', 'Leia', 'Organa', NULL, 'leia.organa@edem.es', 'demo123', 'https://ui-avatars.com/api/?name=Leia%20Organa&size=200'),
('ALU-006', 'Mirabel', 'Madrigal', NULL, 'mirabel.madrigal@edem.es', 'demo123', 'https://ui-avatars.com/api/?name=Mirabel%20Madrigal&size=200'),
('ALU-007', 'Frodo', 'Baggins', NULL, 'frodo.baggins@edem.es', 'demo123', 'https://ui-avatars.com/api/?name=Frodo%20Baggins&size=200'),
('ALU-008', 'Hermione', 'Granger', NULL, 'hermione.granger@edem.es', 'demo123', 'https://ui-avatars.com/api/?name=Hermione%20Granger&size=200');

INSERT INTO "profesores" ("id_profesor", "nombre", "apellido", "correo", "url_foto", "contrasena") VALUES
('PROF-101', 'Adriana', 'Campos', 'adriana.campos@seed.local', 'https://ui-avatars.com/api/?name=Adriana%20Campos&size=200', 'prof123'),
('PROF-102', 'Adrián', 'Colomer', 'adrian.colomer@seed.local', 'https://ui-avatars.com/api/?name=Adri%C3%A1n%20Colomer&size=200', 'prof123'),
('PROF-103', 'Fabio', 'Castro', 'fabio.castro@seed.local', 'https://ui-avatars.com/api/?name=Fabio%20Castro&size=200', 'prof123'),
('PROF-104', 'Nuria', 'Berzal', 'nuria.berzal@seed.local', 'https://ui-avatars.com/api/?name=Nuria%20Berzal&size=200', 'prof123'),
('PROF-105', 'Pedro', 'Nieto', 'pedro.nieto@seed.local', 'https://ui-avatars.com/api/?name=Pedro%20Nieto&size=200', 'prof123'),
('PROF-106', 'Ángel', 'Llosa', 'angel.llosa@seed.local', 'https://ui-avatars.com/api/?name=%C3%81ngel%20Llosa&size=200', 'prof123');

INSERT INTO "personal_edem" ("id_personal", "nombre", "apellido", "correo", "rol", "url_foto", "contrasena") VALUES
('PER-001', 'Andrea', 'Soler', 'andrea.soler@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Andrea%20Soler&size=200', 'staff123'),
('PER-002', 'Luis', 'Marín', 'luis.marin@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Luis%20Mar%C3%ADn&size=200', 'staff123');

INSERT INTO "grupos" ("id_grupo", "nombre") VALUES
('GRP-003', 'MDA A'),
('GRP-006', 'MIA');

INSERT INTO "bloques" ("id_bloque", "nombre") VALUES
('BLQ-101', 'FUNDAMENTOS: Python'),
('BLQ-102', 'ENTORNO CLOUD: GCP Cloud Run'),
('BLQ-103', 'TRATAMIENTO DEL DATO: PySpark'),
('BLQ-104', 'IA GENERATIVA: Agentes'),
('BLQ-105', 'IA PREDICTIVA: ML 1: Regresión'),
('BLQ-106', 'SKILLS: Comunicación');

INSERT INTO "sesiones" ("id_sesion", "id_bloque", "nombre", "fecha", "hora_inicio", "hora_fin", "aula") VALUES
('SES-1011', 'BLQ-101', 'Python para análisis de datos', '2026-05-04', '09:00', '11:00', 'AULA 101'),
('SES-1012', 'BLQ-101', 'Pandas y tratamiento tabular', '2026-05-11', '09:00', '11:00', 'AULA 101'),
('SES-1021', 'BLQ-102', 'Introducción a Cloud Run', '2026-05-05', '11:00', '13:00', 'AULA 102'),
('SES-1022', 'BLQ-102', 'Despliegue de APIs en GCP', '2026-05-12', '11:00', '13:00', 'AULA 102'),
('SES-1031', 'BLQ-103', 'PySpark DataFrames', '2026-05-06', '09:00', '11:00', 'AULA 201'),
('SES-1032', 'BLQ-103', 'ETL distribuido con PySpark', '2026-05-13', '09:00', '11:00', 'AULA 201'),
('SES-1041', 'BLQ-104', 'Arquitecturas de agentes', '2026-05-06', '11:00', '13:00', 'AULA 202'),
('SES-1042', 'BLQ-104', 'Workshop multiagente', '2026-05-13', '11:00', '13:00', 'AULA 202'),
('SES-1051', 'BLQ-105', 'Regresión lineal aplicada', '2026-05-07', '09:00', '11:00', 'AULA 203'),
('SES-1052', 'BLQ-105', 'Feature engineering', '2026-05-14', '09:00', '11:00', 'AULA 203'),
('SES-1061', 'BLQ-106', 'Storytelling de datos', '2026-05-08', '09:00', '11:00', 'AUDITORIO 01'),
('SES-1062', 'BLQ-106', 'Presentaciones efectivas', '2026-05-15', '09:00', '11:00', 'AUDITORIO 01');

INSERT INTO "ubicaciones" ("id_ubicacion", "descripcion", "planta", "aula") VALUES
('UBI-101', 'EDEM, PLANTA 1, AULA 101', 1, 'AULA 101'),
('UBI-102', 'EDEM, PLANTA 1, AULA 102', 1, 'AULA 102'),
('UBI-201', 'EDEM, PLANTA 2, AULA 201', 2, 'AULA 201'),
('UBI-A01', 'EDEM, PLANTA BAJA, AUDITORIO 01', 0, 'AUDITORIO 01');

INSERT INTO "rel_alumnos_grupos" ("id_alumno", "id_grupo") VALUES
('ALU-001', 'GRP-006'),
('ALU-002', 'GRP-006'),
('ALU-003', 'GRP-006'),
('ALU-005', 'GRP-006'),
('ALU-008', 'GRP-006'),
('ALU-004', 'GRP-003'),
('ALU-006', 'GRP-003'),
('ALU-007', 'GRP-003');

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

INSERT INTO "rel_personal_grupos" ("id_personal", "id_grupo") VALUES
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
('RES-001', (SELECT id_alumno FROM rel_alumnos_grupos WHERE id_grupo = 'GRP-006' ORDER BY id_alumno LIMIT 1), 'PROF-105', 'TUT-001', '2026-05-20', 'Revisar el modelo final', 'confirmed', '2026-05-18 10:00:00');

INSERT INTO "notificaciones" ("id", "id_usuario", "tipo", "titulo", "mensaje", "leida", "fecha_creacion") VALUES
('NOT-001', 'ALU-001', 'grades', 'Nueva nota publicada', 'Ya tienes disponible la nota del notebook de Python.', FALSE, '2026-05-12 09:00:00'),
('NOT-002', 'ALU-004', 'attendance', 'Asistencia actualizada', 'Se ha actualizado tu asistencia de PySpark.', FALSE, '2026-05-13 12:00:00'),
('NOT-003', 'ALU-002', 'calendar', 'Nueva entrega', 'Recuerda la entrega de Cloud Run el 19 de mayo.', TRUE, '2026-05-14 08:30:00');

INSERT INTO "configuracion_notificaciones" ("id_usuario", "avisos_calendario", "avisos_notas", "avisos_asistencia")
SELECT id_alumno, TRUE, TRUE, TRUE
FROM alumnos;

INSERT INTO "correos" ("id", "id_remitente", "id_destinatario", "asunto", "cuerpo", "leido", "fecha_envio") VALUES
('MAIL-001', 'PER-001', 'ALU-001', 'Bienvenida al hub', 'Ya puedes acceder al portal y revisar tus bloques.', TRUE, '2026-05-01 09:00:00'),
('MAIL-002', 'ALU-001', 'PROF-105', 'Duda sobre la práctica', 'Quería revisar la última entrega antes de la tutoría.', FALSE, '2026-05-18 16:30:00');

INSERT INTO "contenidos" ("id", "id_bloque", "id_profesor", "titulo", "descripcion", "tipo", "url", "fecha_subida") VALUES
('CNT-001', 'BLQ-101', 'PROF-101', 'Guía de Python', 'Material base del bloque de Python.', 'pdf', 'https://example.com/python-guide.pdf', '2026-05-02 08:00:00'),
('CNT-002', 'BLQ-102', 'PROF-102', 'Slides Cloud Run', 'Presentación del despliegue en GCP.', 'slides', 'https://example.com/cloud-run-slides', '2026-05-03 08:00:00'),
('CNT-003', 'BLQ-104', 'PROF-104', 'Plantilla de agentes', 'Repositorio base del workshop.', 'repo', 'https://example.com/agents-template', '2026-05-05 08:00:00');
