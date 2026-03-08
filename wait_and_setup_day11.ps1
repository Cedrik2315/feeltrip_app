#!/usr/bin/env powershell
param(
  [string]$ProjectId = "feeltrip-app",
  [int]$MaxMinutes = 60,
  [int]$IntervalSeconds = 60
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Get-FirebaseAccessToken {
  $cfgPath = Join-Path $env:USERPROFILE ".config\configstore\firebase-tools.json"
  if (!(Test-Path $cfgPath)) { throw "No se encontro firebase-tools.json." }
  $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
  if (-not $cfg.tokens.access_token) { throw "No hay access_token disponible." }
  return $cfg.tokens.access_token
}

function Refresh-FirebaseSession {
  firebase projects:list | Out-Null
}

function Get-Datasets {
  param([string]$ProjectId)
  $uri = "https://bigquery.googleapis.com/bigquery/v2/projects/$ProjectId/datasets"
  try {
    $token = Get-FirebaseAccessToken
    $headers = @{ Authorization = "Bearer $token" }
    $resp = Invoke-RestMethod -Method Get -Headers $headers -Uri $uri
  } catch {
    if ($_.Exception.Message -like "*(401)*") {
      Write-Host "Token expirado. Refrescando sesion Firebase..."
      Refresh-FirebaseSession
      try {
        $token = Get-FirebaseAccessToken
        $headers = @{ Authorization = "Bearer $token" }
        $resp = Invoke-RestMethod -Method Get -Headers $headers -Uri $uri
      } catch {
        Write-Host "Aviso: fallo tras refresh de token ($($_.Exception.Message))"
        return @()
      }
    } else {
      Write-Host "Aviso: fallo temporal consultando BigQuery API ($($_.Exception.Message))"
      return @()
    }
  }
  if (-not $resp.datasets) { return @() }
  return @($resp.datasets | ForEach-Object { $_.datasetReference.datasetId })
}

$maxAttempts = [Math]::Ceiling(($MaxMinutes * 60) / $IntervalSeconds)

for ($i = 1; $i -le $maxAttempts; $i++) {
  $datasets = Get-Datasets -ProjectId $ProjectId
  $analytics = $datasets | Where-Object { $_ -like "analytics_*" } | Select-Object -First 1
  if ($analytics) {
    Write-Host "Dataset detectado: $analytics"
    powershell -ExecutionPolicy Bypass -File .\setup_day11_bigquery.ps1 -ProjectId $ProjectId -DatasetId $analytics
    exit $LASTEXITCODE
  }
  Write-Host "[$i/$maxAttempts] Aun no existe analytics_*. Reintentando en $IntervalSeconds s..."
  Start-Sleep -Seconds $IntervalSeconds
}

throw "Timeout: no aparecio dataset analytics_* en $MaxMinutes minutos."
