# EIEL Data Model Modernization Lab

[![CI — Validación](https://github.com/Torcse-S-L/EIEL-Data-Model-Modernization-Lab/actions/workflows/ci.yml/badge.svg)](https://github.com/Torcse-S-L/EIEL-Data-Model-Modernization-Lab/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

Plataforma para analizar, rediseñar y validar la modernización del modelo de datos EIEL
sobre **PostgreSQL/PostGIS**. Incluye esquema legado de referencia, modelo normalizado
objetivo, capa de compatibilidad y controles de calidad automatizados.

## Objetivo

Demostrar un proceso completo de modernización de modelo de datos EIEL aplicable a
entornos reales, incluyendo:

- Inventario del modelo legado y detección de redundancias estructurales.
- Diseño de un modelo lógico y físico normalizado con índices espaciales.
- Migración reproducible desde el esquema legado hacia el modelo objetivo.
- Vistas de compatibilidad para preservar las interfaces de SITMAP y el plugin EIEL de QGIS.
- Controles de calidad de datos y validaciones de integridad automatizables.
- Trazabilidad completa de cada activo migrado hacia su origen legado.

## Arquitectura

```
┌──────────────────────────────────────────────────────────────────────┐
│                        Docker Compose                                │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                   Esquema legado (legacy.*)                  │    │
│  │  municipios · nucleos · abastecimientos · saneamientos       │    │
│  │  equipamientos · v_resumen_municipal                         │    │
│  └───────────────────────────┬─────────────────────────────────┘    │
│                              │  migraciones                         │
│                              ▼                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │               Modelo normalizado (core.* / catalog.*)        │    │
│  │  municipality · population_center · asset_category           │    │
│  │  asset · asset_metric                                        │    │
│  └───────────┬─────────────────────────────────────────────────┘    │
│              │                           │                          │
│              ▼                           ▼                          │
│  ┌────────────────────────┐  ┌───────────────────────────────┐     │
│  │  Compatibilidad        │  │  Calidad (qa.*)               │     │
│  │  (compat.*)            │  │  v_data_quality_checks        │     │
│  │  v_abastecimientos     │  │  v_model_inventory            │     │
│  │  v_saneamientos        │  └───────────────────────────────┘     │
│  │  v_equipamientos       │                                        │
│  │  v_resumen_municipal   │                                        │
│  └────────────────────────┘                                        │
│                                                                      │
│               PostgreSQL/PostGIS :5433                               │
└──────────────────────────────────────────────────────────────────────┘
```

## Inicio Rápido

### Requisitos Previos

- [Docker Engine](https://docs.docker.com/engine/install/) 24+
- [Docker Compose](https://docs.docker.com/compose/install/) v2+
- 2 GB de RAM disponible
- Puerto `5433` libre (PostgreSQL)

### Despliegue

```bash
# 1. Clonar el repositorio
git clone https://github.com/Torcse-S-L/EIEL-Data-Model-Modernization-Lab.git
cd EIEL-Data-Model-Modernization-Lab

# 2. Copiar variables de entorno
cp .env.example .env

# 3. Levantar la base de datos
docker compose up -d

# 4. Aplicar el modelo objetivo y las vistas de compatibilidad
bash scripts/run_migrations.sh

# 5. Validar el resultado
bash tests/test_migration.sh
```

En Windows PowerShell:

```powershell
Copy-Item .env.example .env
./scripts/bootstrap_lab.ps1
./tests/test_migration.ps1
```

### Verificación

```bash
bash tests/test_migration.sh
```

## Esquemas

| Esquema | Función |
|---------|---------|
| `legacy.*` | Reproduce el estado actual para análisis y trazabilidad |
| `catalog.*` | Catálogo controlado de categorías funcionales |
| `core.*` | Modelo normalizado: municipio, núcleo, activo, métrica |
| `compat.*` | Vistas con la misma forma que el modelo legado |
| `qa.*` | Controles de calidad e inventario de entidades |

## Validaciones Incluidas

- Equivalencia de recuentos entre tablas legadas y vistas de compatibilidad.
- Comprobación de errores bloqueantes de calidad de datos.
- Presencia de índices espaciales en el modelo normalizado.
- Inventario de entidades para trazabilidad de la migración.

## Estructura del Proyecto

```
├── .github/workflows/ci.yml          # CI: validación automática
├── docker-compose.yml                # Entorno PostgreSQL/PostGIS
├── .env.example                      # Variables de entorno (template)
├── postgres/
│   ├── init/
│   │   ├── 01-extensions.sql         # PostGIS y extensiones
│   │   ├── 02-legacy-schema.sql      # Esquema legado de referencia
│   │   └── 03-legacy-sample-data.sql # Datos de ejemplo
│   └── migrations/
│       ├── 001_target_model.sql      # Modelo normalizado objetivo
│       ├── 002_compatibility_views.sql # Vistas de compatibilidad
│       └── 003_quality_checks.sql    # Controles de calidad
├── scripts/
│   ├── bootstrap_lab.sh / .ps1       # Inicialización del entorno
│   └── run_migrations.sh / .ps1      # Aplicación de migraciones
├── tests/
│   └── test_migration.sh / .ps1      # Suite de validación
└── docs/                             # Documentación técnica
```

## Documentación

- [Arquitectura](docs/arquitectura.md) — Capas, componentes y principios de diseño
- [Análisis del modelo actual](docs/analisis-modelo-actual.md) — Inventario legado y hallazgos
- [Modelo de datos objetivo](docs/modelo-datos.md) — Modelo lógico y físico normalizado
- [Diccionario de datos](docs/diccionario-datos.md) — Tablas, columnas y tipos
- [Migración y compatibilidad](docs/migracion-y-compatibilidad.md) — Proceso y vistas de transición
- [Operación y mantenimiento](docs/operacion-y-mantenimiento.md) — Guía operativa

## Puerto

| Servicio | Puerto |
|----------|--------|
| PostgreSQL/PostGIS | 5433 |

## Tecnologías

| Componente | Versión | Función |
|------------|---------|---------|
| PostgreSQL | 16 | Motor de base de datos relacional |
| PostGIS | 3.4 | Extensión de datos espaciales |
| Docker Compose | v2+ | Orquestación del entorno de laboratorio |

## Licencia

Este proyecto está licenciado bajo [Apache License 2.0](LICENSE).

---

Desarrollado por [Torcse S.L.](https://github.com/Torcse-S-L)
