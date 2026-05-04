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
    asistencia
RESTART IDENTITY CASCADE;

INSERT INTO "alumnos" ("id_alumno", "nombre", "apellido", "apellido2", "correo", "contrasena", "url_foto", "rol", "grupo") VALUES
('daadgi', 'Daniel', 'Adam', 'Giménez', 'daadgi@edem.es', 'Da7!kLm92Q', '', 'Alumno', 'MDA A 2526'),
('joallu', 'Jorge', 'Albalat', 'Luengo', 'joallu@edem.es', 'Jo4#vRt81P', '', 'Alumno', 'MDA A 2526'),
('gebaad', 'Gemma', 'Balaguer', 'Adell', 'gebaad@edem.es', 'Ge9$uNx34L', '', 'Alumno', 'MDA A 2526'),
('cabesa', 'Carlos', 'Beltrán', 'Sanz', 'cabesa@edem.es', 'Ca2@pWd67M', '', 'Alumno', 'MDA A 2526'),
('inbupe', 'Iñaki', 'Buj', 'Peris', 'inbupe@edem.es', 'In8!yQs53K', '', 'Alumno', 'MDA A 2526'),
('pagaes', 'Pau', 'García', 'Esparter', 'pagaes@edem.es', 'Pa6#zHt28R', '', 'Alumno', 'MDA A 2526'),
('maazlo', 'Marina', 'Azul', 'López', 'maazlo@edem.es', 'Ma3$eJv74N', '', 'Alumno', 'MDA A 2526'),
('jomama', 'Jorge', 'Martínez', 'Martínez', 'jomama@edem.es', 'Jo1@xBc95T', '', 'Alumno', 'MDA A 2526'),
('japlro', 'Javier', 'Plaza', 'Rosique', 'japlro@edem.es', 'Ja5!mYu46H', '', 'Alumno', 'MDA A 2526'),
('sareva', 'Salvador', 'Reche', 'Vázquez', 'sareva@edem.es', 'Sa7#nKi83D', '', 'Alumno', 'MDA A 2526'),
--('jogrhe', 'Jorge', 'Greus', 'Herrero', 'jogrhe@edem.es', 'Jo8$hPw52C', '', 'Alumno', 'MIA 2526'),
('cesaco', 'Celia', 'Sarrió', 'Colomar', 'cesaco@edem.es', 'Ce4@tLq67B', '', 'Alumno', 'MDA A 2526'),
--('jaloru', 'Javier', 'Lopez', 'Ruiz', 'jaloru@edem.es', 'Ja9!rMx31F', '', 'Alumno', 'MIA 2526'),
--('feorma', 'Felix', 'Ortuño', 'Martinez', 'feorma@edem.es', 'Fe2#vNd84S', '', 'Alumno', 'MIA 2526');

