# Extracts DBC, maps, vmaps and mmaps from a 1.12.1 (5875) client into the server's data folder.
# The client folder is only read, never modified.
# Each step writes a ".done-<step>" marker when it FINISHES. A step without a marker is redone from scratch,
# so an interrupted run (closed window, Ctrl+C, crash) is safe to simply start again.
# Run:  powershell -ExecutionPolicy Bypass -File .\custom\scripts\extract-data.ps1
param(
  [string]$Client = 'E:\Wow Classic 1.12.1',
  [string]$Server = 'E:\vmangos-server'
)
$ErrorActionPreference = 'Stop'

$tools = Join-Path $Server 'Extractors'
$data  = Join-Path $Server 'data'
foreach ($p in @("$Client\WoW.exe", "$Client\Data", "$tools\MapExtractor.exe", "$tools\VMapExtractor.exe", "$tools\VMapAssembler.exe", "$tools\MoveMapGenerator.exe")) {
  if (-not (Test-Path $p)) { throw "Missing: $p" }
}
New-Item -ItemType Directory -Force $data | Out-Null

function IsDone($n)   { Test-Path (Join-Path $data ".done-$n") }
function MarkDone($n) { Set-Content (Join-Path $data ".done-$n") (Get-Date -Format s) }
function Step($name, [scriptblock]$cmd) {
  Write-Host "`n=== $name ($(Get-Date -Format HH:mm:ss)) ===" -ForegroundColor Cyan
  & $cmd
  if ($LASTEXITCODE) { throw "$name failed with exit code $LASTEXITCODE" }
}

Push-Location $data
try {
  # 1. DBC + maps (+ cameras). -e 7 = everything. The core expects DBCs under data\5875\dbc
  if (-not (IsDone 'maps')) {
    Remove-Item "$data\maps", "$data\dbc", "$data\Cameras" -Recurse -Force -ErrorAction SilentlyContinue
    Step 'MapExtractor (DBC + maps)' { & "$tools\MapExtractor.exe" -i $Client -o $data -e 7 --silent }
    New-Item -ItemType Directory -Force "$data\5875" | Out-Null
    Remove-Item "$data\5875\dbc" -Recurse -Force -ErrorAction SilentlyContinue
    Move-Item "$data\dbc" "$data\5875\dbc"
    MarkDone 'maps'
  } else { Write-Host 'maps + dbc: already done.' }

  # 2. Raw vmap data (writes .\Buildings), then assemble into .\vmaps
  if (-not (IsDone 'vmaps')) {
    Remove-Item "$data\Buildings", "$data\vmaps" -Recurse -Force -ErrorAction SilentlyContinue
    Step 'VMapExtractor' { & "$tools\VMapExtractor.exe" -d "$Client\Data" --silent }
    Step 'VMapAssembler' { & "$tools\VMapAssembler.exe" --silent }
    Remove-Item "$data\Buildings" -Recurse -Force -ErrorAction SilentlyContinue
    MarkDone 'vmaps'
  } else { Write-Host 'vmaps: already done.' }

  # 3. Movement maps. SLOW (can take an hour or more) and cannot resume, so do not close this window.
  #    Reads .\maps and .\vmaps, writes .\mmaps
  if (-not (IsDone 'mmaps')) {
    Remove-Item "$data\mmaps" -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force "$data\mmaps" | Out-Null
    $threads = [Environment]::ProcessorCount
    Step "MoveMapGenerator ($threads threads) - please leave this window open" {
      & "$tools\MoveMapGenerator.exe" --threads $threads --silent --configInputPath "$tools\config.json" --offMeshInput "$tools\offmesh.txt"
    }
    MarkDone 'mmaps'
  } else { Write-Host 'mmaps: already done.' }

  Remove-Item "$data\Cameras" -Recurse -Force -ErrorAction SilentlyContinue
  Write-Host "`nAll extraction steps finished. Data is in $data" -ForegroundColor Green
}
finally { Pop-Location }
