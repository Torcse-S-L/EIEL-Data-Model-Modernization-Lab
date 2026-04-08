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

Get-ChildItem (Join-Path $root 'postgres\migrations\*.sql') | Sort-Object Name | ForEach-Object {
    Write-Host "Aplicando $($_.Name)"
    docker exec $container psql -U $postgresUser -d $postgresDb -v ON_ERROR_STOP=1 -f "/workspace/migrations/$($_.Name)"
}
