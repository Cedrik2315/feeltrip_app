# Script de corrección automática
$filesToDelete = @(
    "lib\services\smart_travel_controller.dart",
    "lib\config\firebase_options.dart",
    "lib\packages_section.dart",
    "lib\models\packages_section.dart",
    "lib\screens\packages_section.dart",
    "lib\config\notification_model.dart",
    "lib\controllers\smart_results_screen.dart",
    "lib\scripts\traveler_story_model.dart",
    "lib\screens\notification_tile.dart",
    "lib\scripts\stories_screen.dart",
    "lib\screens\affiliate_service.dart"
)

foreach ($file in $filesToDelete) {
    $fullPath = Join-Path $PSScriptRoot $file
    if (Test-Path $fullPath) {
        Remove-Item $fullPath -Force
        Write-Host "Eliminado: $file" -ForegroundColor Red
    }
}

Write-Host "Limpieza finalizada." -ForegroundColor Green