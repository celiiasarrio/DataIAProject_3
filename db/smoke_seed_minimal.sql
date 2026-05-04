TRUNCATE TABLE
    reservas,
    franja_tutoria,
    eventos,
    rel_alumno_tarea,
    asistencia,
    contenidos,
    correos,
    configuracion_notificaciones,
    notificaciones,
    rel_profesores_bloques,
    rel_bloques_grupos,
    rel_alumnos_grupos,
    rel_coordinadores_grupos,
    tareas,
    sesiones,
    ubicaciones,
    bloques,
    grupos,
    profesores,
    alumnos,
    coordinadores
RESTART IDENTITY CASCADE;

INSERT INTO coordinadores (id_coordinador, nombre, apellido, correo, contrasena, rol, url_foto) VALUES
('COR-001', 'Andrea', 'Soler', 'andrea.soler@edem.es', 'staff123', 'Coordinador', NULL);

INSERT INTO alumnos (id_alumno, nombre, apellido1, apellido2, correo, contrasena, url_foto, rol) VALUES
('ALU-001', 'Ahsoka', 'Tano', NULL, 'ahsoka.tano@edem.es', 'demo123', NULL, 'Alumno');

INSERT INTO profesores (id_profesor, nombre, apellido, correo, contrasena, url_foto, rol) VALUES
('PROF-101', 'Pedro', 'Nieto', 'pedro.nieto@seed.local', 'prof123', NULL, 'Profesor');

INSERT INTO grupos (id_grupo, nombre) VALUES
('GRP-001', 'MIA Smoke');

INSERT INTO bloques (id_bloque, nombre) VALUES
('BLQ-101', 'IA Generativa');

INSERT INTO sesiones (id_sesion, id_bloque, nombre, fecha, hora_inicio, hora_fin, aula) VALUES
('SES-001', 'BLQ-101', 'Introducción al bloque', '2026-05-14', '15:30', '19:30', 'AULA 115');

INSERT INTO tareas (id_tarea, id_bloque, nombre, descripcion) VALUES
(1, 'BLQ-101', 'Entrega inicial', 'Primera tarea de validación');

INSERT INTO rel_coordinadores_grupos (id_coordinador, id_grupo) VALUES
('COR-001', 'GRP-001');

INSERT INTO rel_alumnos_grupos (id_alumno, id_grupo) VALUES
('ALU-001', 'GRP-001');

INSERT INTO rel_bloques_grupos (id_bloque, id_grupo) VALUES
('BLQ-101', 'GRP-001');

INSERT INTO rel_profesores_bloques (id_profesor, id_bloque) VALUES
('PROF-101', 'BLQ-101');

INSERT INTO rel_alumno_tarea (id_alumno, id_tarea, nota) VALUES
('ALU-001', 1, 8.5);

INSERT INTO asistencia (id_alumno, id_sesion, fecha, presente) VALUES
('ALU-001', 'SES-001', '2026-05-14', TRUE);

INSERT INTO eventos (id, tipo, titulo, id_bloque, id_sesion, aula, id_profesor, fecha_inicio, fecha_fin, descripcion) VALUES
('EVT-001', 'class', 'Sesión de apertura', 'BLQ-101', 'SES-001', 'AULA 115', 'PROF-101', '2026-05-14 15:30:00', '2026-05-14 19:30:00', 'Evento de prueba para smoke test');

INSERT INTO franja_tutoria (id, id_profesor, id_bloque, dia_semana, hora_inicio, hora_fin, ubicacion, disponible) VALUES
('TUT-001', 'PROF-101', 'BLQ-101', 2, '10:00', '11:00', 'Despacho 1', TRUE);

INSERT INTO configuracion_notificaciones (id_usuario, avisos_calendario, avisos_notas, avisos_asistencia) VALUES
('ALU-001', TRUE, TRUE, TRUE);

INSERT INTO correos (id, id_remitente, id_destinatario, asunto, cuerpo, leido, fecha_envio) VALUES
('MAIL-001', 'PROF-101', 'ALU-001', 'Bienvenida', 'Bienvenida al entorno de pruebas.', FALSE, '2026-05-13 09:00:00');

INSERT INTO contenidos (id, id_bloque, id_profesor, titulo, descripcion, tipo, url, fecha_subida) VALUES
('CNT-001', 'BLQ-101', 'PROF-101', 'Presentación inicial', 'Material del smoke test', 'pdf', 'https://example.com/material.pdf', '2026-05-13 08:30:00');