INSERT INTO "profesores" ("id_profesor", "nombre", "apellido", "apellido2", "correo", "contrasena", "url_foto", 'rol') VALUES
('penipe', 'Pedro', 'Nieto', 'Pelaez', 'pedronietopelaez@gmail.com', 'PeNiPe2026!', '', 'Profesor'),
('sopina', 'Sofía', 'Pinilla', '', 'sofia.pinilla@edem.es', 'SoPi2026!', '', 'Profesor'),
('dapina', 'David', 'Pinilla', '', 'david.pinilla@climatetrade.com', 'DaPi2026!', '', 'Profesor'),
('macola', 'Marco', 'Colapietro', '', 'marco.colapietro@gft.com', 'MaCo2026!', '', 'Profesor'),
('anllos', 'Ángel', 'Llosa', '', 'angel.llosa@seidor.com', 'AnLl2026!', '', 'Profesor'),
('anrode', 'Ángel', 'Rodríguez', '', 'angel.rodriguez@sdggroup.com', 'AnRo2026!', '', 'Profesor'),
('frkrog', 'Franziska', 'Kröger', '', 'franziska.kroger@gft.com', 'FrKr2026!', '', 'Profesor'),
('nareye', 'Nacho', 'Reyes', '', 'nacho.reyes@bbva.com', 'NaRe2026!', '', 'Profesor'),
('jugamil', 'Juanjo', 'García', 'Millán', 'juanjo.garcia@empresa.com', 'JuGa2026!', '', 'Profesor'),
('jolgome', 'Jose Luis', 'Gómez', '', 'joseluis.gomez@ub.com', 'JoGo2026!', '', 'Profesor'),
('viasen', 'Vicent', 'Asensio', '', 'vicent.asensio@prima.com', 'ViAs2026!', '', 'Profesor'),
('facast', 'Fabio', 'Castro', '', 'fabio.castro@gft.com', 'FaCa2026!', '', 'Profesor'),
('heboas', 'Hernan', 'Boasso', '', 'hernan.boasso@gft.com', 'HeBo2026!', '', 'Profesor'),
('lalath', 'Lars', 'Lathan', '', 'lars.lathan@gft.com', 'LaLa2026!', '', 'Profesor'),
('mimora', 'Miguel', 'Moratilla', '', 'miguel.moratilla@mercadonatec.com', 'MiMo2026!', '', 'Profesor'),
('jabrio', 'Javier', 'Briones', '', 'javier.briones@radicant.com', 'JaBr2026!', '', 'Profesor'),
('nuberz', 'Nuria', 'Berzal', '', 'nuria.berzal@gft.com', 'NuBe2026!', '', 'Profesor'),
('diegue', 'Diego', 'Guerrero', '', 'diego.guerrero@gft.com', 'DiGu2026!', '', 'Profesor'),
('joeste', 'Jose Luis', 'Esteban', '', 'joseluis.esteban@medallatech.com', 'JoEs2026!', '', 'Profesor'),
('adcamp', 'Adriana', 'Campos', '', 'adriana.campos@sdggroup.com', 'AdCa2026!', '', 'Profesor'),
('bearuiz', 'Bea', 'Ruíz', '', 'bea.ruiz@openbank.com', 'BeRu2026!', '', 'Profesor'),
('jopere', 'Josiño', 'Pérez', '', 'josino.perez@experto.com', 'JoPe2026!', '', 'Profesor'),
('tocanto', 'Toni', 'Cantó', '', 'toni.canto@empresa.com', 'ToCa2026!', '', 'Profesor');

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
('SES-1',  '1-MDA', 'Introducción + Instalación de Software', '2025-09-29', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-2',  '1-MDA', 'Git',                                    '2025-09-30', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-3',  '1-MDA', 'Python',                                 '2025-10-01', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-4',  '1-MDA', 'Git',                                    '2025-10-02', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-5',  '1-MDA', 'Python',                                 '2025-10-06', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-6',  '1-MDA', 'Python',                                 '2025-10-07', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-7',  '1-MDA', 'Python',                                 '2025-10-08', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-8',  '1-MDA', 'Docker',                                 '2025-10-13', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-9',  '1-MDA', 'Linux',                                  '2025-10-14', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-10', '1-MDA', 'Docker',                                 '2025-10-15', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-11', '1-MDA', 'Docker',                                 '2025-10-16', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-12', '1-MDA', 'SQL',                                    '2025-10-20', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-13', '1-MDA', 'Docker Compose',                         '2025-10-21', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-14', '1-MDA', 'SQL',                                    '2025-10-22', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-15', '1-MDA', 'SQL',                                    '2025-10-23', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-16', '1-MDA', 'Python',                                 '2025-10-27', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
('SES-17', '1-MDA', 'E2E Módulo 0',                           '2025-10-28', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 102'),
-- B2. TRATAMIENTO DEL DATO: PySpark, Kafka, DBT... (LZD PLANTA 1 AULA 115)
('SES-18', '2-MDA', 'Intro Módulo + Origen del Dato', '2025-10-29', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-19', '2-MDA', 'Visualización de datos',        '2025-10-30', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-20', '2-MDA', 'Visualización de datos',        '2025-11-03', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-21', '2-MDA', 'Ingesta de Datos y NoSQL',      '2025-11-05', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-22', '2-MDA', 'Ingesta de Datos y NoSQL',      '2025-11-06', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-23', '2-MDA', 'Ingesta de Datos y NoSQL',      '2025-11-10', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-24', '2-MDA', 'DBT',                           '2025-11-11', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-25', '2-MDA', 'DBT',                           '2025-11-12', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-26', '2-MDA', 'Kafka',                         '2025-11-18', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-28', '2-MDA', 'Kafka avanzado',                '2025-11-21', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-29', '2-MDA', 'API Management',                '2025-11-24', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-30', '2-MDA', 'API Management',                '2025-11-25', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-31', '2-MDA', 'PySpark',                       '2025-11-26', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-32', '2-MDA', 'PySpark',                       '2025-11-27', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-33', '2-MDA', 'PySpark',                       '2025-12-01', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-34', '2-MDA', 'Blockchain',                    '2025-12-04', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-71', '2-MDA', 'Data Products',                 '2026-04-28', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-72', '2-MDA', 'Prototipado',                   '2026-04-29', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
-- B3. ENTORNO CLOUD: GCP, Terraform, Cloud Run, Agentes (LZD PLANTA 1 AULA 115)
('SES-36', '3-MDA', 'Cloud Intro',           '2025-12-11', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-37', '3-MDA', 'Certificaciones Cloud', '2025-12-15', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-38', '3-MDA', 'Terraform',             '2025-12-16', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-39', '3-MDA', 'GCP Project Setup',     '2025-12-17', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-40', '3-MDA', 'Terraform',             '2025-12-18', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-41', '3-MDA', 'Terraform',             '2026-01-07', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-42', '3-MDA', 'GCP Almacenamiento',    '2026-01-08', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-43', '3-MDA', 'GCP Almacenamiento',    '2026-01-12', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-44', '3-MDA', 'GCP Almacenamiento',    '2026-01-15', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-45', '3-MDA', 'GCP PubSub/DataFlow',   '2026-01-19', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-46', '3-MDA', 'GCP PubSub/DataFlow',   '2026-01-21', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-47', '3-MDA', 'GCP PubSub/DataFlow',   '2026-01-26', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-48', '3-MDA', 'GCP DataFlow',          '2026-01-27', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-49', '3-MDA', 'GCP DataFlow',          '2026-01-28', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-50', '3-MDA', 'GCP DataFlow',          '2026-01-29', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-52', '3-MDA', 'GCP Funciones',         '2026-02-03', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-53', '3-MDA', 'GCP Cloud Run',         '2026-02-04', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-54', '3-MDA', 'Gobierno del Dato',     '2026-02-05', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-56', '3-MDA', 'GCP Específicos',       '2026-02-10', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-57', '3-MDA', 'Git Actions',           '2026-02-11', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-58', '3-MDA', 'Calidad del Dato',      '2026-02-12', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-65', '3-MDA', 'Airflow',               '2026-03-23', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-66', '3-MDA', 'Agentes',               '2026-03-24', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-73', '3-MDA', 'Gen AI',                '2026-05-14', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
-- SOFT SKILLS: Autoconocimiento, Comunicación, Inteligencia Emocional... (EDEM PLANTA 2 AULA 202 / LZD)
('SES-59', '4-MDA', 'Skills Autoconocimiento',               '2025-11-04', '15:30', '19:30', 'EDEM', 'PLANTA 1', 'AULA 101'),
('SES-60', '4-MDA', 'Skills Comunicación',                   '2025-11-17', '15:30', '19:30', 'LZD',  'PLANTA 1', 'AULA 115'),
('SES-61', '4-MDA', 'Skills Inteligencia Emocional',         '2025-11-19', '15:30', '19:30', 'EDEM', 'PLANTA 2', 'AULA 202'),
('SES-62', '4-MDA', 'Skills Comunicación eficaz',            '2026-01-20', '15:30', '19:30', 'EDEM', 'PLANTA 2', 'AULA 202'),
('SES-64', '4-MDA', 'Skills Productividad Sana',             '2026-02-18', '15:30', '19:30', 'EDEM', 'PLANTA 2', 'AULA 202'),
('SES-69', '4-MDA', 'Skills Gestión de equipos y liderazgo', '2026-04-22', '15:30', '19:30', 'EDEM', 'PLANTA 2', 'AULA 202'),
('SES-70', '4-MDA', 'Skills Comunicación',                   '2026-04-27', '15:30', '19:30', 'LZD',  'PLANTA 1', 'AULA 115'),
-- DATA PROJECTS: Lanzamientos y jornadas de trabajo de los Data Projects (LZD PLANTA 1 AULA 115)
('SES-27', '5-MDA', 'Lanzamiento DP1 + E2E Módulo 1.1', '2025-11-20', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-35', '5-MDA', 'E2E Módulo 1.2',                   '2025-12-09', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-51', '5-MDA', 'Lanzamiento DP2',                  '2026-02-02', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-55', '5-MDA', 'Jornada trabajo DP2',              '2026-02-09', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
-- HACKATONES (LZD PLANTA 1 AULA 115)
('SES-63', '5-MDA', 'Hackatón NTT Data', '2026-02-16', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-67', '5-MDA', 'Hackatón GFT',      '2026-03-25', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115'),
('SES-68', '5-MDA', 'Hackatón GFT',      '2026-03-26', '15:30', '19:30', 'LZD', 'PLANTA 1', 'AULA 115');

INSERT INTO "ubicaciones" ("id_ubicacion", "descripcion", "planta", "aula") VALUES
('UBI-101',    'EDEM, PLANTA 1, AULA 101',        1, 'AULA 101'),
('UBI-102',    'EDEM, PLANTA 1, AULA 102',        1, 'AULA 102'),
('UBI-103',    'EDEM, PLANTA 1, AULA 103',        1, 'AULA 103'),
('UBI-107',    'EDEM, PLANTA 1, AULA 107',        1, 'AULA 107'),
('UBI-110',    'EDEM, PLANTA 1, AULA 110',        1, 'AULA 110'),
('UBI-111',    'EDEM, PLANTA 1, AULA 111',        1, 'AULA 111'),
('UBI-202',    'EDEM, PLANTA 2, AULA 202',        2, 'AULA 202'),
('UBI-206',    'EDEM, PLANTA 2, AULA 206',        2, 'AULA 206'),
('UBI-208',    'EDEM, PLANTA 2, AULA 208',        2, 'AULA 208'),
('UBI-209',    'EDEM, PLANTA 2, AULA 209',        2, 'AULA 209'),
('UBI-A01',    'EDEM, PLANTA BAJA, AUDITORIO 01', 0, 'AUDITORIO 01'),
('UBI-LZD115', 'LZD, PLANTA 1, AULA 115',        1, 'AULA 115');

INSERT INTO "rel_alumnos_grupos" ("id_alumno", "id_grupo") VALUES
('daadgi', 'MDA A 2526'),
('joallu', 'MDA A 2526'),
('gebaad', 'MDA A 2526'),
('cabesa', 'MDA A 2526'),
('inbupe', 'MDA A 2526'),
('pagaes', 'MDA A 2526'),
('maazlo', 'MDA A 2526'),
('jomama', 'MDA A 2526'),
('japlro', 'MDA A 2526'),
('sareva', 'MDA A 2526'),
--('jogrhe', 'MIA 2526'),
('cesaco', 'MDA A 2526');
--('jaloru', 'MIA 2526'),
--('feorma', 'MIA 2526');

INSERT INTO "rel_bloques_grupos" ("id_bloque", "id_grupo") VALUES
('1-MDA', 'MDA A 2526'),
('2-MDA', 'MDA A 2526'),
('3-MDA', 'MDA A 2526'),
('4-MDA', 'MDA A 2526'),
('5-MDA', 'MDA A 2526'),
('6-MDA', 'MDA A 2526');

INSERT INTO "rel_profesores_bloques" ("id_profesor", "id_bloque") VALUES
-- FUNDAMENTOS (1-MDA)
('penipe', '1-MDA'),
('sopina', '1-MDA'),
('dapina', '1-MDA'),
-- TRATAMIENTO DEL DATO (2-MDA)
('macola', '2-MDA'),
('anllos', '2-MDA'),
('anrode', '2-MDA'),
('frkrog', '2-MDA'),
('nareye', '2-MDA'),
('jugamil', '2-MDA'),
-- ENTORNO CLOUD (3-MDA)
('jolgome', '3-MDA'),
('viasen', '3-MDA'),
('facast', '3-MDA'),
('heboas', '3-MDA'),
('lalath', '3-MDA'),
('mimora', '3-MDA'),
('jabrio', '3-MDA'),
('nuberz', '3-MDA'),
('diegue', '3-MDA'),
('joeste', '3-MDA'),
('adcamp', '3-MDA'),
('anllos', '3-MDA'),
('nareye', '3-MDA'),
('bearuiz', '3-MDA'),
-- SOFT SKILLS (4-MDA)
('jopere', '4-MDA'),
('tocanto', '4-MDA'),
-- DATA PROJECTS (5-MDA)
('penipe', '5-MDA');

INSERT INTO "rel_coordinadores_grupos" ("id_coordinador", "id_grupo") VALUES
('m.herrera', 'MDA A 2526');

INSERT INTO "tareas" ("id_tarea", "id_bloque", "nombre", "fecha") VALUES
-- B1. FUNDAMENTOS
(1,  '1-MDA', 'Deadline Entregable Linux',           '2025-10-28'),
(2,  '1-MDA', 'Deadline Entregable Python',          '2025-11-03'),
(3,  '1-MDA', 'Deadline Entregable Docker',          '2025-11-04'),
(4,  '1-MDA', 'Deadline Entregable SQL',             '2025-11-10'),
(5,  '1-MDA', 'Deadline Entregable Ahorcado',        '2025-11-11'),
-- B2. TRATAMIENTO DEL DATO
(6,  '2-MDA', 'Deadline Entregable Kafka',           '2025-12-02'),
(7,  '2-MDA', 'Deadline Entregable APIs',            '2025-12-09'),
(8,  '2-MDA', 'Deadline Entregable Spark Streaming', '2025-12-15'),
-- B3. ENTORNO CLOUD
(9,  '3-MDA', 'Deadline Entregable GCP',             '2026-02-25'),
(10, '3-MDA', 'Deadline Entregable AWS',             '2026-03-24'),
(11, '3-MDA', 'Deadline Entregable Azure',           '2026-05-12'),
-- B4. SOFT SKILLS
(12, '4-MDA', 'Deadline Experiencia Internacional',              '2025-12-19'),
(13, '4-MDA', 'Deadline Confirmación Experiencia Internacional', '2026-02-23'),
-- B5. DATA PROJECTS
(14, '5-MDA', 'Deadline DP1',           '2025-12-08'),
(15, '5-MDA', 'Deadline pptx DP1',      '2025-12-10'),
(16, '5-MDA', 'Deadline Entrega DP2',   '2026-02-23'),
(17, '5-MDA', 'Deadline PPTX DP2',      '2026-02-25'),
(18, '5-MDA', 'Deadline 2º Hito',       '2026-04-02'),
(19, '5-MDA', 'Deadline DP3',           '2026-05-10'),
(20, '5-MDA', 'Deadline PPTX DP3',      '2026-05-12'),
(21, '5-MDA', 'DEADLINE Entregables',   '2026-06-01'),
-- TFM
(22, '5-MDA', 'Deadline Memoria TFM',       '2026-07-09'),
(23, '5-MDA', 'Deadline Autoevaluación TFM','2026-07-13'),
(24, '5-MDA', 'Deadline PPTX TFM',          '2026-07-15');

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

-- Vista para unificar eventos del calendario desde sesiones y tareas
CREATE VIEW vista_eventos AS
-- Eventos de sesiones (clases)
SELECT
    CONCAT('ses-', id_sesion) AS id_evento,
    'class' AS tipo,
    nombre AS titulo,
    id_bloque,
    id_sesion,
    aula,
    NULL AS id_profesor,
    (fecha || ' ' || hora_inicio)::TIMESTAMP AS fecha_inicio,
    (fecha || ' ' || hora_fin)::TIMESTAMP AS fecha_fin,
    CONCAT('Sesión en ', edificio, ', ', planta, ', ', aula) AS descripcion
FROM sesiones

UNION ALL

-- Eventos de tareas (entregas)
SELECT
    CONCAT('task-', id_tarea) AS id_evento,
    'deadline' AS tipo,
    nombre AS titulo,
    id_bloque,
    NULL AS id_sesion,
    NULL AS aula,
    NULL AS id_profesor,
    (fecha || ' 00:00:00')::TIMESTAMP AS fecha_inicio,
    (fecha || ' 23:59:59')::TIMESTAMP AS fecha_fin,
    descripcion
FROM tareas;
