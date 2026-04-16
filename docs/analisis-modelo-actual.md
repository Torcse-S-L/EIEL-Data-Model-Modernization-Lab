# Analisis del Modelo Actual

## Inventario del escenario legado simulado

| Tabla/Vista | Funcion | Problemas detectados |
|------------|---------|----------------------|
| `legacy.municipios` | Limite municipal y metadatos | Informacion territorial sin relacion formal con el resto de dominios |
| `legacy.nucleos` | Nucleos de poblacion | Sin clave foranea explicita hacia municipio |
| `legacy.abastecimientos` | Infraestructura de agua | Redundancia de nombre de municipio y nucleo |
| `legacy.saneamientos` | Infraestructura de saneamiento | Estructura paralela a abastecimientos con muy bajo reaprovechamiento |
| `legacy.equipamientos` | Equipamientos municipales | Variabilidad funcional resuelta por columnas de texto libres |
| `legacy.v_resumen_municipal` | Resumen operativo | Dependencia de tablas heterogeneas y costosas de mantener |

## Hallazgos principales

### 1. Duplicidad estructural

Abastecimientos y saneamientos comparten buena parte de su semantica: pertenecen a un municipio, opcionalmente a un nucleo, tienen estado, geometria y una metrica principal. Mantenerlos en tablas completamente separadas incrementa el coste de evolucion y multiplica la logica SQL.

### 2. Integridad referencial debil

El modelo legado trabaja con `cod_municipio`, `municipio_nombre` y `nucleo_nombre` como campos repetidos, lo que facilita divergencias ortograficas, referencias huerfanas y dependencias implícitas en aplicaciones.

### 3. Falta de tipificacion controlada

La clasificacion funcional de equipamientos se expresa como texto libre en `categoria` y `subtipo`. Esto complica filtrado, analitica y explotacion por otros sistemas.

### 4. Complejidad de consultas

Las aplicaciones consumidoras deben unir tablas heterogeneas o replicar reglas de negocio para obtener una vista integrada del territorio. Esta complejidad es uno de los principales puntos de friccion para SITMAP y herramientas GIS de escritorio.

## Criterios de mejora

- Unificar patrones comunes de infraestructuras y equipamientos.
- Mantener una clave de trazabilidad hacia el origen para migraciones auditables.
- Externalizar categorias y metricas repetibles.
- Proteger el cambio con vistas de compatibilidad y comprobaciones de calidad.
