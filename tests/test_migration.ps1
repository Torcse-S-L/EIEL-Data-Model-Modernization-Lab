$ErrorActionPreference = 'Stop'

$root = Split-Path -Path $PSScriptRoot -Parent
Set-Location $root

$envFile = Join-Path $root '.env'
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^(?<key>[^#=]+)=(?<value>.*)$') {
            [System.Environment]::SetEnvironmentVariable($Matches.key, $Matches.value)
        }
    }
}

$postgresUser = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { 'eiel_admin' }
$postgresDb = if ($env:POSTGRES_DB) { $env:POSTGRES_DB } else { 'eiel_lab' }
$container = if ($env:POSTGIS_CONTAINER) { $env:POSTGIS_CONTAINER } else { 'eiel-postgis' }

function Invoke-DbQuery([string]$sql) {
    $raw = docker exec $container psql -U $postgresUser -d $postgresDb -tAc $sql | Out-String
    ($raw -replace 'failed to get console mode for stdout: The handle is invalid\.\s*', '').Trim()
}

function Assert-Equal([string]$actual, [string]$expected, [string]$label) {
    if ($actual -eq $expected) {
        Write-Host "[OK] $label = $actual"
    }
    else {
        throw "$label esperado $expected y recibido $actual"
    }
}

function Assert-Positive([int]$actual, [string]$label) {
    if ($actual -gt 0) {
        Write-Host "[OK] $label = $actual"
    }
    else {
        throw "$label debe ser mayor que 0"
    }
}

$legacyAb = (Invoke-DbQuery "SELECT COUNT(*) FROM legacy.abastecimientos;").Trim()
$compatAb = (Invoke-DbQuery "SELECT COUNT(*) FROM compat.v_abastecimientos_legacy;").Trim()
Assert-Equal $compatAb $legacyAb 'Compatibilidad abastecimientos'

$legacySa = (Invoke-DbQuery "SELECT COUNT(*) FROM legacy.saneamientos;").Trim()
$compatSa = (Invoke-DbQuery "SELECT COUNT(*) FROM compat.v_saneamientos_legacy;").Trim()
Assert-Equal $compatSa $legacySa 'Compatibilidad saneamientos'

$legacyEq = (Invoke-DbQuery "SELECT COUNT(*) FROM legacy.equipamientos;").Trim()
$compatEq = (Invoke-DbQuery "SELECT COUNT(*) FROM compat.v_equipamientos_legacy;").Trim()
Assert-Equal $compatEq $legacyEq 'Compatibilidad equipamientos'

$qualityErrors = (Invoke-DbQuery "SELECT COUNT(*) FROM qa.v_data_quality_checks WHERE status = 'error' AND affected_rows > 0;").Trim()
Assert-Equal $qualityErrors '0' 'Errores de calidad bloqueantes'

$gistIndexes = [int](Invoke-DbQuery "SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'core' AND indexdef ILIKE '%USING gist%';").Trim()
Assert-Positive $gistIndexes 'Indices espaciales en core'
