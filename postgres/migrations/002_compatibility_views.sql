CREATE OR REPLACE VIEW compat.v_abastecimientos_legacy AS
SELECT
    a.legacy_source_id AS id,
    a.municipality_code AS cod_municipio,
    m.name AS municipio_nombre,
    pc.official_name AS nucleo_nombre,
    a.attributes ->> 'tipo_fuente' AS tipo_fuente,
    metric.metric_value AS caudal_l_s,
    a.status AS estado,
    a.geom
FROM core.asset a
JOIN catalog.asset_category c ON c.category_id = a.category_id AND c.code = 'ABASTECIMIENTO'
JOIN core.municipality m ON m.municipality_code = a.municipality_code
LEFT JOIN core.population_center pc ON pc.population_center_id = a.population_center_id
LEFT JOIN core.asset_metric metric ON metric.asset_id = a.asset_id AND metric.metric_code = 'CAUDAL_L_S';

CREATE OR REPLACE VIEW compat.v_saneamientos_legacy AS
SELECT
    a.legacy_source_id AS id,
    a.municipality_code AS cod_municipio,
    m.name AS municipio_nombre,
    pc.official_name AS nucleo_nombre,
    a.attributes ->> 'sistema' AS sistema,
    metric.metric_value::INTEGER AS poblacion_servida,
    a.status AS estado,
    a.geom
FROM core.asset a
JOIN catalog.asset_category c ON c.category_id = a.category_id AND c.code = 'SANEAMIENTO'
JOIN core.municipality m ON m.municipality_code = a.municipality_code
LEFT JOIN core.population_center pc ON pc.population_center_id = a.population_center_id
LEFT JOIN core.asset_metric metric ON metric.asset_id = a.asset_id AND metric.metric_code = 'POBLACION_SERVIDA';

CREATE OR REPLACE VIEW compat.v_equipamientos_legacy AS
SELECT
    a.legacy_source_id AS id,
    a.municipality_code AS cod_municipio,
    m.name AS municipio_nombre,
    COALESCE(a.service_level, a.attributes ->> 'categoria') AS categoria,
    a.attributes ->> 'subtipo' AS subtipo,
    a.asset_name AS nombre,
    metric.metric_value::INTEGER AS capacidad,
    a.manager AS gestion,
    a.geom
FROM core.asset a
JOIN catalog.asset_category c ON c.category_id = a.category_id AND c.asset_group = 'equipamiento'
JOIN core.municipality m ON m.municipality_code = a.municipality_code
LEFT JOIN core.asset_metric metric ON metric.asset_id = a.asset_id AND metric.metric_code = 'CAPACIDAD';

CREATE OR REPLACE VIEW compat.v_resumen_municipal AS
SELECT
    m.municipality_code AS codigo_municipio,
    m.name AS municipio,
    COUNT(*) FILTER (WHERE c.code = 'ABASTECIMIENTO') AS total_abastecimientos,
    COUNT(*) FILTER (WHERE c.code = 'SANEAMIENTO') AS total_saneamientos,
    COUNT(*) FILTER (WHERE c.asset_group = 'equipamiento') AS total_equipamientos
FROM core.municipality m
LEFT JOIN core.asset a ON a.municipality_code = m.municipality_code
LEFT JOIN catalog.asset_category c ON c.category_id = a.category_id
GROUP BY m.municipality_code, m.name;
