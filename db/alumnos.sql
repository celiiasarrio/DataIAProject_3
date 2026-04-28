-- Legacy seed snapshot. Usar init_db_v4.sql para seeds compatibles con el esquema actual.

TRUNCATE TABLE "alumnos" CASCADE;
TRUNCATE TABLE "bloques" CASCADE;
TRUNCATE TABLE "sesiones" CASCADE;
TRUNCATE TABLE "asistencia" CASCADE;
TRUNCATE TABLE "grupos" CASCADE;
TRUNCATE TABLE "personal_edem" CASCADE;
TRUNCATE TABLE "profesores" CASCADE;
TRUNCATE TABLE "rel_alumno_tarea" CASCADE;
TRUNCATE TABLE "rel_alumnos_grupos" CASCADE;
TRUNCATE TABLE "rel_bloques_grupos" CASCADE;
TRUNCATE TABLE "rel_personal_grupos" CASCADE;
TRUNCATE TABLE "rel_profesores_bloques" CASCADE;
TRUNCATE TABLE "tareas" CASCADE;
TRUNCATE TABLE "ubicaciones" CASCADE;

INSERT INTO "alumnos" ("id_alumno", "nombre", "apellido", "apellido2", "correo", "contrasena", "url_foto") VALUES
('daadgi', 'Daniel', 'Adam', 'Giménez', 'daadgi@edem.es', 'Da7!kLm92Q', ''),
('joallu', 'Jorge', 'Albalat', 'Luengo', 'joallu@edem.es', 'Jo4#vRt81P', ''),
('gebaad', 'Gemma', 'Balaguer', 'Adell', 'gebaad@edem.es', 'Ge9$uNx34L', ''),
('cabesa', 'Carlos', 'Beltrán', 'Sanz', 'cabesa@edem.es', 'Ca2@pWd67M', ''),
('inbupe', 'Iñaki', 'Buj', 'Peris', 'inbupe@edem.es', 'In8!yQs53K', ''),
('pagaes', 'Pau', 'García', 'Esparter', 'pagaes@edem.es', 'Pa6#zHt28R', ''),
('maazlo', 'Marina', 'Azul', 'López', 'maazlo@edem.es', 'Ma3$eJv74N', ''),
('jomama', 'Jorge', 'Martínez', 'Martínez', 'jomama@edem.es', 'Jo1@xBc95T', ''),
('japlro', 'Javier', 'Plaza', 'Rosique', 'japlro@edem.es', 'Ja5!mYu46H', ''),
('sareva', 'Salvador', 'Reche', 'Vázquez', 'sareva@edem.es', 'Sa7#nKi83D', ''),
('jogrhe', 'Jorge', 'Greus', 'Herrero', 'jogrhe@edem.es', 'Jo8$hPw52C', ''),
('cesaco', 'Celia', 'Sarrió', 'Colomar', 'cesaco@edem.es', 'Ce4@tLq67B', ''),
('jaloru', 'Javier', 'Lopez', 'Ruiz', 'jaloru@edem.es', 'Ja9!rMx31F', ''),
('feorma', 'Felix', 'Ortuño', 'Martinez', 'feorma@edem.es', 'Fe2#vNd84S', '');

-- fabricate-flush
-- Placeholder para sesiones reales de cada bloque.
-- INSERT INTO "sesiones" ("id_sesion", "id_bloque", "nombre", "fecha", "hora_inicio", "hora_fin", "aula") VALUES
-- ('SES-001', 'SES-001', 'Sesión 1', '2026-03-01', '09:00', '11:00', 'AULA 101');


