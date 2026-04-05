#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -f "$ROOT_DIR/.env" ]; then
    set -a
    . "$ROOT_DIR/.env"
    set +a
fi

POSTGRES_USER="${POSTGRES_USER:-eiel_admin}"
POSTGRES_DB="${POSTGRES_DB:-eiel_lab}"
POSTGIS_CONTAINER="${POSTGIS_CONTAINER:-eiel-postgis}"

if ! docker ps --format '{{.Names}}' | grep -q "^${POSTGIS_CONTAINER}$"; then
    echo "El contenedor ${POSTGIS_CONTAINER} no esta en ejecucion." >&2
    exit 1
fi

for migration in "$ROOT_DIR"/postgres/migrations/*.sql; do
    echo "Aplicando $(basename "$migration")"
    docker exec "$POSTGIS_CONTAINER" \
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 -f "/workspace/migrations/$(basename "$migration")"
done
