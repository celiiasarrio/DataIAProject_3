-- Seed local/manual. Mantiene alumnos personalizados y reutiliza el catalogo canonico.

DROP VIEW IF EXISTS vista_eventos;

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
    perfil_detalles,
    perfil_documentos,
    correos,
    contenidos,
    solicitud_tutoria,
    user_sessions
RESTART IDENTITY CASCADE;

INSERT INTO "alumnos" ("id_alumno", "nombre", "apellido1", "apellido2", "correo", "contrasena", "url_foto", "rol", "grupo") VALUES
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
('cesaco', 'Celia', 'Sarrió', 'Colomar', 'cesaco@edem.es', 'Ce4@tLq67B', '', 'Alumno', 'MDA A 2526');
--('jaloru', 'Javier', 'Lopez', 'Ruiz', 'jaloru@edem.es', 'Ja9!rMx31F', '', 'Alumno', 'MIA 2526'),
--('feorma', 'Felix', 'Ortuño', 'Martinez', 'feorma@edem.es', 'Fe2#vNd84S', '', 'Alumno', 'MIA 2526');

INSERT INTO "profesores" ("id_profesor", "nombre", "apellido", "correo", "contrasena", "url_foto", "rol") VALUES
('penipe', 'Pedro', 'Nieto Pelaez', 'pedronietopelaez@gmail.com', 'PeNiPe2026!', '', 'Profesor'),
('sopina', 'Sofía', 'Pinilla', 'sofia.pinilla@edem.es', 'SoPi2026!', '', 'Profesor'),
('dapina', 'David', 'Pinilla', 'david.pinilla@climatetrade.com', 'DaPi2026!', '', 'Profesor'),
('macola', 'Marco', 'Colapietro', 'marco.colapietro@gft.com', 'MaCo2026!', '', 'Profesor'),
('anllos', 'Ángel', 'Llosa', 'angel.llosa@seidor.com', 'AnLl2026!', '', 'Profesor'),
('anrode', 'Ángel', 'Rodríguez', 'angel.rodriguez@sdggroup.com', 'AnRo2026!', '', 'Profesor'),
('frkrog', 'Franziska', 'Kröger', 'franziska.kroger@gft.com', 'FrKr2026!', '', 'Profesor'),
('nareye', 'Nacho', 'Reyes', 'nacho.reyes@bbva.com', 'NaRe2026!', '', 'Profesor'),
('jugamil', 'Juanjo', 'García Millán', 'juanjo.garcia@empresa.com', 'JuGa2026!', '', 'Profesor'),
('rusanc', 'Rubén', 'Sanchís', 'ruben.sanchis@empresa.com', 'RuSa2026!', '', 'Profesor'),
('jolgome', 'Jose Luis', 'Gómez', 'joseluis.gomez@ub.com', 'JoGo2026!', '', 'Profesor'),
('viasen', 'Vicent', 'Asensio', 'vicent.asensio@prima.com', 'ViAs2026!', '', 'Profesor'),
('facast', 'Fabio', 'Castro', 'fabio.castro@gft.com', 'FaCa2026!', '', 'Profesor'),
('heboas', 'Hernan', 'Boasso', 'hernan.boasso@gft.com', 'HeBo2026!', '', 'Profesor'),
('lalath', 'Lars', 'Lathan', 'lars.lathan@gft.com', 'LaLa2026!', '', 'Profesor'),
('mimora', 'Miguel', 'Moratilla', 'miguel.moratilla@mercadonatec.com', 'MiMo2026!', '', 'Profesor'),
('jabrio', 'Javier', 'Briones', 'javier.briones@radicant.com', 'JaBr2026!', '', 'Profesor'),
('nuberz', 'Nuria', 'Berzal', 'nuria.berzal@gft.com', 'NuBe2026!', '', 'Profesor'),
('diegue', 'Diego', 'Guerrero', 'diego.guerrero@gft.com', 'DiGu2026!', '', 'Profesor'),
('joeste', 'Jose Luis', 'Esteban', 'joseluis.esteban@medallatech.com', 'JoEs2026!', '', 'Profesor'),
('adcamp', 'Adriana', 'Campos', 'adriana.campos@sdggroup.com', 'AdCa2026!', '', 'Profesor'),
('bearuiz', 'Bea', 'Ruíz', 'bea.ruiz@openbank.com', 'BeRu2026!', '', 'Profesor'),
('jopere', 'Josiño', 'Pérez', 'josino.perez@experto.com', 'JoPe2026!', '', 'Profesor'),
('tocanto', 'Toni', 'Cantó', 'toni.canto@empresa.com', 'ToCa2026!', '', 'Profesor');

INSERT INTO "coordinadores" ("id_coordinador", "nombre", "apellido", "correo", "contrasena", "url_foto", "rol") VALUES
('m.herrera', 'Miguel', 'Herrera', 'mherrera@edem.es', 'MiHe2026!', '', 'Coordinador'),
('dev.cloud', 'Developer', 'Cloud', 'developer@edem.es', 'DevCloud2026!', '', 'Desarrollador');

INSERT INTO "perfil_detalles" (
    "id_usuario", "telefono", "ciudad", "idioma_preferido", "correo_personal",
    "linkedin", "github", "portfolio", "preferencia_contacto", "area_interes",
    "stack_tecnologico", "experiencia_actual", "disponibilidad", "preferencia_jornada",
    "idioma_app", "notificaciones_email", "notificaciones_push", "visibilidad_profesional",
    "permitir_cv_empleabilidad", "permitir_links_profesores", "tema", "estado", "fecha_actualizacion"
)
SELECT id_usuario, '', 'Valencia', 'es', '', '', '', '', 'email',
       'Data & AI', 'Python, SQL, Cloud', '', 'Por definir', 'Por definir',
       'es', TRUE, TRUE, TRUE, TRUE, TRUE, 'claro', 'Activo', NOW()
FROM (
    SELECT id_alumno AS id_usuario FROM alumnos
    UNION ALL
    SELECT id_profesor AS id_usuario FROM profesores
    UNION ALL
    SELECT id_coordinador AS id_usuario FROM coordinadores
) usuarios;

INSERT INTO "grupos" ("id_grupo", "nombre") VALUES
('MDA A 2526', 'MDA A 2526'),
('MIA 2526', 'MIA 2526');

