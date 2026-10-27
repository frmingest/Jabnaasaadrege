# apply-sql.ps1 - backs up the `mangos` database, then applies one SQL file to it.
# Uses the DB user `mangos` (password from E:\vmangos-server\.dbpass via a temporary config file, deleted afterwards).
# Usage: powershell -ExecutionPolicy Bypass -File .\custom\scripts\apply-sql.ps1 -File .\custom\jaersk\staging\0001_jaersk_pilot.sql
# Rollback: run the matching *.rollback.sql the same way (backup is taken again; use -SkipBackup to skip).
param(
  [Parameter(Mandatory = $true)][string]$File,
  [switch]$SkipBackup
)
$ErrorActionPreference = 'Continue'
$enc = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $enc
$OutputEncoding = $enc

if (-not (Test-Path $File)) { throw "File not found: $File" }
$File = (Resolve-Path $File).Path
$bin = (Get-Item 'C:\Program Files\MariaDB*\bin' | Select-Object -First 1).FullName
$client = Join-Path $bin 'mariadb.exe'
$dump = Join-Path $bin 'mariadb-dump.exe'
if (-not (Test-Path $client)) { throw 'mariadb.exe not found.' }

$pw = (Get-Content 'E:\vmangos-server\.dbpass' -Raw).Trim()
$cnf = Join-Path $env:TEMP ('apply-' + [guid]::NewGuid().ToString('N') + '.cnf')
[IO.File]::WriteAllText($cnf, "[client]`nuser=mangos`npassword=$pw`nhost=127.0.0.1`n", $enc)

try {
  if (-not $SkipBackup) {
    $dir = Join-Path 'E:\vmangos-backups' (Get-Date -Format 'yyyyMMdd-HHmmss')
    New-Item -ItemType Directory -Force $dir | Out-Null
    $bak = Join-Path $dir 'mangos.sql'
    & $dump "--defaults-extra-file=$cnf" --single-transaction --default-character-set=utf8mb4 mangos "--result-file=$bak"
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $bak) -or (Get-Item $bak).Length -lt 1MB) {
      throw 'Backup failed or looks too small. Nothing was applied.'
    }
    Write-Host ("Backup OK: {0} ({1:N0} MB)" -f $bak, ((Get-Item $bak).Length / 1MB))
  }
  Write-Host "Applying $File ..."
  $sql = [IO.File]::ReadAllText($File, $enc)
  $res = $sql | & $client "--defaults-extra-file=$cnf" --default-character-set=utf8mb4 mangos 2>&1
  if ($LASTEXITCODE -ne 0) { Write-Host ($res | Out-String); throw 'SQL failed. The transaction was not committed.' }
  Write-Host 'Applied OK.'
} finally {
  Remove-Item $cnf -Force -ErrorAction SilentlyContinue
}
