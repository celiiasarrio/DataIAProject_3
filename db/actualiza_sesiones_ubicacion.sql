ALTER TABLE sesiones ADD COLUMN IF NOT EXISTS edificio VARCHAR;
ALTER TABLE sesiones ADD COLUMN IF NOT EXISTS planta VARCHAR;

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
