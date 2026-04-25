# Operacion y Mantenimiento

## Arranque del entorno

### Linux / macOS

```bash
cp .env.example .env
bash scripts/bootstrap_lab.sh
```

### Windows PowerShell

```powershell
Copy-Item .env.example .env
./scripts/bootstrap_lab.ps1
```

## Comandos de uso frecuente

| Tarea | Comando |
|------|---------|
| Levantar entorno | `docker compose up -d` |
| Aplicar migraciones | `bash scripts/run_migrations.sh` |
| Validar laboratorio | `bash tests/test_migration.sh` |
| Consultar calidad | `SELECT * FROM qa.v_data_quality_checks;` |
| Ver inventario | `SELECT * FROM qa.v_model_inventory;` |

## Tareas de mantenimiento recomendadas

- revisar periodicamente el inventario de categorias y metricas;
- mantener documentado el mapeo entre dominios legacy y categorias normalizadas;
- ampliar `qa.v_data_quality_checks` conforme aparezcan nuevas reglas de negocio;
- incorporar al pipeline consultas reales de SITMAP/QGIS cuando se disponga de ellas.

## Evoluciones previstas

- importar el esquema real EIEL de produccion para benchmarking;
- crear procedimientos SQL de refresco incremental;
- incorporar exportaciones hacia geodatabase ministerial;
- añadir pruebas de rendimiento con `EXPLAIN ANALYZE` sobre consultas reales.
