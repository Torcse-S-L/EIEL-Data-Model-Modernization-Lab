CREATE TABLE IF NOT EXISTS catalog.asset_category (
    category_id SMALLSERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    asset_group TEXT NOT NULL CHECK (asset_group IN ('infraestructura', 'equipamiento'))
);

CREATE TABLE IF NOT EXISTS core.municipality (
    municipality_code VARCHAR(5) PRIMARY KEY,
    name TEXT NOT NULL,
    province TEXT NOT NULL,
    district TEXT,
    geom geometry(MultiPolygon, 4326) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS core.population_center (
    population_center_id BIGSERIAL PRIMARY KEY,
    municipality_code VARCHAR(5) NOT NULL REFERENCES core.municipality (municipality_code),
    official_name TEXT NOT NULL,
    population INTEGER NOT NULL,
    geom geometry(Point, 4326) NOT NULL,
    UNIQUE (municipality_code, official_name)
);

CREATE TABLE IF NOT EXISTS core.asset (
    asset_id BIGSERIAL PRIMARY KEY,
    category_id SMALLINT NOT NULL REFERENCES catalog.asset_category (category_id),
    municipality_code VARCHAR(5) NOT NULL REFERENCES core.municipality (municipality_code),
    population_center_id BIGINT REFERENCES core.population_center (population_center_id),
    legacy_source_table TEXT NOT NULL,
    legacy_source_id INTEGER NOT NULL,
    asset_name TEXT NOT NULL,
    status TEXT NOT NULL,
    manager TEXT,
    capacity NUMERIC(12,2),
    service_level TEXT,
    attributes JSONB NOT NULL DEFAULT '{}'::jsonb,
    geom geometry(Geometry, 4326) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (legacy_source_table, legacy_source_id)
);

CREATE TABLE IF NOT EXISTS core.asset_metric (
    asset_id BIGINT NOT NULL REFERENCES core.asset (asset_id) ON DELETE CASCADE,
    metric_code TEXT NOT NULL,
    metric_name TEXT NOT NULL,
    metric_value NUMERIC(12,2),
    unit TEXT,
    PRIMARY KEY (asset_id, metric_code)
);

CREATE INDEX IF NOT EXISTS idx_core_municipality_geom ON core.municipality USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_core_population_center_geom ON core.population_center USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_core_asset_geom ON core.asset USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_core_asset_municipality ON core.asset (municipality_code);
CREATE INDEX IF NOT EXISTS idx_core_asset_category ON core.asset (category_id);

INSERT INTO catalog.asset_category (code, name, asset_group)
VALUES
    ('ABASTECIMIENTO', 'Abastecimiento de agua', 'infraestructura'),
    ('SANEAMIENTO', 'Saneamiento', 'infraestructura'),
    ('CENTRO_CULTURAL', 'Centro cultural', 'equipamiento'),
    ('CONSULTORIO', 'Consultorio', 'equipamiento'),
    ('INSTALACION_DEPORTIVA', 'Instalacion deportiva', 'equipamiento')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    asset_group = EXCLUDED.asset_group;

INSERT INTO core.municipality (municipality_code, name, province, district, geom)
SELECT
    codigo_municipio,
    nombre,
    provincia,
    comarca,
    geom
FROM legacy.municipios
ON CONFLICT (municipality_code) DO UPDATE
SET name = EXCLUDED.name,
    province = EXCLUDED.province,
    district = EXCLUDED.district,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO core.population_center (municipality_code, official_name, population, geom)
SELECT
    codigo_municipio,
    nombre,
    poblacion,
    geom
FROM legacy.nucleos
ON CONFLICT (municipality_code, official_name) DO UPDATE
SET population = EXCLUDED.population,
    geom = EXCLUDED.geom;

INSERT INTO core.asset (
    category_id,
    municipality_code,
    population_center_id,
    legacy_source_table,
    legacy_source_id,
    asset_name,
    status,
    manager,
    capacity,
    service_level,
    attributes,
    geom
)
SELECT
    c.category_id,
    a.cod_municipio,
    pc.population_center_id,
    'legacy.abastecimientos',
    a.id,
    COALESCE(a.tipo_fuente || ' - ' || a.nucleo_nombre, a.tipo_fuente),
    a.estado,
    NULL,
    a.caudal_l_s,
    NULL,
    jsonb_build_object(
        'tipo_fuente', a.tipo_fuente,
        'municipio_nombre_legado', a.municipio_nombre,
        'nucleo_nombre_legado', a.nucleo_nombre
    ),
    a.geom
FROM legacy.abastecimientos a
JOIN catalog.asset_category c ON c.code = 'ABASTECIMIENTO'
LEFT JOIN core.population_center pc
    ON pc.municipality_code = a.cod_municipio
   AND pc.official_name = a.nucleo_nombre
ON CONFLICT (legacy_source_table, legacy_source_id) DO UPDATE
SET category_id = EXCLUDED.category_id,
    municipality_code = EXCLUDED.municipality_code,
    population_center_id = EXCLUDED.population_center_id,
    asset_name = EXCLUDED.asset_name,
    status = EXCLUDED.status,
    capacity = EXCLUDED.capacity,
    attributes = EXCLUDED.attributes,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO core.asset (
    category_id,
    municipality_code,
    population_center_id,
    legacy_source_table,
    legacy_source_id,
    asset_name,
    status,
    manager,
    capacity,
    service_level,
    attributes,
    geom
)
SELECT
    c.category_id,
    s.cod_municipio,
    pc.population_center_id,
    'legacy.saneamientos',
    s.id,
    COALESCE(s.sistema || ' - ' || s.nucleo_nombre, s.sistema),
    s.estado,
    NULL,
    s.poblacion_servida,
    NULL,
    jsonb_build_object(
        'sistema', s.sistema,
        'municipio_nombre_legado', s.municipio_nombre,
        'nucleo_nombre_legado', s.nucleo_nombre
    ),
    s.geom
FROM legacy.saneamientos s
JOIN catalog.asset_category c ON c.code = 'SANEAMIENTO'
LEFT JOIN core.population_center pc
    ON pc.municipality_code = s.cod_municipio
   AND pc.official_name = s.nucleo_nombre
ON CONFLICT (legacy_source_table, legacy_source_id) DO UPDATE
SET category_id = EXCLUDED.category_id,
    municipality_code = EXCLUDED.municipality_code,
    population_center_id = EXCLUDED.population_center_id,
    asset_name = EXCLUDED.asset_name,
    status = EXCLUDED.status,
    capacity = EXCLUDED.capacity,
    attributes = EXCLUDED.attributes,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO core.asset (
    category_id,
    municipality_code,
    population_center_id,
    legacy_source_table,
    legacy_source_id,
    asset_name,
    status,
    manager,
    capacity,
    service_level,
    attributes,
    geom
)
SELECT
    c.category_id,
    e.cod_municipio,
    NULL,
    'legacy.equipamientos',
    e.id,
    e.nombre,
    'operativo',
    e.gestion,
    e.capacidad,
    e.categoria,
    jsonb_build_object(
        'categoria', e.categoria,
        'subtipo', e.subtipo,
        'municipio_nombre_legado', e.municipio_nombre
    ),
    e.geom
FROM legacy.equipamientos e
JOIN catalog.asset_category c
    ON c.code = CASE
        WHEN LOWER(e.subtipo) = 'consultorio' THEN 'CONSULTORIO'
        WHEN LOWER(e.subtipo) = 'pabellon' THEN 'INSTALACION_DEPORTIVA'
        ELSE 'CENTRO_CULTURAL'
    END
ON CONFLICT (legacy_source_table, legacy_source_id) DO UPDATE
SET category_id = EXCLUDED.category_id,
    municipality_code = EXCLUDED.municipality_code,
    asset_name = EXCLUDED.asset_name,
    status = EXCLUDED.status,
    manager = EXCLUDED.manager,
    capacity = EXCLUDED.capacity,
    service_level = EXCLUDED.service_level,
    attributes = EXCLUDED.attributes,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO core.asset_metric (asset_id, metric_code, metric_name, metric_value, unit)
SELECT
    a.asset_id,
    'CAUDAL_L_S',
    'Caudal nominal',
    l.caudal_l_s,
    'l/s'
FROM core.asset a
JOIN legacy.abastecimientos l
    ON a.legacy_source_table = 'legacy.abastecimientos'
   AND a.legacy_source_id = l.id
ON CONFLICT (asset_id, metric_code) DO UPDATE
SET metric_value = EXCLUDED.metric_value,
    unit = EXCLUDED.unit;

INSERT INTO core.asset_metric (asset_id, metric_code, metric_name, metric_value, unit)
SELECT
    a.asset_id,
    'POBLACION_SERVIDA',
    'Poblacion servida',
    l.poblacion_servida,
    'habitantes'
FROM core.asset a
JOIN legacy.saneamientos l
    ON a.legacy_source_table = 'legacy.saneamientos'
   AND a.legacy_source_id = l.id
ON CONFLICT (asset_id, metric_code) DO UPDATE
SET metric_value = EXCLUDED.metric_value,
    unit = EXCLUDED.unit;

INSERT INTO core.asset_metric (asset_id, metric_code, metric_name, metric_value, unit)
SELECT
    a.asset_id,
    'CAPACIDAD',
    'Capacidad operativa',
    l.capacidad,
    'plazas'
FROM core.asset a
JOIN legacy.equipamientos l
    ON a.legacy_source_table = 'legacy.equipamientos'
   AND a.legacy_source_id = l.id
ON CONFLICT (asset_id, metric_code) DO UPDATE
SET metric_value = EXCLUDED.metric_value,
    unit = EXCLUDED.unit;
