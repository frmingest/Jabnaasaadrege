# run-mapping.ps1 - READ ONLY. Runs custom\scripts\mapping\*.sql against the `mangos` database
# and writes one .tsv per file to custom\scripts\mapping\out\ (git-ignored).
# Uses the DB password from E:\vmangos-server\.dbpass via a temporary config file (deleted afterwards).
$ErrorActionPreference = 'Continue'
$enc = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $enc
$OutputEncoding = $enc

$dir = Join-Path $PSScriptRoot 'mapping'
$out = Join-Path $dir 'out'
New-Item -ItemType Directory -Force $out | Out-Null
Get-ChildItem $out -Filter '*.tsv' -ErrorAction SilentlyContinue | Remove-Item -Force

$client = 'C:\Program Files\MariaDB 13.0\bin\mariadb.exe'
if (-not (Test-Path $client)) { $client = 'C:\Program Files\MariaDB 13.0\bin\mysql.exe' }
if (-not (Test-Path $client)) { throw 'MariaDB client not found.' }

$pw = (Get-Content 'E:\vmangos-server\.dbpass' -Raw).Trim()
$cnf = Join-Path $env:TEMP ('mapping-' + [guid]::NewGuid().ToString('N') + '.cnf')
[IO.File]::WriteAllText($cnf, "[client]`nuser=mangos`npassword=$pw`nhost=127.0.0.1`n", (New-Object System.Text.UTF8Encoding($false)))

try {
  Get-ChildItem $dir -Filter '*.sql' | Sort-Object Name | ForEach-Object {
    Write-Host "Running $($_.Name) ..."
    $sql = [IO.File]::ReadAllText($_.FullName)
    $res = $sql | & $client "--defaults-extra-file=$cnf" --default-character-set=utf8mb4 --batch --force mangos 2>&1
    [IO.File]::WriteAllLines((Join-Path $out ($_.BaseName + '.tsv')), [string[]]$res, $enc)
  }
  Write-Host "Done. Results in $out"
} finally {
  Remove-Item $cnf -Force -ErrorAction SilentlyContinue
}
