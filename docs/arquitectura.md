# Arquitectura de la Solucion

## Vision general

La propuesta separa con claridad tres capas:

1. **Modelo legado**: reproduce los problemas habituales del escenario EIEL actual, como redundancia de nombres de municipio y nucleo, ausencia de claves foraneas y estructuras paralelas por dominio funcional.
2. **Modelo objetivo**: normaliza municipios, nucleos, activos y metricas, manteniendo las geometrías en PostGIS y reduciendo duplicidad estructural.
3. **Capa de compatibilidad**: ofrece vistas SQL con la misma forma que el modelo legado para minimizar impacto sobre SITMAP, QGIS y procesos de exportacion.

## Componentes

| Componente | Funcion |
|-----------|---------|
| `legacy.*` | Simula el estado actual para analisis y trazabilidad |
| `catalog.asset_category` | Catalogo de categorias funcionales |
| `core.municipality` | Entidad territorial normalizada |
| `core.population_center` | Nucleos de poblacion vinculados a municipio |
| `core.asset` | Activo generico para infraestructuras y equipamientos |
| `core.asset_metric` | Metricas especializadas desacopladas del activo |
| `compat.*` | Vistas de compatibilidad con forma legacy |
| `qa.*` | Controles de calidad y visibilidad operativa |

## Flujo de transformacion

```mermaid
flowchart LR
    A[Esquema legacy] --> B[Inventario y diagnostico]
    B --> C[Normalizacion de entidades territoriales]
    C --> D[Consolidacion de activos]
    D --> E[Separacion de metricas y atributos]
    E --> F[Vistas de compatibilidad]
    F --> G[Validacion QA + pruebas]
```

## Principios de diseno

- **Normalizacion pragmatica**: se evita una descomposicion excesiva que complique mantenimiento.
- **Compatibilidad gradual**: las aplicaciones existentes pueden leer de vistas mientras se adapta el acceso al nuevo modelo.
- **Trazabilidad de migracion**: cada activo conserva su origen mediante `legacy_source_table` y `legacy_source_id`.
- **Preparacion para rendimiento**: el modelo objetivo incorpora índices espaciales y btree desde el inicio.
- **Extensibilidad**: nuevas categorias o metricas pueden incorporarse sin multiplicar tablas por dominio.

## Riesgos cubiertos

- Redundancia de atributos territoriales.
- Dificultad para introducir nuevas infraestructuras o equipamientos.
- Complejidad de consultas en aplicaciones consumidoras.
- Falta de puntos de control de calidad automatizables.
