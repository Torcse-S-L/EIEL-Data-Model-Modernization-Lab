INSERT INTO legacy.municipios (codigo_municipio, nombre, provincia, comarca, geom)
VALUES
    ('29015', 'Antequera', 'Malaga', 'Antequera', ST_Multi(ST_GeomFromText('POLYGON((-4.70 37.00,-4.50 37.00,-4.50 37.15,-4.70 37.15,-4.70 37.00))', 4326))),
    ('29084', 'Ronda', 'Malaga', 'Serrania de Ronda', ST_Multi(ST_GeomFromText('POLYGON((-5.25 36.68,-5.05 36.68,-5.05 36.82,-5.25 36.82,-5.25 36.68))', 4326))),
    ('29075', 'Nerja', 'Malaga', 'Axarquia', ST_Multi(ST_GeomFromText('POLYGON((-3.95 36.72,-3.75 36.72,-3.75 36.82,-3.95 36.82,-3.95 36.72))', 4326)))
ON CONFLICT (codigo_municipio) DO UPDATE
SET nombre = EXCLUDED.nombre,
    provincia = EXCLUDED.provincia,
    comarca = EXCLUDED.comarca,
    geom = EXCLUDED.geom;

INSERT INTO legacy.nucleos (codigo_municipio, nombre, poblacion, geom)
VALUES
    ('29015', 'Antequera', 41239, ST_GeomFromText('POINT(-4.56 37.02)', 4326)),
    ('29015', 'Cartaojal', 1205, ST_GeomFromText('POINT(-4.63 37.07)', 4326)),
    ('29084', 'Ronda', 33712, ST_GeomFromText('POINT(-5.16 36.74)', 4326)),
    ('29075', 'Nerja', 21418, ST_GeomFromText('POINT(-3.88 36.75)', 4326))
ON CONFLICT DO NOTHING;

INSERT INTO legacy.abastecimientos (cod_municipio, municipio_nombre, nucleo_nombre, tipo_fuente, caudal_l_s, estado, geom)
VALUES
    ('29015', 'Antequera', 'Antequera', 'Captacion subterranea', 82.50, 'operativo', ST_GeomFromText('POINT(-4.57 37.03)', 4326)),
    ('29015', 'Antequera', 'Cartaojal', 'Deposito regulador', 14.20, 'operativo', ST_GeomFromText('POINT(-4.62 37.08)', 4326)),
    ('29084', 'Ronda', 'Ronda', 'ETAP', 76.80, 'mantenimiento', ST_GeomFromText('POINT(-5.17 36.75)', 4326)),
    ('29075', 'Nerja', 'Nerja', 'Captacion superficial', 64.40, 'operativo', ST_GeomFromText('POINT(-3.89 36.76)', 4326))
ON CONFLICT DO NOTHING;

INSERT INTO legacy.saneamientos (cod_municipio, municipio_nombre, nucleo_nombre, sistema, poblacion_servida, estado, geom)
VALUES
    ('29015', 'Antequera', 'Antequera', 'EDAR urbana', 40500, 'operativo', ST_GeomFromText('POINT(-4.55 37.01)', 4326)),
    ('29084', 'Ronda', 'Ronda', 'Colector principal', 32900, 'operativo', ST_GeomFromText('POINT(-5.18 36.73)', 4326)),
    ('29075', 'Nerja', 'Nerja', 'Estacion de bombeo', 21000, 'mantenimiento', ST_GeomFromText('POINT(-3.87 36.74)', 4326))
ON CONFLICT DO NOTHING;

INSERT INTO legacy.equipamientos (cod_municipio, municipio_nombre, categoria, subtipo, nombre, capacidad, gestion, geom)
VALUES
    ('29015', 'Antequera', 'cultural', 'centro cultural', 'Centro Cultural Santa Clara', 450, 'municipal', ST_GeomFromText('POINT(-4.56 37.01)', 4326)),
    ('29015', 'Antequera', 'sanitario', 'consultorio', 'Consultorio Cartaojal', 35, 'mixta', ST_GeomFromText('POINT(-4.63 37.07)', 4326)),
    ('29084', 'Ronda', 'deportivo', 'pabellon', 'Pabellon El Fuerte', 620, 'municipal', ST_GeomFromText('POINT(-5.15 36.75)', 4326)),
    ('29075', 'Nerja', 'cultural', 'centro cultural', 'Centro Cultural Villa de Nerja', 280, 'municipal', ST_GeomFromText('POINT(-3.88 36.75)', 4326))
ON CONFLICT DO NOTHING;