INSERT INTO "bloques" ("id_bloque", "nombre") VALUES
('1-MDA', 'B1. FUNDAMENTOS'),
('2-MDA', 'B2. TRATAMIENTO DEL DATO'),
('3-MDA', 'B3. ENTORNO CLOUD'),
('4-MDA', 'SOFT SKILLS'),
('5-MDA', 'DATA PROJECTS'),
('6-MDA', 'HACKATONES'),
('7-MDA', 'EXPERIENCIA INTERNACIONAL');

INSERT INTO "sesiones" ("id_sesion", "id_bloque", "nombre", "fecha", "hora_inicio", "hora_fin", "aula") VALUES
('SES-1', '1-MDA', 'Introducción + Instalación de Software', '2025-09-29', '15:30', '19:30', 'AULA 102'),
('SES-2', '1-MDA', 'Git', '2025-09-30', '15:30', '19:30', 'AULA 102'),
('SES-3', '1-MDA', 'Python', '2025-10-01', '15:30', '19:30', 'AULA 102'),
('SES-4', '1-MDA', 'Git', '2025-10-02', '15:30', '19:30', 'AULA 102'),
('SES-5', '1-MDA', 'Python', '2025-10-06', '15:30', '19:30', 'AULA 102'),
('SES-6', '1-MDA', 'Python', '2025-10-07', '15:30', '19:30', 'AULA 102'),
('SES-7', '1-MDA', 'Python', '2025-10-08', '15:30', '19:30', 'AULA 102'),
('SES-8', '1-MDA', 'Docker', '2025-10-13', '15:30', '19:30', 'AULA 102'),
('SES-9', '1-MDA', 'Linux', '2025-10-14', '15:30', '19:30', 'AULA 102'),
('SES-10', '1-MDA', 'Docker', '2025-10-15', '15:30', '19:30', 'AULA 102'),
('SES-11', '1-MDA', 'Docker', '2025-10-16', '15:30', '19:30', 'AULA 102'),
('SES-12', '1-MDA', 'SQL', '2025-10-20', '15:30', '19:30', 'AULA 102'),
('SES-13', '1-MDA', 'Docker Compose', '2025-10-21', '15:30', '19:30', 'AULA 102'),
('SES-14', '1-MDA', 'SQL', '2025-10-22', '15:30', '19:30', 'AULA 102'),
('SES-15', '1-MDA', 'SQL', '2025-10-23', '15:30', '19:30', 'AULA 102'),
('SES-16', '1-MDA', 'Python', '2025-10-27', '15:30', '19:30', 'AULA 102'),
('SES-17', '1-MDA', 'E2E Módulo 0', '2025-10-28', '15:30', '19:30', 'AULA 102'),
('SES-18', '2-MDA', 'Intro Módulo + Origen', '2025-10-29', '15:30', '19:30', 'AULA 115'),
('SES-19', '2-MDA', 'Visualización de datos', '2025-10-30', '15:30', '19:30', 'AULA 115'),
('SES-20', '2-MDA', 'Visualización de datos', '2025-11-03', '15:30', '19:30', 'AULA 115'),
('SES-21', '4-MDA', 'Autoconocimiento', '2025-11-04', '15:30', '19:30', 'AULA 101'),
('SES-22', '2-MDA', 'Ingestión de Datos y NOSQL', '2025-11-05', '15:30', '19:30', 'AULA 115'),
('SES-23', '2-MDA', 'Ingestión de Datos y NOSQL', '2025-11-06', '15:30', '19:30', 'AULA 115'),
('SES-24', '2-MDA', 'Ingestión de Datos y NOSQL', '2025-11-10', '15:30', '19:30', 'AULA 115'),
('SES-25', '2-MDA', 'DBT', '2025-11-11', '15:30', '19:30', 'AULA 115'),
('SES-26', '2-MDA', 'DBT', '2025-11-12', '15:30', '19:30', 'AULA 115'),
('SES-27', '4-MDA', 'Comunicación', '2025-11-17', '15:30', '19:30', 'AULA 115'),
('SES-28', '2-MDA', 'Introducción a Kafka y programación básica con Kafka/Python', '2025-11-18', '15:30', '19:30', 'AULA 115'),
('SES-29', '4-MDA', 'Inteligencia Emocional', '2025-11-19', '15:30', '19:30', 'AULA 202'),
('SES-30', '2-MDA', 'Conceptos avanzados de Kafka. Ejercicios prácticos con KSQL, Kafka/Python en Cloud y caso de uso final(Kafka/Python)', '2025-11-21', '15:30', '19:30', 'AULA 111'),
('SES-31', '2-MDA', 'API Management', '2025-11-24', '15:30', '19:30', 'AULA 115'),
('SES-32', '2-MDA', 'API Management', '2025-11-25', '15:30', '19:30', 'AULA 115'),
('SES-33', '2-MDA', 'PySpark', '2025-11-26', '15:30', '19:30', 'AULA 115'),
('SES-34', '2-MDA', 'PySpark', '2025-12-01', '15:30', '19:30', 'AULA 115'),
('SES-35', '2-MDA', 'Blockchain', '2025-12-04', '15:30', '19:30', 'AULA 115'),
('SES-36', '2-MDA', 'E2E Módulo 1.2', '2025-12-09', '15:30', '19:30', 'AULA 115'),
('SES-37', '3-MDA', 'Cloud Intro', '2025-12-11', '15:30', '19:30', 'AULA 115'),
('SES-38', '3-MDA', 'Certificaciones Cloud', '2025-12-15', '15:30', '19:30', 'AULA 115'),
('SES-39', '3-MDA', 'Terraform', '2025-12-16', '15:30', '19:30', 'AULA 115'),
('SES-40', '3-MDA', 'GCP Project Setup', '2025-12-17', '15:30', '19:30', 'AULA 115'),
('SES-41', '3-MDA', 'Terraform', '2025-12-18', '15:30', '19:30', 'AULA 115'),
('SES-42', '3-MDA', 'Terraform', '2026-01-07', '15:30', '19:30', 'AULA 115'),
('SES-43', '3-MDA', 'GCP Almacenamiento', '2026-01-08', '15:30', '19:30', 'AULA 115'),
('SES-44', '3-MDA', 'GCP Almacenamiento', '2026-01-12', '15:30', '19:30', 'AULA 115'),
('SES-45', '3-MDA', 'GCP Almacenamiento', '2026-01-15', '15:30', '19:30', 'AULA 115'),
('SES-46', '3-MDA', 'GCP PubSub/DataFlow', '2026-01-19', '15:30', '19:30', 'AULA 115'),
('SES-47', '4-MDA', 'Comunicación eficaz', '2026-01-20', '15:30', '19:30', 'AULA 202'),
('SES-48', '3-MDA', 'GCP PubSub/DataFlow', '2026-01-21', '15:00', '18:00', 'AULA 115'),
('SES-49', '3-MDA', 'GCP PubSub/DataFlow', '2026-01-26', '15:30', '19:30', 'AULA 115'),
('SES-50', '3-MDA', 'GCP DataFlow', '2026-01-27', '15:30', '19:30', 'AULA 115'),
('SES-51', '3-MDA', 'GCP DataFlow', '2026-01-28', '15:00', '20:00', 'AULA 115'),
('SES-52', '3-MDA', 'GCP DataFlow', '2026-01-29', '15:30', '19:30', 'AULA 115'),
('SES-53', '3-MDA', 'GCP Funciones', '2026-02-03', '15:30', '19:30', 'AULA 115'),
('SES-54', '3-MDA', 'GCP Cloud Run', '2026-02-04', '15:30', '19:30', 'AULA 115'),
('SES-55', '3-MDA', 'Gobierno del Dato', '2026-02-05', '15:00', '19:00', 'AULA 115'),
('SES-56', '3-MDA', 'GCP Específicos', '2026-02-10', '15:30', '19:30', 'AULA 115'),
('SES-57', '3-MDA', 'Git Actions', '2026-02-11', '15:30', '19:00', 'AULA 115'),
('SES-58', '3-MDA', 'Calidad del Dato', '2026-02-12', '15:30', '19:30', 'AULA 115'),
('SES-59', '3-MDA', 'AWS Project Setup', '2026-02-17', '15:30', '19:30', 'AULA 115'),
('SES-60', '4-MDA', 'Productividad Sana', '2026-02-18', '15:30', '19:30', 'AULA 202'),
('SES-61', '3-MDA', 'GCP Específicos', '2026-02-19', '15:30', '19:30', 'AULA 115'),
('SES-62', '3-MDA', 'AWS Almacenamiento', '2026-02-23', '15:30', '19:30', 'AULA 115'),
('SES-63', '3-MDA', 'AWS Almacenamiento', '2026-02-25', '15:30', '19:30', 'AULA 115'),
('SES-64', '3-MDA', 'AWS Almacenamiento', '2026-03-02', '15:30', '19:30', 'AULA 115'),
('SES-66', '3-MDA', 'AWS Almacenamiento', '2026-03-03', '15:30', '19:30', 'AULA 115'),
('SES-67', '3-MDA', 'AWS Procesamiento', '2026-03-04', '15:30', '19:30', 'AULA 115'),
('SES-68', '3-MDA', 'AWS Procesamiento', '2026-03-05', '15:30', '19:30', 'AULA 115'),
('SES-70', '3-MDA', 'AWS Procesamiento', '2026-03-09', '15:30', '19:30', 'AULA 115'),
('SES-71', '3-MDA', 'AWS Procesamiento', '2026-03-10', '15:30', '19:30', 'AULA 115'),
('SES-72', '3-MDA', 'AWS E2E', '2026-03-11', '15:30', '19:30', 'AULA 115'),
('SES-73', '3-MDA', 'Certificaciones Cloud', '2026-03-12', '15:30', '19:30', 'AULA 115'),
('SES-74', '3-MDA', 'Airflow', '2026-03-23', '15:30', '19:30', 'AULA 115'),
('SES-75', '3-MDA', 'Agentes', '2026-03-24', '15:30', '19:30', 'AULA 115'),
('SES-76', '3-MDA', 'Azure Project Setup', '2026-03-31', '15:30', '19:30', 'AULA 115'),
('SES-77', '3-MDA', 'Azure Procesamiento', '2026-04-14', '15:30', '19:30', 'AULA 115'),
('SES-78', '3-MDA', 'Azure Procesamiento', '2026-04-15', '15:30', '19:30', 'AULA 115'),
('SES-79', '3-MDA', 'Azure Procesamiento', '2026-04-16', '15:30', '19:30', 'AULA 115'),
('SES-80', '3-MDA', 'Azure Almacenamiento', '2026-04-20', '15:30', '19:30', 'AULA 115'),
('SES-81', '3-MDA', 'Azure Almacenamiento', '2026-04-21', '15:30', '19:30', 'AULA 115'),
('SES-82', '4-MDA', 'Gestión de equipos y liderazgo', '2026-04-22', '15:30', '19:30', 'AULA 202'),
('SES-83', '4-MDA', 'Comunicación', '2026-04-27', '15:30', '19:30', 'AULA 115'),
('SES-84', '2-MDA', 'Data Products', '2026-05-20', '15:30', '19:30', 'AULA 115'),
('SES-85', '2-MDA', 'Prototipado', '2026-04-29', '15:30', '19:30', 'AULA 115'),
('SES-86', '3-MDA', 'Certificaciones Cloud', '2026-04-30', '15:30', '19:30', 'AULA 115'),
('SES-87', '3-MDA', 'Snowflake', '2026-05-11', '15:30', '19:30', 'AULA 115'),
('SES-88', '3-MDA', 'Snowflake', '2026-05-12', '15:30', '19:30', 'AULA 115'),
('SES-89', '3-MDA', 'Gen AI', '2026-05-14', '15:30', '19:30', 'AULA 115'),
('SES-90', '5-MDA', 'Defensa DATA/IA PROJECT + Dinámica', '2026-05-13', '15:30', '19:30', 'AULA 202');

