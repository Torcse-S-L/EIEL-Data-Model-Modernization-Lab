CREATE OR REPLACE VIEW qa.v_data_quality_checks AS
SELECT
    'municipalities_without_geometry' AS check_name,
    CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'error' END AS status,
    'Municipios sin geometria' AS detail,
    COUNT(*)::BIGINT AS affected_rows
FROM core.municipality
WHERE geom IS NULL

UNION ALL

SELECT
    'population_centers_without_municipality' AS check_name,
    CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'error' END AS status,
    'Nucleos sin municipio asociado' AS detail,
    COUNT(*)::BIGINT AS affected_rows
FROM core.population_center pc
LEFT JOIN core.municipality m ON m.municipality_code = pc.municipality_code
WHERE m.municipality_code IS NULL

UNION ALL

SELECT
    'assets_without_category' AS check_name,
    CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'error' END AS status,
    'Activos sin categoria normalizada' AS detail,
    COUNT(*)::BIGINT AS affected_rows
FROM core.asset a
LEFT JOIN catalog.asset_category c ON c.category_id = a.category_id
WHERE c.category_id IS NULL

UNION ALL

SELECT
    'assets_without_population_center_mapping' AS check_name,
    CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'warning' END AS status,
    'Infraestructuras sin nucleo normalizado asociado' AS detail,
    COUNT(*)::BIGINT AS affected_rows
FROM core.asset a
JOIN catalog.asset_category c ON c.category_id = a.category_id
WHERE c.asset_group = 'infraestructura'
  AND a.population_center_id IS NULL

UNION ALL

SELECT
    'invalid_asset_geometries' AS check_name,
    CASE WHEN COUNT(*) = 0 THEN 'ok' ELSE 'error' END AS status,
    'Activos con geometrias invalidas' AS detail,
    COUNT(*)::BIGINT AS affected_rows
FROM core.asset
WHERE NOT ST_IsValid(geom);

CREATE OR REPLACE VIEW qa.v_model_inventory AS
SELECT
    'legacy' AS model_layer,
    'municipios' AS entity_name,
    COUNT(*)::BIGINT AS total_rows
FROM legacy.municipios
UNION ALL
SELECT 'legacy', 'nucleos', COUNT(*)::BIGINT FROM legacy.nucleos
UNION ALL
SELECT 'legacy', 'abastecimientos', COUNT(*)::BIGINT FROM legacy.abastecimientos
UNION ALL
SELECT 'legacy', 'saneamientos', COUNT(*)::BIGINT FROM legacy.saneamientos
UNION ALL
SELECT 'legacy', 'equipamientos', COUNT(*)::BIGINT FROM legacy.equipamientos
UNION ALL
SELECT 'normalized', 'municipality', COUNT(*)::BIGINT FROM core.municipality
UNION ALL
SELECT 'normalized', 'population_center', COUNT(*)::BIGINT FROM core.population_center
UNION ALL
SELECT 'normalized', 'asset', COUNT(*)::BIGINT FROM core.asset
UNION ALL
SELECT 'normalized', 'asset_metric', COUNT(*)::BIGINT FROM core.asset_metric;