INSERT INTO "bloques" ("id_bloque", "nombre") VALUES
('SES-001', 'Análisis de Riesgos Financieros'),
('SES-002', 'Arquitectura de Datos'),
('SES-003', 'Big Data Analytics'),
('SES-004', 'Blockchain y Criptomonedas'),
('SES-005', 'Cloud Computing'),
('SES-006', 'Contabilidad Financiera'),
('SES-007', 'Data Science para Finanzas'),
('SES-008', 'Deep Learning'),
('SES-009', 'DevOps y CI/CD'),
('SES-010', 'Dirección Estratégica'),
('SES-011', 'Economía Digital'),
('SES-012', 'Economía de la Empresa'),
('SES-013', 'Gestión de Proyectos Tecnológicos'),
('SES-014', 'Gestión de Recursos Humanos'),
('SES-015', 'Ingeniería de Procesos'),
('SES-016', 'Innovación y Emprendimiento'),
('SES-017', 'Machine Learning'),
('SES-018', 'Marketing Digital'),
('SES-019', 'Pagos Digitales'),
('SES-020', 'Procesamiento de Datos en Tiempo Real'),
('SES-021', 'Procesamiento de Lenguaje Natural'),
('SES-022', 'Regulación Financiera Digital'),
('SES-023', 'Sistemas de Información Empresarial'),
('SES-024', 'Visión por Computador'),
('SES-025', 'Ética en Inteligencia Artificial');


-- fabricate-flush



INSERT INTO "grupos" ("id_grupo", "nombre") VALUES
('GRP-001', 'GADE'),
('GRP-002', 'GIGE'),
('GRP-003', 'MDA A'),
('GRP-004', 'MDA B'),
('GRP-005', 'MFT'),
('GRP-006', 'MIA');


-- fabricate-flush


INSERT INTO "personal_edem" ("id_personal", "nombre", "apellido", "correo", "rol", "url_foto", "contrasena") VALUES
('PER-001', 'Andrea', 'Soler', 'andrea.soler@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Andrea%20Soler&size=200', 'Andrea16$2025'),
('PER-002', 'Luis', 'Marín', 'luis.marin@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Luis%20Mar%C3%ADn&size=200', 'LuisMarín#79'),
('PER-003', 'Miguel', 'Herrera', 'miguel.herrera@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Miguel%20Herrera&size=200', 'Miguel.2025%'),
('PER-004', 'Sara', 'Reyes', 'sara.reyes@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Sara%20Reyes&size=200', 'Sara.2026$');


-- fabricate-flush