UPDATE sesiones
SET
    edificio = CASE UPPER(aula)
        WHEN 'AULA 101' THEN 'EDEM'
        WHEN 'AULA 102' THEN 'EDEM'
        WHEN 'AULA 103' THEN 'EDEM'
        WHEN 'AULA 107' THEN 'EDEM'
        WHEN 'AULA 110' THEN 'EDEM'
        WHEN 'AULA 111' THEN 'EDEM'
        WHEN 'AULA 202' THEN 'EDEM'
        WHEN 'AULA 206' THEN 'EDEM'
        WHEN 'AULA 208' THEN 'EDEM'
        WHEN 'AULA 209' THEN 'EDEM'
        WHEN 'AUDITORIO 01' THEN 'EDEM'
        WHEN 'AULA 115' THEN 'LZD'
        ELSE edificio
    END,
    planta = CASE UPPER(aula)
        WHEN 'AULA 101' THEN '1'
        WHEN 'AULA 102' THEN '1'
        WHEN 'AULA 103' THEN '1'
        WHEN 'AULA 107' THEN '1'
        WHEN 'AULA 110' THEN '1'
        WHEN 'AULA 111' THEN '1'
        WHEN 'AULA 202' THEN '2'
        WHEN 'AULA 206' THEN '2'
        WHEN 'AULA 208' THEN '2'
        WHEN 'AULA 209' THEN '2'
        WHEN 'AUDITORIO 01' THEN 'BAJA'
        WHEN 'AULA 115' THEN '1'
        ELSE planta
    END
