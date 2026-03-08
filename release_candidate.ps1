#!/usr/bin/env powershell
param(
  [Parameter(Mandatory = $true)]
  [string]$VersionName,
  [Parameter(Mandatory = $true)]
  [int]$BuildNumber
)

$ErrorActionPreference = "Stop"

if ($VersionName -notmatch '^\d+\.\d+\.\d+$') {
  throw "VersionName invalido. Usa formato semver: X.Y.Z"
}
if ($BuildNumber -lt 1) {
  throw "BuildNumber invalido. Debe ser >= 1."
}

Set-Location $PSScriptRoot

function Invoke-Step {
  param([string]$Command)
  Invoke-Expression $Command
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed with exit code ${LASTEXITCODE}: $Command"
  }
}

$keyProps = Join-Path $PSScriptRoot "android/key.properties"
if (!(Test-Path $keyProps)) {
  throw "Falta android/key.properties. Copia android/key.properties.example y completa tus valores."
}

$keyPropsContent = Get-Content $keyProps
$storeFileLine = $keyPropsContent | Where-Object { $_ -like "storeFile=*" } | Select-Object -First 1
if (-not $storeFileLine) {
  throw "android/key.properties no define storeFile."
}
$storeFilePath = $storeFileLine.Substring("storeFile=".Length)
if (!(Test-Path $storeFilePath)) {
  throw "No existe keystore en storeFile: $storeFilePath"
}

$pubspecPath = Join-Path $PSScriptRoot "pubspec.yaml"
$pubspec = Get-Content $pubspecPath -Raw
$newVersion = "$VersionName+$BuildNumber"
$updated = [regex]::Replace($pubspec, '(?m)^version:\s*.+$', "version: $newVersion")
if ($updated -eq $pubspec) {
  throw "No se pudo actualizar la linea version en pubspec.yaml"
}
Set-Content $pubspecPath $updated

Write-Host "Version seteada: $newVersion"

Invoke-Step "powershell -ExecutionPolicy Bypass -File .\preflight_release.ps1"
Invoke-Step "flutter build appbundle --release --dart-define=APP_ENV=prod --dart-define=APP_VERSION=$newVersion"

Write-Host "Release candidate generado:"
Write-Host "  version: $newVersion"
Write-Host "  artifact: build\app\outputs\bundle\release\app-release.aab"
