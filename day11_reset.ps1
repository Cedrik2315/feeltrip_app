#!/usr/bin/env powershell
param(
  [string]$ProjectId = "feeltrip-app",
  [int]$WaitMinutes = 0
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "Refrescando sesion Firebase..."
firebase projects:list | Out-Null

function Get-Token {
  $cfgPath = Join-Path $env:USERPROFILE ".config\configstore\firebase-tools.json"
  if (!(Test-Path $cfgPath)) {
    throw "No se encontro firebase-tools.json. Ejecuta 'firebase login'."
  }
  $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
  return $cfg.tokens.access_token
}

function Get-Datasets {
  param([string]$ProjectId, [string]$Token)
  $headers = @{ Authorization = "Bearer $Token" }
  $uri = "https://bigquery.googleapis.com/bigquery/v2/projects/$ProjectId/datasets"
  $resp = Invoke-RestMethod -Method Get -Headers $headers -Uri $uri
  if (-not $resp.datasets) { return @() }
  return @($resp.datasets | ForEach-Object { $_.datasetReference.datasetId })
}

$token = Get-Token
$datasets = Get-Datasets -ProjectId $ProjectId -Token $token

if ($datasets.Count -eq 0) {
  Write-Host "No hay datasets en BigQuery para $ProjectId."
} else {
  Write-Host "Datasets actuales:"
  $datasets | ForEach-Object { Write-Host "- $_" }
}

$analytics = $datasets | Where-Object { $_ -like "analytics_*" } | Select-Object -First 1
if ($analytics) {
  Write-Host "Detectado dataset de Analytics: $analytics"
  powershell -ExecutionPolicy Bypass -File .\setup_day11_bigquery.ps1 -ProjectId $ProjectId -DatasetId $analytics
  exit $LASTEXITCODE
}

if ($WaitMinutes -gt 0) {
  Write-Host "No existe analytics_* aun. Iniciando espera activa..."
  powershell -ExecutionPolicy Bypass -File .\wait_and_setup_day11.ps1 -ProjectId $ProjectId -MaxMinutes $WaitMinutes -IntervalSeconds 60
  exit $LASTEXITCODE
}

Write-Host ""
Write-Host "DIA 11 bloqueado: falta dataset analytics_*."
Write-Host "Accion: en GA4 (propiedad de feeltrip-app) activa BigQuery Links con Daily + Streaming."