WHERE (edificio IS NULL OR edificio = '' OR planta IS NULL OR planta = '')
  AND UPPER(aula) IN (
      'AULA 101',
      'AULA 102',
      'AULA 103',
      'AULA 107',
      'AULA 110',
      'AULA 111',
      'AULA 202',
      'AULA 206',
      'AULA 208',
      'AULA 209',
      'AUDITORIO 01',
      'AULA 115'
  );

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
--('feorma', 'MIA 2526'),

INSERT INTO "rel_bloques_grupos" ("id_bloque", "id_grupo") VALUES
('1-MDA', 'MDA A 2526'),
('2-MDA', 'MDA A 2526'),
('3-MDA', 'MDA A 2526'),
('4-MDA', 'MDA A 2526'),
('5-MDA', 'MDA A 2526'),
('6-MDA', 'MDA A 2526'),
('7-MDA', 'MDA A 2526');

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
('rusanc', '2-MDA'),
-- ENTORNO CLOUD (3-MDA)
('jolgome', '3-MDA'),
('viasen', '3-MDA'),
('facast', '3-MDA'),
-- SOFT SKILLS (4-MDA)
('heboas', '4-MDA'),
('lalath', '4-MDA'),
-- DATA PROJECTS (5-MDA)
('penipe', '5-MDA'),
('sopina', '5-MDA'),
-- HACKATONES (6-MDA)
('macola', '6-MDA'),
('anllos', '6-MDA'),
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
('tocanto', '4-MDA');

INSERT INTO "rel_coordinadores_grupos" ("id_coordinador", "id_grupo") VALUES
('m.herrera', 'MDA A 2526');

INSERT INTO "tareas" ("id_tarea", "id_bloque", "nombre", "fecha") VALUES
(1, '1-MDA', 'Deadline Entregable Linux', '2025-10-28'),
(2, '1-MDA', 'Deadline Entregable Python', '2025-11-03'),
(3, '1-MDA', 'Deadline Entregable Docker', '2025-11-04'),
(4, '1-MDA', 'Deadline Entregable SQL', '2025-11-10'),
(5, '1-MDA', 'Deadline Entregable Ahorcado', '2025-11-11'),
(6, '2-MDA', 'Deadline Entregable Kafka', '2025-12-02'),
(7, '5-MDA', 'Deadline DP1', '2025-12-08'),
(8, '2-MDA', 'Deadline Entregable APIs', '2025-12-09'),
(9, '5-MDA', 'Deadline pptx DP1', '2025-12-10'),
(10, '2-MDA', 'Deadline Entregable Spark Streaming', '2025-12-15'),
(11, '4-MDA', 'Deadline Experiencia Internacional', '2025-12-19'),
(12, '4-MDA', 'Deadline Confirmación Experiencia Internacional', '2026-02-23'),
(13, '5-MDA', 'Deadline Entrega DP2', '2026-02-23'),
(14, '3-MDA', 'Deadline Entregable GCP', '2026-02-25'),
(15, '5-MDA', 'Deadline PPTX DP2', '2026-02-25'),
(16, '3-MDA', 'Deadline Entregable AWS', '2026-03-24'),
(17, '5-MDA', 'Deadline 2º Hito', '2026-04-02'),
(18, '5-MDA', 'Deadline DP3', '2026-05-10'),
(19, '3-MDA', 'Deadline Entregable Azure', '2026-05-12'),
(20, '5-MDA', 'Deadline PPTX DP2', '2026-05-12'),
(21, '5-MDA', 'DEADLINE Entregables', '2026-06-01'),
(22, '5-MDA', 'Deadline MEMORIA TFM', '2026-07-09'),
(23, '5-MDA', 'Deadline AUTOEVALUACIÓN TFM', '2026-07-13'),
(24, '5-MDA', 'Deadline PPTX TFM', '2026-07-15');

SELECT setval(pg_get_serial_sequence('tareas', 'id_tarea'), COALESCE(MAX(id_tarea), 1), true)
FROM tareas;

INSERT INTO "rel_alumno_tarea" ("id_alumno", "id_tarea", "nota")
SELECT
    rag.id_alumno,
    t.id_tarea,
    CASE
        WHEN t.id_tarea IN (7, 13, 18) THEN ROUND(
            LEAST(
                9.8,
                5.4
                + ((ABS(HASHTEXT(rag.id_alumno || '-' || t.id_tarea::TEXT)) % 38) * 0.10)
                + ((t.id_tarea % 5) * 0.12)
            )::NUMERIC,
            2
        )
        ELSE 10.00
    END
