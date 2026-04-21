# Diccionario de Datos

## `catalog.asset_category`

| Campo | Tipo | Descripcion |
|------|------|-------------|
| `category_id` | `smallserial` | Identificador interno |
| `code` | `text` | Codigo funcional estable |
| `name` | `text` | Etiqueta descriptiva |
| `asset_group` | `text` | Agrupacion principal: infraestructura/equipamiento |

## `core.municipality`

| Campo | Tipo | Descripcion |
|------|------|-------------|
| `municipality_code` | `varchar(5)` | Codigo oficial del municipio |
| `name` | `text` | Denominacion municipal |
| `province` | `text` | Provincia |
| `district` | `text` | Comarca o ambito equivalente |
| `geom` | `geometry(MultiPolygon, 4326)` | Geometria municipal |

## `core.population_center`

| Campo | Tipo | Descripcion |
|------|------|-------------|
| `population_center_id` | `bigserial` | Identificador interno |
| `municipality_code` | `varchar(5)` | Municipio al que pertenece |
| `official_name` | `text` | Nombre oficial del nucleo |
| `population` | `integer` | Poblacion asociada |
| `geom` | `geometry(Point, 4326)` | Localizacion del nucleo |

## `core.asset`

| Campo | Tipo | Descripcion |
|------|------|-------------|
| `asset_id` | `bigserial` | Identificador del activo |
| `category_id` | `smallint` | Categoria normalizada |
| `municipality_code` | `varchar(5)` | Municipio propietario |
| `population_center_id` | `bigint` | Nucleo asociado, si existe |
| `legacy_source_table` | `text` | Tabla origen de la migracion |
| `legacy_source_id` | `integer` | Id origen de la migracion |
| `asset_name` | `text` | Nombre funcional o denominacion |
| `status` | `text` | Estado operativo |
| `manager` | `text` | Gestor o titular operativo |
| `capacity` | `numeric(12,2)` | Valor principal agregado cuando aplica |
| `service_level` | `text` | Segmento funcional adicional |
| `attributes` | `jsonb` | Atributos variables del dominio |
| `geom` | `geometry(Geometry, 4326)` | Geometria del activo |

## `core.asset_metric`

| Campo | Tipo | Descripcion |
|------|------|-------------|
| `asset_id` | `bigint` | Activo al que pertenece |
| `metric_code` | `text` | Codigo de la metrica |
| `metric_name` | `text` | Nombre descriptivo |
| `metric_value` | `numeric(12,2)` | Valor numerico |
| `unit` | `text` | Unidad de medida |

## Vistas de compatibilidad

| Vista | Uso previsto |
|------|--------------|
| `compat.v_abastecimientos_legacy` | Reproducir la interfaz de lectura del dominio de abastecimiento |
| `compat.v_saneamientos_legacy` | Reproducir la interfaz de lectura del dominio de saneamiento |
| `compat.v_equipamientos_legacy` | Reproducir la interfaz de lectura del dominio de equipamientos |
| `compat.v_resumen_municipal` | Sustituir agregaciones usadas por procesos de soporte |