INSERT INTO "profesores" ("id_profesor", "nombre", "apellido", "correo", "url_foto", "contrasena") VALUES
('PROF-001', 'Alberto', 'Gil', 'alberto.gil@edem.es', 'https://ui-avatars.com/api/?name=Alberto%20Gil&size=200', 'Alberto1#2025'),
('PROF-002', 'Ana', 'Fernández', 'ana.fernandez@edem.es', 'https://ui-avatars.com/api/?name=Ana%20Fern%C3%A1ndez&size=200', 'FernándezAna#2024'),
('PROF-003', 'Andrés', 'Herrero', 'andres.herrero@edem.es', 'https://ui-avatars.com/api/?name=Andr%C3%A9s%20Herrero&size=200', 'AndrésHerrero#82'),
('PROF-004', 'Carlos', 'García', 'carlos.garcia@edem.es', 'https://ui-avatars.com/api/?name=Carlos%20Garc%C3%ADa&size=200', 'García2024*99'),
('PROF-005', 'Carmen', 'Álvarez', 'carmen.alvarez@edem.es', 'https://ui-avatars.com/api/?name=Carmen%20%C3%81lvarez&size=200', 'Carmen39!2025'),
('PROF-006', 'Cristina', 'Ortiz', 'cristina.ortiz@edem.es', 'https://ui-avatars.com/api/?name=Cristina%20Ortiz&size=200', 'Cristina.2025!'),
('PROF-007', 'Daniel', 'Morales', 'daniel.morales@edem.es', 'https://ui-avatars.com/api/?name=Daniel%20Morales&size=200', 'MoralesDaniel%2025'),
('PROF-008', 'Diego', 'Ruiz', 'diego.ruiz@edem.es', 'https://ui-avatars.com/api/?name=Diego%20Ruiz&size=200', 'DiegoRuiz#71'),
('PROF-009', 'Elena', 'Moreno', 'elena.moreno@edem.es', 'https://ui-avatars.com/api/?name=Elena%20Moreno&size=200', 'Elena.2024@'),
('PROF-010', 'Fernando', 'Castro', 'fernando.castro@edem.es', 'https://ui-avatars.com/api/?name=Fernando%20Castro&size=200', 'Fernando.2024*'),
('PROF-011', 'Francisco', 'Romero', 'francisco.romero@edem.es', 'https://ui-avatars.com/api/?name=Francisco%20Romero&size=200', 'Francisco7!2024'),
('PROF-012', 'Isabel', 'Navarro', 'isabel.navarro@edem.es', 'https://ui-avatars.com/api/?name=Isabel%20Navarro&size=200', 'Isabel91#2025'),
('PROF-013', 'Javier', 'Martín', 'javier.martin@edem.es', 'https://ui-avatars.com/api/?name=Javier%20Mart%C3%ADn&size=200', 'Javier.2026&'),
('PROF-014', 'Laura', 'Torres', 'laura.torres@edem.es', 'https://ui-avatars.com/api/?name=Laura%20Torres&size=200', 'TorresLaura%2025'),
('PROF-015', 'Lucía', 'Blanco', 'lucia.blanco@edem.es', 'https://ui-avatars.com/api/?name=Luc%C3%ADa%20Blanco&size=200', 'Blanco2026#0'),
('PROF-016', 'Manuel', 'Ramírez', 'manuel.ramirez@edem.es', 'https://ui-avatars.com/api/?name=Manuel%20Ram%C3%ADrez&size=200', 'Ramírez2024#84'),
('PROF-017', 'Marta', 'Delgado', 'marta.delgado@edem.es', 'https://ui-avatars.com/api/?name=Marta%20Delgado&size=200', 'Marta.2026&'),
('PROF-018', 'María', 'López', 'maria.lopez@edem.es', 'https://ui-avatars.com/api/?name=Mar%C3%ADa%20L%C3%B3pez&size=200', 'LópezMaría&2024'),
('PROF-019', 'Pablo', 'Vega', 'pablo.vega@edem.es', 'https://ui-avatars.com/api/?name=Pablo%20Vega&size=200', 'Pablo38*2026'),
('PROF-020', 'Patricia', 'Serrano', 'patricia.serrano@edem.es', 'https://ui-avatars.com/api/?name=Patricia%20Serrano&size=200', 'SerranoPatricia*2024'),
('PROF-021', 'Pedro', 'Sánchez', 'pedro.sanchez@edem.es', 'https://ui-avatars.com/api/?name=Pedro%20S%C3%A1nchez&size=200', 'Pedro76$2024'),
('PROF-022', 'Raúl', 'Jiménez', 'raul.jimenez@edem.es', 'https://ui-avatars.com/api/?name=Ra%C3%BAl%20Jim%C3%A9nez&size=200', 'RaúlJiménez#19'),
('PROF-023', 'Roberto', 'Díaz', 'roberto.diaz@edem.es', 'https://ui-avatars.com/api/?name=Roberto%20D%C3%ADaz&size=200', 'Roberto57!2024'),
('PROF-024', 'Sofía', 'Molina', 'sofia.molina@edem.es', 'https://ui-avatars.com/api/?name=Sof%C3%ADa%20Molina&size=200', 'Sofía31!2024'),
('PROF-025', 'Teresa', 'Peña', 'teresa.pena@edem.es', 'https://ui-avatars.com/api/?name=Teresa%20Pe%C3%B1a&size=200', 'Teresa77$2024');


-- fabricate-flush