FROM rel_alumnos_grupos rag
JOIN rel_bloques_grupos rbg ON rbg.id_grupo = rag.id_grupo
JOIN tareas t ON t.id_bloque = rbg.id_bloque
WHERE t.fecha <= DATE '2026-05-05'
  AND t.id_tarea NOT IN (11, 12)
  AND UPPER(t.nombre) NOT LIKE '%PPT%'
  AND UPPER(t.nombre) NOT LIKE '%PPTX%'
  AND UPPER(t.nombre) NOT LIKE '%TFM%'
  AND UPPER(t.nombre) NOT LIKE '%EXPERIENCIA INTERNACIONAL%'
  AND UPPER(t.nombre) NOT LIKE '%CONFIRMACIÓN EXPERIENCIA INTERNACIONAL%'
  AND UPPER(t.nombre) NOT LIKE '%CONFIRMACIÃ³N EXPERIENCIA INTERNACIONAL%'
  AND (
      t.id_tarea IN (7, 13, 18)
      OR (
          UPPER(t.nombre) NOT LIKE '%DP1%'
          AND UPPER(t.nombre) NOT LIKE '%DP2%'
          AND UPPER(t.nombre) NOT LIKE '%DP3%'
          AND UPPER(t.nombre) NOT LIKE '%DATA PROJECT%'
          AND UPPER(t.nombre) NOT LIKE '%HITO%'
          AND (ABS(HASHTEXT(rag.id_alumno || '-delivery-' || t.id_tarea::TEXT)) % 5) <> 0
      )
  );

INSERT INTO "asistencia" ("id_alumno", "id_sesion", "fecha", "presente")
SELECT
    usuarios.id_usuario,
    s.id_sesion,
    s.fecha,
    (ABS(CAST(('x' || SUBSTRING(MD5(usuarios.id_usuario || '-attendance-' || s.id_sesion), 1, 16)) AS BIT(64))::BIGINT) % 10) < 8
FROM (
    SELECT id_alumno AS id_usuario FROM alumnos
    UNION ALL
    SELECT id_profesor AS id_usuario FROM profesores
    UNION ALL
    SELECT id_coordinador AS id_usuario FROM coordinadores
) usuarios
CROSS JOIN sesiones s
WHERE s.fecha < DATE '2026-05-05'
  AND LOWER(s.nombre) NOT LIKE '%tfm%'
  AND LOWER(s.nombre) NOT LIKE '%visita%'
  AND LOWER(s.nombre) NOT LIKE '%empleabilidad%'
  AND LOWER(s.nombre) NOT LIKE '%experiencia internacional%'
  AND LOWER(s.nombre) NOT LIKE '%foto orla%';

INSERT INTO "eventos" ("id", "tipo", "titulo", "id_bloque", "id_sesion", "aula", "id_profesor", "fecha_inicio", "fecha_fin", "descripcion")
SELECT
    CONCAT('ses-', s.id_sesion) AS id,
    'class' AS tipo,
    s.nombre AS titulo,
    s.id_bloque,
    s.id_sesion,
    COALESCE(s.aula, s.edificio) AS aula,
    CASE s.id_sesion
        WHEN 'SES-1' THEN 'penipe'
        WHEN 'SES-2' THEN 'penipe'
        WHEN 'SES-3' THEN 'sopina'
        WHEN 'SES-4' THEN 'penipe'
        WHEN 'SES-5' THEN 'sopina'
        WHEN 'SES-6' THEN 'sopina'
        WHEN 'SES-7' THEN 'sopina'
        WHEN 'SES-8' THEN 'dapina'
        WHEN 'SES-9' THEN 'sopina'
        WHEN 'SES-10' THEN 'dapina'
        WHEN 'SES-11' THEN 'dapina'
        WHEN 'SES-12' THEN 'sopina'
        WHEN 'SES-13' THEN 'dapina'
        WHEN 'SES-14' THEN 'sopina'
        WHEN 'SES-15' THEN 'sopina'
        WHEN 'SES-16' THEN 'sopina'
        WHEN 'SES-17' THEN 'penipe'
        WHEN 'SES-18' THEN 'penipe'
        WHEN 'SES-19' THEN 'jugamil'
        WHEN 'SES-20' THEN 'jugamil'
        WHEN 'SES-21' THEN 'jopere'
        WHEN 'SES-22' THEN 'frkrog'
        WHEN 'SES-23' THEN 'frkrog'
        WHEN 'SES-24' THEN 'frkrog'
        WHEN 'SES-25' THEN 'anrode'
        WHEN 'SES-26' THEN 'anrode'
        WHEN 'SES-27' THEN 'tocanto'
        WHEN 'SES-28' THEN 'rusanc'
        WHEN 'SES-29' THEN 'jopere'
        WHEN 'SES-30' THEN 'rusanc'
        WHEN 'SES-31' THEN 'macola'
        WHEN 'SES-32' THEN 'macola'
        WHEN 'SES-33' THEN 'nareye'
        WHEN 'SES-34' THEN 'nareye'
        WHEN 'SES-35' THEN 'macola'
        WHEN 'SES-36' THEN 'penipe'
        WHEN 'SES-37' THEN 'jolgome'
        WHEN 'SES-38' THEN 'lalath'
        WHEN 'SES-39' THEN 'penipe'
        WHEN 'SES-40' THEN 'frkrog'
        WHEN 'SES-41' THEN 'penipe'
        WHEN 'SES-42' THEN 'penipe'
        WHEN 'SES-43' THEN 'frkrog'
        WHEN 'SES-44' THEN 'frkrog'
        WHEN 'SES-45' THEN 'frkrog'
        WHEN 'SES-46' THEN 'jabrio'
        WHEN 'SES-47' THEN 'jopere'
        WHEN 'SES-48' THEN 'jabrio'
        WHEN 'SES-49' THEN 'jabrio'
        WHEN 'SES-50' THEN 'jabrio'
        WHEN 'SES-51' THEN 'jabrio'
        WHEN 'SES-52' THEN 'jabrio'
        WHEN 'SES-53' THEN 'adcamp'
        WHEN 'SES-54' THEN 'adcamp'
        WHEN 'SES-55' THEN 'joeste'
        WHEN 'SES-56' THEN 'penipe'
        WHEN 'SES-57' THEN 'nareye'
        WHEN 'SES-58' THEN 'joeste'
        WHEN 'SES-59' THEN 'lalath'
        WHEN 'SES-60' THEN 'jopere'
        WHEN 'SES-61' THEN 'penipe'
        WHEN 'SES-62' THEN 'facast'
        WHEN 'SES-63' THEN 'lalath'
        WHEN 'SES-64' THEN 'heboas'
        WHEN 'SES-65' THEN 'jabrio'
        WHEN 'SES-66' THEN 'facast'
        WHEN 'SES-67' THEN 'heboas'
        WHEN 'SES-68' THEN 'facast'
        WHEN 'SES-69' THEN 'mimora'
        WHEN 'SES-70' THEN 'facast'
        WHEN 'SES-71' THEN 'facast'
        WHEN 'SES-72' THEN 'penipe'
        WHEN 'SES-73' THEN 'lalath'
        WHEN 'SES-74' THEN 'viasen'
        WHEN 'SES-75' THEN 'jolgome'
        WHEN 'SES-76' THEN 'diegue'
        WHEN 'SES-77' THEN 'nuberz'
        WHEN 'SES-78' THEN 'nuberz'
        WHEN 'SES-79' THEN 'nuberz'
        WHEN 'SES-80' THEN 'nuberz'
        WHEN 'SES-81' THEN 'nuberz'
        WHEN 'SES-82' THEN 'jopere'
        WHEN 'SES-83' THEN 'tocanto'
        WHEN 'SES-84' THEN 'anllos'
        WHEN 'SES-85' THEN 'anllos'
        WHEN 'SES-86' THEN 'lalath'
        WHEN 'SES-87' THEN 'bearuiz'
        WHEN 'SES-88' THEN 'bearuiz'
        WHEN 'SES-89' THEN 'anllos'
        ELSE NULL
    END AS id_profesor,
    (s.fecha || ' ' || s.hora_inicio)::TIMESTAMP AS fecha_inicio,
    (s.fecha || ' ' || s.hora_fin)::TIMESTAMP AS fecha_fin,
    CASE
        WHEN s.aula IS NULL THEN CONCAT('Sesión online en ', s.edificio)
        ELSE CONCAT('Sesión en ', s.edificio, ', ', s.planta, ', ', s.aula)
    END AS descripcion
