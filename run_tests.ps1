#!/usr/bin/env powershell
# AUTOMATED TESTING FLOW - For Windows
# Run: .\run_tests.ps1

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     FEELTRIP - AUTOMATED FEATURE TESTING FLOW          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Navigate to project
Write-Host "Step 1️⃣  Preparing project..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Set-Location $PSScriptRoot

Write-Host "  → Cleaning build files..." -ForegroundColor Gray
flutter clean

Write-Host "  → Fetching dependencies..." -ForegroundColor Gray
flutter pub get

Write-Host "✅ Project prepared" -ForegroundColor Green
Write-Host ""

# Step 2: Build
Write-Host "Step 2️⃣  Building APK..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
flutter build apk --debug
Write-Host "✅ APK built successfully" -ForegroundColor Green
Write-Host ""

# Step 3: Check device
Write-Host "Step 3️⃣  Checking connected devices..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
$devices = flutter devices
Write-Host $devices -ForegroundColor Gray
Write-Host ""

# Step 4: Run
Write-Host "Step 4️⃣  Running app on emulator..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "App launching in 3 seconds..." -ForegroundColor Gray
Write-Host "Available commands:" -ForegroundColor Gray
Write-Host "  r = Hot reload" -ForegroundColor Gray
Write-Host "  R = Hot restart" -ForegroundColor Gray
Write-Host "  h = Help" -ForegroundColor Gray
Write-Host "  q = Quit" -ForegroundColor Gray
Write-Host ""
Start-Sleep -Seconds 3

flutter run

# Step 5: Summary
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              APP RUNNING ON EMULATOR!                  ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Open MANUAL_TESTING.md in your editor" -ForegroundColor Gray
Write-Host "2. Follow the step-by-step testing guide" -ForegroundColor Gray
Write-Host "3. Create test data in Firebase Console" -ForegroundColor Gray
Write-Host "4. Test each feature as described" -ForegroundColor Gray
Write-Host ""
Write-Host "Timeline: ~20-30 minutes for complete testing" -ForegroundColor Yellow
Write-Host ""
