#!/usr/bin/env powershell
$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

function Invoke-Step {
  param([string]$Command)
  Invoke-Expression $Command
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed with exit code ${LASTEXITCODE}: $Command"
  }
}

Write-Host "[1/5] flutter pub get"
Invoke-Step "flutter pub get"

Write-Host "[2/5] flutter analyze"
Invoke-Step "flutter analyze"

Write-Host "[3/5] flutter test (release suite, staging env)"
Invoke-Step "flutter test test/services test/unit/admob_service_test.dart test/unit/auth_controller_test.dart test/unit/auth_service_test.dart test/unit/database_service_test.dart test/unit/diary_controller_test.dart test/unit/experience_controller_test.dart test/widget_test.dart --dart-define=APP_ENV=staging"

Write-Host "[4/5] build staging debug apk"
Invoke-Step "flutter build apk --debug --dart-define=APP_ENV=staging"

Write-Host "[5/5] build prod debug apk"
Invoke-Step "flutter build apk --debug --dart-define=APP_ENV=prod"

Write-Host "Preflight release OK"