FROM sesiones s
WHERE s.fecha IS NOT NULL AND s.hora_inicio IS NOT NULL AND s.hora_fin IS NOT NULL

UNION ALL

SELECT
    CONCAT('task-', id_tarea) AS id,
    'delivery' AS tipo,
    nombre AS titulo,
    id_bloque,
    NULL AS id_sesion,
    NULL AS aula,
    NULL AS id_profesor,
    (fecha || ' 00:00:00')::TIMESTAMP AS fecha_inicio,
    (fecha || ' 23:59:59')::TIMESTAMP AS fecha_fin,
    COALESCE(descripcion, CONCAT('Entrega: ', nombre)) AS descripcion
FROM tareas
WHERE fecha IS NOT NULL;

INSERT INTO "eventos" ("id", "tipo", "titulo", "id_bloque", "id_sesion", "aula", "id_profesor", "fecha_inicio", "fecha_fin", "descripcion") VALUES
('ics-extra-001', 'class', 'JORNADA BIENVENIDA', '5-MDA', NULL, 'AUDITORIO 01', NULL, '2025-09-26 11:00:00', '2025-09-26 12:15:00', 'EDEM, PLANTA BAJA, AUDITORIO 01'),
('ics-extra-002', 'class', 'MÁSTER EN AULA', '5-MDA', NULL, 'AULA 110', NULL, '2025-09-26 12:15:00', '2025-09-26 18:00:00', 'EDEM, PLANTA 1, AULA 110'),
('ics-extra-004', 'class', 'CHARLAS EMPRESA - Robert Walters', '4-MDA', NULL, 'AUDITORIO 01', NULL, '2025-10-28 13:00:00', '2025-10-28 14:30:00', 'EDEM, PLANTA BAJA, AUDITORIO 01'),
('ics-extra-005', 'class', 'CHARLAS EMPRESA - Roig Arena', '4-MDA', NULL, 'AUDITORIO 01', NULL, '2025-10-29 13:00:00', '2025-10-29 14:30:00', 'EDEM, PLANTA BAJA, AUDITORIO 01'),
('ics-extra-006', 'class', 'CHARLAS EMPRESA - DHL', '4-MDA', NULL, 'AUDITORIO 01', NULL, '2025-10-30 13:00:00', '2025-10-30 14:30:00', 'EDEM, PLANTA BAJA, AUDITORIO 01'),
('ics-extra-007', 'class', 'TALLER EMPLEABILIDAD', '4-MDA', NULL, 'AULA 202', NULL, '2025-10-31 15:00:00', '2025-10-31 16:00:00', 'EDEM, PLANTA 2, AULA 202'),
('ics-extra-008', 'class', 'SPEED DATING', '4-MDA', NULL, NULL, NULL, '2025-11-04 08:30:00', '2025-11-04 10:30:00', 'Evento de empleabilidad'),
('ics-extra-009', 'class', 'FERIA EMPLEO', '4-MDA', NULL, NULL, NULL, '2025-11-04 11:00:00', '2025-11-04 14:00:00', 'Evento de empleabilidad'),
('ics-extra-010', 'class', 'MATCH & GO', '4-MDA', NULL, NULL, NULL, '2025-11-04 14:00:00', '2025-11-04 15:00:00', 'Evento de empleabilidad'),
('ics-extra-011', 'class', 'Explicación EI en aula', '4-MDA', NULL, 'AULA 202', NULL, '2025-11-19 15:00:00', '2025-11-19 15:30:00', 'EDEM, PLANTA 2, AULA 202'),
('ics-extra-012', 'class', 'Lanzamiento DATA PROJECT 1 + E2E Módulo 1.1', '5-MDA', NULL, 'AULA 115', 'penipe', '2025-11-20 15:30:00', '2025-11-20 19:30:00', 'LZD, PLANTA 1, AULA 115'),
('ics-extra-013', 'class', 'Jornada trabajo DATA PROJECT 1', '5-MDA', NULL, 'AULA 115', NULL, '2025-11-27 15:30:00', '2025-11-27 19:30:00', 'LZD, PLANTA 1, AULA 115'),
('ics-extra-014', 'class', 'Defensa DATA PROJECT 1', '5-MDA', NULL, 'AULA 115', NULL, '2025-12-10 15:00:00', '2025-12-10 19:00:00', 'LZD, PLANTA 1, AULA 115'),
('ics-extra-016', 'class', 'Lanzamiento DATA PROJECT 2', '5-MDA', NULL, 'AULA 115', NULL, '2026-02-02 15:30:00', '2026-02-02 19:30:00', 'LZD, PLANTA 1, AULA 115'),
('ics-extra-017', 'class', 'Jornada trabajo DATA PROJECT 2', '5-MDA', NULL, 'AULA 115', NULL, '2026-02-09 15:30:00', '2026-02-09 19:30:00', 'LZD, PLANTA 1, AULA 115'),
('ics-extra-018', 'class', 'HACKATÓN (NTT Data)', '6-MDA', NULL, 'AULA 115', NULL, '2026-02-16 15:30:00', '2026-02-16 19:30:00', 'LZD, PLANTA 1, AULA 115'),
('ics-extra-019', 'class', 'Visita NTT DATA', '4-MDA', NULL, 'Reunión de Microsoft Teams', NULL, '2026-02-24 15:00:00', '2026-02-24 17:00:00', 'Sesión online en Reunión de Microsoft Teams'),
('ics-extra-020', 'class', 'Defensa DATA PROJECT 2', '5-MDA', NULL, 'AULA 115', NULL, '2026-02-26 15:30:00', '2026-02-26 19:30:00', 'LZD, PLANTA 1, AULA 115'),
('ics-extra-021', 'class', 'TALLER EMPLEABILIDAD', '4-MDA', NULL, 'AULA 206', NULL, '2026-02-27 15:30:00', '2026-02-27 17:00:00', 'EDEM, PLANTA 2, AULA 206'),
('ics-extra-022', 'class', 'HACKATÓN (GFT)', '6-MDA', NULL, 'AULA 115', NULL, '2026-03-25 15:30:00', '2026-03-25 19:30:00', 'LZD, PLANTA 1, AULA 115'),
('ics-extra-023', 'class', 'HACKATÓN (GFT)', '6-MDA', NULL, 'AULA 115', NULL, '2026-03-26 15:30:00', '2026-03-26 19:30:00', 'LZD, PLANTA 1, AULA 115'),
('ics-extra-024', 'class', 'Visita GFT', '4-MDA', NULL, 'Reunión de Microsoft Teams', NULL, '2026-03-30 15:00:00', '2026-03-30 17:00:00', 'Sesión online en Reunión de Microsoft Teams'),
('ics-extra-025', 'class', 'Lanzamiento DATA/IA PROJECT 3', '5-MDA', NULL, 'AULA 202', NULL, '2026-04-01 15:30:00', '2026-04-01 19:30:00', 'EDEM, PLANTA 2, AULA 202'),
('ics-extra-026', 'class', 'Jornada trabajo DATA/IA PROJECT 3', '5-MDA', NULL, 'AULA 209', NULL, '2026-04-23 15:30:00', '2026-04-23 19:30:00', 'EDEM, PLANTA 2, AULA 209'),
('ics-extra-027', 'class', 'Explicación TFM', '5-MDA', NULL, 'AULA 209', NULL, '2026-04-24 15:00:00', '2026-04-24 15:30:00', 'EDEM, PLANTA 2, AULA 209'),
('ics-extra-028', 'class', 'FOTO ORLA', '5-MDA', NULL, NULL, NULL, '2026-04-24 16:30:00', '2026-04-24 17:00:00', 'Evento de máster'),
('ics-extra-029', 'international', 'EXPERIENCIA INTERNACIONAL MDA', '7-MDA', NULL, NULL, NULL, '2026-05-05 00:00:00', '2026-05-07 23:59:59', 'Experiencia internacional MDA'),
('ics-extra-030', 'class', 'Lanzamiento TFM', '5-MDA', NULL, 'AULA 208', NULL, '2026-05-15 15:30:00', '2026-05-15 17:30:00', 'EDEM, PLANTA 2, AULA 208 (ES)'),
('ics-extra-031', 'class', 'Defensa 1 TFM', '5-MDA', NULL, 'AULA 103', NULL, '2026-07-16 15:30:00', '2026-07-16 20:00:00', 'EDEM, PLANTA 1, AULA 103'),
('ics-extra-032', 'class', 'Defensa 2 TFM', '5-MDA', NULL, 'AULA 107', NULL, '2026-07-17 15:30:00', '2026-07-17 18:00:00', 'EDEM, PLANTA 1, AULA 107'),
('ics-extra-033', 'class', 'GRADUACIÓN MÁSTERS', '5-MDA', NULL, NULL, NULL, '2026-09-11 14:00:00', '2026-09-11 21:00:00', 'Graduación de másters');