INSERT INTO "rel_alumnos_grupos" ("id_alumno", "id_grupo") VALUES
('ALU-052', 'GRP-003'),
('ALU-054', 'GRP-003'),
('ALU-097', 'GRP-003'),
('ALU-035', 'GRP-003'),
('ALU-069', 'GRP-003'),
('ALU-081', 'GRP-003'),
('ALU-049', 'GRP-003'),
('ALU-043', 'GRP-003'),
('ALU-047', 'GRP-003'),
('ALU-025', 'GRP-003'),
('ALU-028', 'GRP-003'),
('ALU-104', 'GRP-003'),
('ALU-032', 'GRP-003'),
('ALU-086', 'GRP-003'),
('ALU-088', 'GRP-003'),
('ALU-064', 'GRP-003'),
('ALU-085', 'GRP-003'),
('ALU-061', 'GRP-003'),
('ALU-004', 'GRP-003'),
('ALU-065', 'GRP-003'),
('ALU-044', 'GRP-004'),
('ALU-101', 'GRP-004'),
('ALU-006', 'GRP-004'),
('ALU-066', 'GRP-004'),
('ALU-048', 'GRP-004'),
('ALU-016', 'GRP-004'),
('ALU-041', 'GRP-004'),
('ALU-039', 'GRP-004'),
('ALU-038', 'GRP-004'),
('ALU-074', 'GRP-004'),
('ALU-090', 'GRP-004'),
('ALU-009', 'GRP-004'),
('ALU-045', 'GRP-004'),
('ALU-036', 'GRP-004'),
('ALU-015', 'GRP-004'),
('ALU-109', 'GRP-004'),
('ALU-050', 'GRP-004'),
('ALU-098', 'GRP-004'),
('ALU-108', 'GRP-004'),
('ALU-026', 'GRP-004'),
('ALU-068', 'GRP-006'),
('ALU-067', 'GRP-006'),
('ALU-051', 'GRP-006'),
('ALU-003', 'GRP-006'),
('ALU-087', 'GRP-006'),
('ALU-083', 'GRP-006'),
('ALU-120', 'GRP-006'),
('ALU-070', 'GRP-006'),
('ALU-001', 'GRP-006'),
('ALU-096', 'GRP-006'),
('ALU-042', 'GRP-006'),
('ALU-093', 'GRP-006'),
('ALU-034', 'GRP-006'),
('ALU-063', 'GRP-006'),
('ALU-059', 'GRP-006'),
('ALU-024', 'GRP-006'),
('ALU-053', 'GRP-006'),
('ALU-040', 'GRP-006'),
('ALU-062', 'GRP-006'),
('ALU-099', 'GRP-006'),
('ALU-113', 'GRP-005'),
('ALU-107', 'GRP-005'),
('ALU-080', 'GRP-005'),
('ALU-019', 'GRP-005'),
('ALU-111', 'GRP-005'),
('ALU-089', 'GRP-005'),
('ALU-117', 'GRP-005'),
('ALU-103', 'GRP-005'),
('ALU-106', 'GRP-005'),
('ALU-023', 'GRP-005'),
('ALU-020', 'GRP-005'),
('ALU-029', 'GRP-005'),
('ALU-033', 'GRP-005'),
('ALU-013', 'GRP-005'),
('ALU-008', 'GRP-005'),
('ALU-105', 'GRP-005'),
('ALU-012', 'GRP-005'),
('ALU-084', 'GRP-005'),
('ALU-060', 'GRP-005'),
('ALU-116', 'GRP-005'),
('ALU-037', 'GRP-001'),
('ALU-005', 'GRP-001'),
('ALU-094', 'GRP-001'),
('ALU-078', 'GRP-001'),
('ALU-079', 'GRP-001'),
('ALU-073', 'GRP-001'),
('ALU-112', 'GRP-001'),
('ALU-007', 'GRP-001'),
('ALU-056', 'GRP-001'),
('ALU-002', 'GRP-001'),
('ALU-118', 'GRP-001'),
('ALU-022', 'GRP-001'),
('ALU-075', 'GRP-001'),
('ALU-076', 'GRP-001'),
('ALU-095', 'GRP-001'),
('ALU-021', 'GRP-001'),
('ALU-072', 'GRP-001'),
('ALU-091', 'GRP-001'),
('ALU-014', 'GRP-001'),
('ALU-011', 'GRP-001'),
('ALU-057', 'GRP-002'),
('ALU-030', 'GRP-002'),
('ALU-010', 'GRP-002'),
('ALU-102', 'GRP-002'),
('ALU-115', 'GRP-002'),
('ALU-027', 'GRP-002'),
('ALU-055', 'GRP-002'),
('ALU-017', 'GRP-002'),
('ALU-110', 'GRP-002'),
('ALU-018', 'GRP-002'),
('ALU-100', 'GRP-002'),
('ALU-058', 'GRP-002'),
('ALU-077', 'GRP-002'),
('ALU-114', 'GRP-002'),
('ALU-031', 'GRP-002'),
('ALU-071', 'GRP-002'),
('ALU-082', 'GRP-002'),
('ALU-119', 'GRP-002'),
('ALU-046', 'GRP-002'),
('ALU-092', 'GRP-002');


