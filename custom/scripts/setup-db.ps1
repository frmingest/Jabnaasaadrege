# Creates the four vMaNGOS databases and a dedicated 'mangos' DB user on a local MariaDB,
# imports the latest published database snapshot, registers a realm, and writes mangosd.conf / realmd.conf.
# Run:  powershell -ExecutionPolicy Bypass -File .\custom\scripts\setup-db.ps1
# You will be asked for the MariaDB root password; it is only kept in memory for this run.
param(
  [string]$Server    = 'E:\vmangos-server',
  [string]$RealmName = 'My vMaNGOS Realm',
  [string]$RealmAddr = '127.0.0.1',   # change to your public IP / hostname before friends connect
  [switch]$ForceImport
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# --- locate the MariaDB client -------------------------------------------------
$maria = (Get-Command mariadb.exe -ErrorAction SilentlyContinue).Source
if (-not $maria) { $maria = (Get-Command mysql.exe -ErrorAction SilentlyContinue).Source }
if (-not $maria) {
  $maria = Get-ChildItem "${env:ProgramFiles}\MariaDB*\bin\mariadb.exe", "${env:ProgramFiles(x86)}\MariaDB*\bin\mariadb.exe" -ErrorAction SilentlyContinue |
           Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $maria) { throw 'MariaDB client not found. Find it with: Get-ChildItem C:\ -Filter mariadb.exe -Recurse -ErrorAction SilentlyContinue | Select -First 3 FullName' }
Write-Host "Using client: $maria"

$svc = Get-Service | Where-Object { $_.Name -match 'maria|mysql' } | Select-Object -First 1
if ($svc -and $svc.Status -ne 'Running') { Write-Host "Starting service $($svc.Name)..."; Start-Service $svc.Name }

# --- root login ----------------------------------------------------------------
$sec  = Read-Host 'MariaDB root password (just press Enter if root has no password)' -AsSecureString
$root = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
$env:MYSQL_PWD = $root
function Sql([string]$text) {
  $text | & $maria -uroot --batch --skip-column-names
  if ($LASTEXITCODE) { throw "SQL failed: $text" }
}
function SqlFile([string]$db, [string]$file) {
  cmd /c "`"$maria`" -uroot --max-allowed-packet=256M $db < `"$file`""
  if ($LASTEXITCODE) { throw "Import of $file into $db failed" }
}
try {
  Write-Host ("Connected. Server version: " + (& $maria -uroot --batch --skip-column-names -e 'SELECT VERSION()'))
  if ($LASTEXITCODE) { throw 'Could not log in as root (wrong password?).' }
  if ($root -eq '') {
    Write-Warning 'MariaDB root has no password. Fine for local setup, but do not expose port 3306 to the internet; we will set one later.'
  }

  # --- dedicated user with a random password (kept in $Server\.dbpass) -----------
  $passFile = Join-Path $Server '.dbpass'
  if (Test-Path $passFile) { $dbpass = (Get-Content $passFile -Raw).Trim() }
  else {
    $b = New-Object byte[] 16; [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b)
    $dbpass = -join ($b | ForEach-Object { $_.ToString('x2') })
    Set-Content $passFile $dbpass -NoNewline
  }
  foreach ($db in 'realmd','mangos','characters','logs') {
    Sql "CREATE DATABASE IF NOT EXISTS ``$db`` DEFAULT CHARSET utf8 COLLATE utf8_general_ci;"
  }
  foreach ($h in 'localhost','127.0.0.1') {
    Sql "CREATE USER IF NOT EXISTS 'mangos'@'$h' IDENTIFIED BY '$dbpass'; ALTER USER 'mangos'@'$h' IDENTIFIED BY '$dbpass';"
    foreach ($db in 'realmd','mangos','characters','logs') { Sql "GRANT ALL PRIVILEGES ON ``$db``.* TO 'mangos'@'$h';" }
  }
  Sql 'FLUSH PRIVILEGES;'

  # --- snapshot download + import --------------------------------------------------
  $tables = [int](& $maria -uroot --batch --skip-column-names -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='mangos'")
  if ($tables -gt 50 -and -not $ForceImport) {
    Write-Host "World database already has $tables tables; skipping import (use -ForceImport to redo)."
  } else {
    $work = Join-Path $env:TEMP 'vmangos-db'
    Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory $work | Out-Null
    Write-Host 'Looking up the latest database snapshot...'
    $rel = Invoke-RestMethod 'https://api.github.com/repos/vmangos/core/releases/tags/db_latest' -Headers @{ 'User-Agent' = 'vmangos-setup' }
    $asset = $rel.assets | Where-Object { $_.name -match '^db-.*\.zip$' } | Select-Object -First 1
    if (-not $asset) { throw 'No db-*.zip asset found on the db_latest release.' }
    Write-Host ("Downloading {0} ({1:N0} MB)..." -f $asset.name, ($asset.size / 1MB))
    $zip = Join-Path $work $asset.name
    Invoke-WebRequest $asset.browser_download_url -OutFile $zip
    Expand-Archive $zip -DestinationPath $work -Force
    $map = @{ 'logon.sql'='realmd'; 'characters.sql'='characters'; 'mangos.sql'='mangos'; 'logs.sql'='logs' }
    foreach ($f in $map.Keys) {
      $p = Get-ChildItem $work -Recurse -Filter $f | Select-Object -First 1
      if (-not $p) { throw "Snapshot is missing $f" }
      Write-Host "Importing $f into $($map[$f])..."
      SqlFile $map[$f] $p.FullName
    }
    Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
  }

  # --- realm entry -------------------------------------------------------------------
  Sql "REPLACE INTO realmd.realmlist (id,name,address,port,icon,realmflags,timezone,allowedSecurityLevel,population,gamebuild_min,gamebuild_max,flag) VALUES (1,'$RealmName','$RealmAddr',8085,1,0,1,0,0,5875,5875,0);"
}
finally { Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue }

# --- config files -----------------------------------------------------------------------
$data = ($Server -replace '\\','/') + '/data'
$logs = ($Server -replace '\\','/') + '/logs'
New-Item -ItemType Directory -Force (Join-Path $Server 'logs') | Out-Null
$utf8 = New-Object Text.UTF8Encoding $false
function Conf($name, [hashtable]$rules) {
  $dist = Join-Path $Server "$name.dist"; $conf = Join-Path $Server $name
  if (-not (Test-Path $dist)) { throw "Missing $dist" }
  $t = Get-Content $dist -Raw
  foreach ($k in $rules.Keys) {
    $new = '$1' + $rules[$k]
    if ($t -notmatch "(?m)^$k\s*=") { throw "Key $k not found in $name.dist" }
    $t = [regex]::Replace($t, "(?m)^($k\s*=\s*).*$", { param($m) $m.Groups[1].Value + $rules[$k] }.GetNewClosure())
  }
  [IO.File]::WriteAllText($conf, $t, $utf8)
  Write-Host "Wrote $conf"
}
$info = { param($db) '"127.0.0.1;3306;mangos;' + $dbpass + ';' + $db + '"' }
Conf 'mangosd.conf' @{
  'DataDir'                 = "`"$data`""
  'LogsDir'                 = "`"$logs`""
  'LoginDatabase.Info'      = (& $info 'realmd')
  'WorldDatabase.Info'      = (& $info 'mangos')
  'CharacterDatabase.Info'  = (& $info 'characters')
  'LogsDatabase.Info'       = (& $info 'logs')
}
Conf 'realmd.conf' @{
  'LogsDir'                 = "`"$logs`""
  'LoginDatabaseInfo'       = (& $info 'realmd')
}
Write-Host "`nDone. Databases are set up and configs are written. The 'mangos' DB password is stored in $passFile" -ForegroundColor Green