INSERT INTO "asistencia" ("id_alumno", "id_sesion", "fecha", "presente")
SELECT DISTINCT
    e.id_profesor,
    s.id_sesion,
    COALESCE(s.fecha, CURRENT_DATE),
    TRUE
FROM eventos e
JOIN sesiones s ON s.id_sesion = e.id_sesion
WHERE e.tipo = 'class'
  AND e.id_profesor IS NOT NULL
  AND e.id_sesion IS NOT NULL
ON CONFLICT (id_alumno, id_sesion) DO UPDATE
SET fecha = EXCLUDED.fecha,
    presente = TRUE;

-- Vista para unificar eventos del calendario desde sesiones y tareas
CREATE OR REPLACE VIEW vista_eventos AS
SELECT
    CONCAT('ses-', s.id_sesion) AS id_evento,
    'class' AS tipo,
    s.nombre AS titulo,
    s.id_bloque,
    s.id_sesion,
    COALESCE(s.aula, s.edificio) AS aula,
    CASE s.id_sesion
        WHEN 'SES-1' THEN 'penipe'
        WHEN 'SES-2' THEN 'penipe'
        WHEN 'SES-3' THEN 'sopina'
        WHEN 'SES-4' THEN 'penipe'
        WHEN 'SES-5' THEN 'sopina'
        WHEN 'SES-6' THEN 'sopina'
        WHEN 'SES-7' THEN 'sopina'
        WHEN 'SES-8' THEN 'dapina'
        WHEN 'SES-9' THEN 'sopina'
        WHEN 'SES-10' THEN 'dapina'
        WHEN 'SES-11' THEN 'dapina'
        WHEN 'SES-12' THEN 'sopina'
        WHEN 'SES-13' THEN 'dapina'
        WHEN 'SES-14' THEN 'sopina'
        WHEN 'SES-15' THEN 'sopina'
        WHEN 'SES-16' THEN 'sopina'
        WHEN 'SES-17' THEN 'penipe'
        WHEN 'SES-18' THEN 'penipe'
        WHEN 'SES-19' THEN 'jugamil'
        WHEN 'SES-20' THEN 'jugamil'
        WHEN 'SES-21' THEN 'jopere'
        WHEN 'SES-22' THEN 'frkrog'
        WHEN 'SES-23' THEN 'frkrog'
        WHEN 'SES-24' THEN 'frkrog'
        WHEN 'SES-25' THEN 'anrode'
        WHEN 'SES-26' THEN 'anrode'
        WHEN 'SES-27' THEN 'tocanto'
        WHEN 'SES-28' THEN 'rusanc'
        WHEN 'SES-29' THEN 'jopere'
        WHEN 'SES-30' THEN 'rusanc'
        WHEN 'SES-31' THEN 'macola'
        WHEN 'SES-32' THEN 'macola'
        WHEN 'SES-33' THEN 'nareye'
        WHEN 'SES-34' THEN 'nareye'
        WHEN 'SES-35' THEN 'macola'
        WHEN 'SES-36' THEN 'penipe'
        WHEN 'SES-37' THEN 'jolgome'
        WHEN 'SES-38' THEN 'lalath'
        WHEN 'SES-39' THEN 'penipe'
        WHEN 'SES-40' THEN 'frkrog'
        WHEN 'SES-41' THEN 'penipe'
        WHEN 'SES-42' THEN 'penipe'
        WHEN 'SES-43' THEN 'frkrog'
        WHEN 'SES-44' THEN 'frkrog'
        WHEN 'SES-45' THEN 'frkrog'
        WHEN 'SES-46' THEN 'jabrio'
        WHEN 'SES-47' THEN 'jopere'
        WHEN 'SES-48' THEN 'jabrio'
        WHEN 'SES-49' THEN 'jabrio'
        WHEN 'SES-50' THEN 'jabrio'
        WHEN 'SES-51' THEN 'jabrio'
        WHEN 'SES-52' THEN 'jabrio'
        WHEN 'SES-53' THEN 'adcamp'
        WHEN 'SES-54' THEN 'adcamp'
        WHEN 'SES-55' THEN 'joeste'
        WHEN 'SES-56' THEN 'penipe'
        WHEN 'SES-57' THEN 'nareye'
        WHEN 'SES-58' THEN 'joeste'
        WHEN 'SES-59' THEN 'lalath'
        WHEN 'SES-60' THEN 'jopere'
        WHEN 'SES-61' THEN 'penipe'
        WHEN 'SES-62' THEN 'facast'
        WHEN 'SES-63' THEN 'lalath'
        WHEN 'SES-64' THEN 'heboas'
        WHEN 'SES-65' THEN 'jabrio'
        WHEN 'SES-66' THEN 'facast'
        WHEN 'SES-67' THEN 'heboas'
        WHEN 'SES-68' THEN 'facast'
        WHEN 'SES-69' THEN 'mimora'
        WHEN 'SES-70' THEN 'facast'
        WHEN 'SES-71' THEN 'facast'
        WHEN 'SES-72' THEN 'penipe'
        WHEN 'SES-73' THEN 'lalath'
        WHEN 'SES-74' THEN 'viasen'
        WHEN 'SES-75' THEN 'jolgome'
        WHEN 'SES-76' THEN 'diegue'
        WHEN 'SES-77' THEN 'nuberz'
        WHEN 'SES-78' THEN 'nuberz'
        WHEN 'SES-79' THEN 'nuberz'
        WHEN 'SES-80' THEN 'nuberz'
        WHEN 'SES-81' THEN 'nuberz'
        WHEN 'SES-82' THEN 'jopere'
        WHEN 'SES-83' THEN 'tocanto'
        WHEN 'SES-84' THEN 'anllos'
        WHEN 'SES-85' THEN 'anllos'
        WHEN 'SES-86' THEN 'lalath'
        WHEN 'SES-87' THEN 'bearuiz'
        WHEN 'SES-88' THEN 'bearuiz'
        WHEN 'SES-89' THEN 'anllos'
        ELSE NULL
    END AS id_profesor,
    (s.fecha || ' ' || s.hora_inicio)::TIMESTAMP AS fecha_inicio,
    (s.fecha || ' ' || s.hora_fin)::TIMESTAMP AS fecha_fin,
    CASE
        WHEN s.aula IS NULL THEN CONCAT('Sesión online en ', s.edificio)
        ELSE CONCAT('Sesión en ', s.edificio, ', ', s.planta, ', ', s.aula)
    END AS descripcion
