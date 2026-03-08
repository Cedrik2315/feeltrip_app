#!/usr/bin/env powershell
param(
  [string]$ProjectId = "feeltrip-app",
  [string]$DatasetId = ""
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Get-FirebaseAccessToken {
  $cfgPath = Join-Path $env:USERPROFILE ".config\configstore\firebase-tools.json"
  if (!(Test-Path $cfgPath)) {
    throw "No se encontro firebase-tools.json. Ejecuta 'firebase login' primero."
  }
  $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
  if (-not $cfg.tokens.access_token) {
    throw "No hay access_token en firebase-tools.json."
  }
  return $cfg.tokens.access_token
}

function Refresh-FirebaseSession {
  firebase projects:list | Out-Null
}

function Invoke-BqApi {
  param(
    [string]$Method,
    [string]$Uri,
    [object]$Body,
    [string]$Token
  )
  $headers = @{ Authorization = "Bearer $Token" }
  try {
    if ($Body -eq $null) {
      return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers
    }
    return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers -Body ($Body | ConvertTo-Json -Depth 10) -ContentType "application/json"
  } catch {
    if ($_.Exception.Message -like "*(401)*") {
      Write-Host "Token expirado durante llamada BigQuery. Refrescando sesion..."
      Refresh-FirebaseSession
      $freshToken = Get-FirebaseAccessToken
      $freshHeaders = @{ Authorization = "Bearer $freshToken" }
      if ($Body -eq $null) {
        return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $freshHeaders
      }
      return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $freshHeaders -Body ($Body | ConvertTo-Json -Depth 10) -ContentType "application/json"
    }
    throw
  }
}

function Resolve-AnalyticsDataset {
  param(
    [string]$ProjectId,
    [string]$PreferredDataset,
    [string]$Token
  )

  if ($PreferredDataset) {
    return $PreferredDataset
  }

  $uri = "https://bigquery.googleapis.com/bigquery/v2/projects/$ProjectId/datasets"
  $resp = Invoke-BqApi -Method GET -Uri $uri -Body $null -Token $Token
  $ids = @()
  if ($resp.datasets) {
    $ids = $resp.datasets | ForEach-Object { $_.datasetReference.datasetId }
  }
  $analytics = $ids | Where-Object { $_ -like "analytics_*" } | Select-Object -First 1
  if (-not $analytics) {
    throw "No se encontro dataset analytics_* en '$ProjectId'. Activa export GA4 -> BigQuery en Firebase."
  }
  return $analytics
}

function Run-Query {
  param(
    [string]$ProjectId,
    [string]$Query,
    [string]$Token
  )
  $uri = "https://bigquery.googleapis.com/bigquery/v2/projects/$ProjectId/queries"
  $body = @{
    query = $Query
    useLegacySql = $false
  }
  $null = Invoke-BqApi -Method POST -Uri $uri -Body $body -Token $Token
}

$token = Get-FirebaseAccessToken
$dataset = Resolve-AnalyticsDataset -ProjectId $ProjectId -PreferredDataset $DatasetId -Token $token

Write-Host "Usando dataset: $dataset"

$q1 = @"
CREATE OR REPLACE VIEW `$ProjectId.$dataset.vw_release_funnel_daily` AS
WITH base AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS day,
    event_name,
    user_pseudo_id
  FROM `$ProjectId.$dataset.events_*`
  WHERE event_name IN ('search_executed', 'trip_opened', 'add_to_cart', 'checkout_completed')
)
SELECT
  day,
  COUNT(DISTINCT IF(event_name = 'search_executed', user_pseudo_id, NULL)) AS users_search,
  COUNT(DISTINCT IF(event_name = 'trip_opened', user_pseudo_id, NULL)) AS users_trip_opened,
  COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL)) AS users_add_to_cart,
  COUNT(DISTINCT IF(event_name = 'checkout_completed', user_pseudo_id, NULL)) AS users_checkout,
  SAFE_DIVIDE(COUNT(DISTINCT IF(event_name = 'trip_opened', user_pseudo_id, NULL)), COUNT(DISTINCT IF(event_name = 'search_executed', user_pseudo_id, NULL))) AS rate_search_to_trip,
  SAFE_DIVIDE(COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL)), COUNT(DISTINCT IF(event_name = 'trip_opened', user_pseudo_id, NULL))) AS rate_trip_to_cart,
  SAFE_DIVIDE(COUNT(DISTINCT IF(event_name = 'checkout_completed', user_pseudo_id, NULL)), COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL))) AS rate_cart_to_checkout
FROM base
GROUP BY day
"@

$q2 = @"
CREATE OR REPLACE VIEW `$ProjectId.$dataset.vw_release_auth_daily` AS
SELECT
  PARSE_DATE('%Y%m%d', event_date) AS day,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'state') AS auth_state,
  COUNT(*) AS events_count
FROM `$ProjectId.$dataset.events_*`
WHERE event_name = 'auth_gate_state'
GROUP BY day, auth_state
"@

$q3 = @"
CREATE OR REPLACE VIEW `$ProjectId.$dataset.vw_release_ai_daily` AS
WITH ai AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS day,
    event_name,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'duration_ms') AS duration_ms
  FROM `$ProjectId.$dataset.events_*`
  WHERE event_name IN ('ai_request_start', 'ai_request_success', 'ai_request_error')
)
SELECT
  day,
  COUNTIF(event_name = 'ai_request_start') AS ai_start,
  COUNTIF(event_name = 'ai_request_success') AS ai_success,
  COUNTIF(event_name = 'ai_request_error') AS ai_error,
  SAFE_DIVIDE(COUNTIF(event_name = 'ai_request_success'), COUNTIF(event_name = 'ai_request_start')) AS ai_success_rate,
  APPROX_QUANTILES(IF(event_name = 'ai_request_success', duration_ms, NULL), 100)[OFFSET(95)] AS ai_duration_p95_ms
FROM ai
GROUP BY day
"@

Run-Query -ProjectId $ProjectId -Query $q1 -Token $token
Run-Query -ProjectId $ProjectId -Query $q2 -Token $token
Run-Query -ProjectId $ProjectId -Query $q3 -Token $token

Write-Host "Vistas Dia 11 creadas correctamente:"
Write-Host "- $ProjectId.$dataset.vw_release_funnel_daily"
Write-Host "- $ProjectId.$dataset.vw_release_auth_daily"
Write-Host "- $ProjectId.$dataset.vw_release_ai_daily"
