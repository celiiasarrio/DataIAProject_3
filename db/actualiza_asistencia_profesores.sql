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