FROM sesiones s

UNION ALL

SELECT
    CONCAT('task-', id_tarea) AS id_evento,
    'delivery' AS tipo,
    nombre AS titulo,
    id_bloque,
    NULL AS id_sesion,
    NULL AS aula,
    NULL AS id_profesor,
    (fecha || ' 00:00:00')::TIMESTAMP AS fecha_inicio,
    (fecha || ' 23:59:59')::TIMESTAMP AS fecha_fin,
    COALESCE(descripcion, CONCAT('Entrega: ', nombre)) AS descripcion
FROM tareas;

-- Tabla de solicitudes de tutoría
CREATE TABLE IF NOT EXISTS solicitud_tutoria (
    id VARCHAR(255) PRIMARY KEY,
    id_alumno VARCHAR(255) NOT NULL REFERENCES alumnos(id_alumno),
    id_profesor VARCHAR(255) NOT NULL,
    motivo TEXT NOT NULL,
    estado VARCHAR(50) DEFAULT 'Pendiente' NOT NULL,
    opcion1_fecha_hora TIMESTAMP NOT NULL,
    opcion2_fecha_hora TIMESTAMP NOT NULL,
    opcion3_fecha_hora TIMESTAMP,
    fecha_hora_confirmada TIMESTAMP,
    propuesta_alternativa_fecha_hora TIMESTAMP,
    comentario_profesor TEXT,
    comentario_alumno TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Tabla de sesiones de usuario para múltiples conexiones simultáneas
CREATE TABLE IF NOT EXISTS user_sessions (
    id VARCHAR(255) PRIMARY KEY,
    id_usuario VARCHAR(255) NOT NULL,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(255),
    ip_address VARCHAR(45),
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_expiracion TIMESTAMP NOT NULL,
    activa BOOLEAN DEFAULT true NOT NULL,
    INDEX idx_id_usuario (id_usuario),
    INDEX idx_token_hash (token_hash)
);
