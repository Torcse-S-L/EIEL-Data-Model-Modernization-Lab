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

query() {
    docker exec "$POSTGIS_CONTAINER" \
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "$1"
}

assert_equals() {
    local actual="$1"
    local expected="$2"
    local label="$3"

    if [ "$actual" = "$expected" ]; then
        echo "  [OK] $label = $actual"
    else
        echo "  [FAIL] $label (esperado: $expected, recibido: $actual)" >&2
        exit 1
    fi
}

assert_nonzero() {
    local actual="$1"
    local label="$2"

    if [ "$actual" -gt 0 ]; then
        echo "  [OK] $label = $actual"
    else
        echo "  [FAIL] $label debe ser mayor que 0" >&2
        exit 1
    fi
}

echo ""
echo "Validando migracion EIEL..."

legacy_assets="$(query "SELECT COUNT(*) FROM legacy.abastecimientos;")"
compat_assets="$(query "SELECT COUNT(*) FROM compat.v_abastecimientos_legacy;")"
assert_equals "$compat_assets" "$legacy_assets" "Compatibilidad abastecimientos"

legacy_san="$(query "SELECT COUNT(*) FROM legacy.saneamientos;")"
compat_san="$(query "SELECT COUNT(*) FROM compat.v_saneamientos_legacy;")"
assert_equals "$compat_san" "$legacy_san" "Compatibilidad saneamientos"

legacy_equip="$(query "SELECT COUNT(*) FROM legacy.equipamientos;")"
compat_equip="$(query "SELECT COUNT(*) FROM compat.v_equipamientos_legacy;")"
assert_equals "$compat_equip" "$legacy_equip" "Compatibilidad equipamientos"

normalized_assets="$(query "SELECT COUNT(*) FROM core.asset;")"
assert_nonzero "$normalized_assets" "Total activos normalizados"

errors="$(query "SELECT COUNT(*) FROM qa.v_data_quality_checks WHERE status = 'error' AND affected_rows > 0;")"
assert_equals "$errors" "0" "Errores de calidad bloqueantes"

gist_indexes="$(query "SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'core' AND indexdef ILIKE '%USING gist%';")"
assert_nonzero "$gist_indexes" "Indices espaciales en core"

echo ""
echo "Migracion validada correctamente."
