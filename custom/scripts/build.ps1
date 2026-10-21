# Configures, builds and installs vMaNGOS (Release, x64) outside the repo tree.
# Run from any PowerShell window:  powershell -ExecutionPolicy Bypass -File .\custom\scripts\build.ps1
$ErrorActionPreference = 'Stop'

$src     = (Resolve-Path "$PSScriptRoot\..\..").Path
$build   = 'E:\vmangos-build'
$install = 'E:\vmangos-server'

# Visual Studio with the C++ x64 tools
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere)) { throw 'Visual Studio Installer not found - install the VS 2022 Build Tools (C++ workload) first.' }
$vs = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $vs) { throw 'No Visual Studio install with the C++ x64 tools was found.' }
Write-Host "Using Visual Studio at: $vs"

# CMake: PATH first, then common install folders, then the copy bundled with Visual Studio
if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
  $candidates = @(
    'C:\Program Files\CMake\bin',
    "${env:ProgramFiles(x86)}\CMake\bin",
    "$env:LOCALAPPDATA\Programs\CMake\bin",
    "$vs\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin"
  )
  foreach ($dir in $candidates) {
    if (Test-Path "$dir\cmake.exe") { $env:Path = "$dir;$env:Path"; break }
  }
}
if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
  throw 'CMake not found anywhere. Run: Get-ChildItem C:\ -Filter cmake.exe -Recurse -ErrorAction SilentlyContinue | Select -First 3 FullName'
}
Write-Host "Using CMake: $((Get-Command cmake).Source)"

# A leftover cache from an earlier run that passed -DPREFIX breaks compiler detection; start clean.
# (Do not pass -DPREFIX: it leaks into CMake's compiler-id macros. CMAKE_INSTALL_PREFIX is enough.)
if ((Test-Path "$build\CMakeCache.txt") -and (Select-String -Path "$build\CMakeCache.txt" -Pattern '^PREFIX:' -Quiet)) {
  Remove-Item $build -Recurse -Force
}

# SUPPORTED_CLIENT_BUILD already defaults to CLIENT_BUILD_1_12_1 (build 5875).
cmake -S $src -B $build -G 'Visual Studio 17 2022' -A x64 `
  -DBUILD_EXTRACTORS=ON `
  -DCMAKE_INSTALL_PREFIX="$install"
if ($LASTEXITCODE) { throw 'CMake configure failed.' }

cmake --build $build --config Release --parallel
if ($LASTEXITCODE) { throw 'Build failed.' }

cmake --build $build --config Release --target INSTALL
if ($LASTEXITCODE) { throw 'Install step failed.' }

Write-Host "Done. Binaries are in $install"