-- fabricate-flush


INSERT INTO "rel_bloques_grupos" ("id_bloque", "id_grupo") VALUES
('SES-005', 'GRP-003'),
('SES-005', 'GRP-004'),
('SES-003', 'GRP-003'),
('SES-003', 'GRP-004'),
('SES-002', 'GRP-003'),
('SES-002', 'GRP-004'),
('SES-009', 'GRP-003'),
('SES-009', 'GRP-004'),
('SES-020', 'GRP-003'),
('SES-020', 'GRP-004'),
('SES-017', 'GRP-006'),
('SES-008', 'GRP-006'),
('SES-021', 'GRP-006'),
('SES-024', 'GRP-006'),
('SES-025', 'GRP-006'),
('SES-004', 'GRP-005'),
('SES-022', 'GRP-005'),
('SES-001', 'GRP-005'),
('SES-019', 'GRP-005'),
('SES-007', 'GRP-005'),
('SES-006', 'GRP-001'),
('SES-018', 'GRP-001'),
('SES-010', 'GRP-001'),
('SES-014', 'GRP-001'),
('SES-012', 'GRP-001'),
('SES-013', 'GRP-002'),
('SES-015', 'GRP-002'),
('SES-023', 'GRP-002'),
('SES-016', 'GRP-002'),
('SES-011', 'GRP-002');


-- fabricate-flush


INSERT INTO "rel_personal_grupos" ("id_personal", "id_grupo") VALUES
('PER-003', 'GRP-003'),
('PER-003', 'GRP-004'),
('PER-003', 'GRP-006'),
('PER-001', 'GRP-005'),
('PER-002', 'GRP-001'),
('PER-004', 'GRP-002');


-- fabricate-flush


INSERT INTO "rel_profesores_bloques" ("id_profesor", "id_bloque") VALUES
('PROF-004', 'SES-005'),
('PROF-018', 'SES-003'),
('PROF-013', 'SES-002'),
('PROF-002', 'SES-009'),
('PROF-021', 'SES-020'),
('PROF-014', 'SES-017'),
('PROF-008', 'SES-008'),
('PROF-009', 'SES-021'),
('PROF-023', 'SES-024'),
('PROF-005', 'SES-025'),
('PROF-011', 'SES-004'),
('PROF-012', 'SES-022'),
('PROF-001', 'SES-001'),
('PROF-024', 'SES-019'),
('PROF-022', 'SES-007'),
('PROF-020', 'SES-006'),
('PROF-016', 'SES-018'),
('PROF-015', 'SES-010'),
('PROF-003', 'SES-014'),
('PROF-025', 'SES-012'),
('PROF-019', 'SES-013'),
('PROF-017', 'SES-015'),
('PROF-010', 'SES-023'),
('PROF-006', 'SES-016'),
('PROF-007', 'SES-011');


-- fabricate-flush




INSERT INTO "ubicaciones" ("id_ubicacion", "descripcion", "planta", "aula") VALUES
('UBI-001', 'Aula 101 - Planta 1', 1, '101'),
('UBI-002', 'Aula 102 - Planta 1', 1, '102'),
('UBI-003', 'Aula 103 - Planta 1', 1, '103'),
('UBI-004', 'Aula 201 - Planta 2', 2, '201'),
('UBI-005', 'Aula 202 - Planta 2', 2, '202'),
('UBI-006', 'Aula 203 - Planta 2', 2, '203');


-- fabricate-flush


SET session_replication_role = 'origin';
