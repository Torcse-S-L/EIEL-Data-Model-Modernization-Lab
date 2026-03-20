CREATE TABLE IF NOT EXISTS legacy.municipios (
    codigo_municipio VARCHAR(5) PRIMARY KEY,
    nombre TEXT NOT NULL,
    provincia TEXT NOT NULL DEFAULT 'Malaga',
    comarca TEXT,
    geom geometry(MultiPolygon, 4326) NOT NULL
);

CREATE TABLE IF NOT EXISTS legacy.nucleos (
    id SERIAL PRIMARY KEY,
    codigo_municipio VARCHAR(5) NOT NULL,
    nombre TEXT NOT NULL,
    poblacion INTEGER NOT NULL,
    geom geometry(Point, 4326) NOT NULL
);

CREATE TABLE IF NOT EXISTS legacy.abastecimientos (
    id SERIAL PRIMARY KEY,
    cod_municipio VARCHAR(5) NOT NULL,
    municipio_nombre TEXT NOT NULL,
    nucleo_nombre TEXT,
    tipo_fuente TEXT NOT NULL,
    caudal_l_s NUMERIC(12,2),
    estado TEXT NOT NULL,
    geom geometry(Point, 4326) NOT NULL
);

CREATE TABLE IF NOT EXISTS legacy.saneamientos (
    id SERIAL PRIMARY KEY,
    cod_municipio VARCHAR(5) NOT NULL,
    municipio_nombre TEXT NOT NULL,
    nucleo_nombre TEXT,
    sistema TEXT NOT NULL,
    poblacion_servida INTEGER,
    estado TEXT NOT NULL,
    geom geometry(Point, 4326) NOT NULL
);

CREATE TABLE IF NOT EXISTS legacy.equipamientos (
    id SERIAL PRIMARY KEY,
    cod_municipio VARCHAR(5) NOT NULL,
    municipio_nombre TEXT NOT NULL,
    categoria TEXT NOT NULL,
    subtipo TEXT NOT NULL,
    nombre TEXT NOT NULL,
    capacidad INTEGER,
    gestion TEXT,
    geom geometry(Point, 4326) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_legacy_municipios_geom ON legacy.municipios USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_legacy_nucleos_geom ON legacy.nucleos USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_legacy_abastecimientos_geom ON legacy.abastecimientos USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_legacy_saneamientos_geom ON legacy.saneamientos USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_legacy_equipamientos_geom ON legacy.equipamientos USING GIST (geom);

CREATE OR REPLACE VIEW legacy.v_resumen_municipal AS
SELECT
    m.codigo_municipio,
    m.nombre AS municipio,
    COUNT(DISTINCT a.id) AS total_abastecimientos,
    COUNT(DISTINCT s.id) AS total_saneamientos,
    COUNT(DISTINCT e.id) AS total_equipamientos
FROM legacy.municipios m
LEFT JOIN legacy.abastecimientos a ON a.cod_municipio = m.codigo_municipio
LEFT JOIN legacy.saneamientos s ON s.cod_municipio = m.codigo_municipio
LEFT JOIN legacy.equipamientos e ON e.cod_municipio = m.codigo_municipio
GROUP BY m.codigo_municipio, m.nombre;
