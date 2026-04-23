# Migracion y Compatibilidad

## Estrategia propuesta

La transicion se articula en cinco pasos:

1. **Congelacion del inventario legado** para establecer una linea base auditable.
2. **Carga del modelo objetivo** con catalogos, entidades territoriales y activos consolidados.
3. **Publicacion de vistas de compatibilidad** para mantener operativas las consultas existentes.
4. **Validacion de equivalencia funcional** mediante recuentos, QA e inspeccion de geometrías.
5. **Sustitucion progresiva del acceso directo a tablas legacy** por consumo del modelo normalizado o sus vistas.

## Mapeo principal

| Origen legacy | Destino objetivo | Observaciones |
|--------------|------------------|---------------|
| `legacy.municipios` | `core.municipality` | Se consolidan nombre, provincia, comarca y geometria |
| `legacy.nucleos` | `core.population_center` | Se fija clave unica por municipio + nombre |
| `legacy.abastecimientos` | `core.asset` + `core.asset_metric` | `caudal_l_s` pasa a metrica |
| `legacy.saneamientos` | `core.asset` + `core.asset_metric` | `poblacion_servida` pasa a metrica |
| `legacy.equipamientos` | `core.asset` + `core.asset_metric` | `capacidad` pasa a metrica y `subtipo` a categoria controlada |

## Garantias de compatibilidad

- Las vistas `compat.*` exponen columnas compatibles con el esquema legado.
- El origen de cada fila puede rastrearse por `legacy_source_table` y `legacy_source_id`.
- Los recuentos entre tablas legacy y vistas de compatibilidad se validan automaticamente.

## Criterios de corte

La sustitucion de accesos directos al modelo anterior solo deberia realizarse cuando:

- los recuentos de compatibilidad sean equivalentes;
- no existan errores bloqueantes en `qa.v_data_quality_checks`;
- se hayan revisado consultas criticas de SITMAP y del plugin EIEL.

## Procedimiento operativo

```text
docker compose up -d
run_migrations
test_migration
revisar qa.v_data_quality_checks
habilitar compat.* para consumidores
```
