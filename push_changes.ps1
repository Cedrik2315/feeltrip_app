# Script para actualizar repositorio GitHub - FeelTrip App
# Ejecutar con: .\push_changes.ps1
#
# Mejoras:
# - Pide un mensaje de commit dinámico.
# - Verifica si hay cambios antes de continuar.
# - Detecta la rama actual para el push.
# - Manejo de errores mejorado.
$projectPath = "$PSScriptRoot"
Set-Location $projectPath

Write-Host "🚀 Iniciando proceso de actualización en GitHub..." -ForegroundColor Cyan

# 1. Verificar si hay cambios para commitear
Write-Host "`n📊 Verificando estado del repositorio..." -ForegroundColor Gray
$gitStatus = git status --porcelain
if (-not $gitStatus) {
    Write-Host "`n✅ No hay cambios para subir. ¡Todo está al día!" -ForegroundColor Green
    Read-Host "`nPresiona Enter para salir..."
    exit
}

Write-Host "   Cambios detectados:"
git status -s

# 2. Añadir archivos al stage
Write-Host "`n📦 Añadiendo todos los archivos al stage..." -ForegroundColor Cyan
git add .

# 3. Pedir mensaje de Commit
$commitMessage = Read-Host "`n💬 Escribe el mensaje para el commit (ej: feat: agrega login)"
if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    Write-Host "`n❌ El mensaje de commit no puede estar vacío. Abortando." -ForegroundColor Red
    Read-Host "`nPresiona Enter para salir..."
    exit
}

# 4. Crear el Commit
Write-Host "`n💾 Creando commit..." -ForegroundColor Cyan
git commit -m "$commitMessage"
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Error al crear el commit." -ForegroundColor Red
    Read-Host "`nPresiona Enter para salir..."
    exit
}

# 5. Subir los cambios (Push)
try {
    $currentBranch = git rev-parse --abbrev-ref HEAD
    Write-Host "`n⬆️  Subiendo cambios a la rama '$currentBranch' en GitHub..." -ForegroundColor Cyan
    
    $pushOutput = git push origin $currentBranch 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ ¡ÉXITO! Los cambios se han subido correctamente a la rama '$currentBranch'." -ForegroundColor Green
    } else {
        Write-Host "`n❌ ERROR al subir los cambios:" -ForegroundColor Red
        Write-Host $pushOutput
        Write-Host "`n💡 Posible solución: Ejecuta 'git pull origin $currentBranch' para sincronizar cambios remotos."
    }
} catch {
    Write-Host "`n❌ Ocurrió un error inesperado durante el push:" -ForegroundColor Red
    Write-Host $_.Exception.Message
} finally {
    Read-Host "`nPresiona Enter para salir..."
}