$ErrorActionPreference = 'Stop'

$root = Split-Path -Path $PSScriptRoot -Parent
Set-Location $root

docker compose up -d
& "$root\scripts\run_migrations.ps1"
