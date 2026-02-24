# Configuración de la ruta (ajusta si es necesario)
$projectPath = "$PSScriptRoot\lib"

Write-Host "Iniciando analisis de limpieza en: $projectPath" -ForegroundColor Cyan

if (-not (Test-Path $projectPath)) {
    Write-Error "No se encuentra la carpeta lib en $projectPath"
    exit
}

# Obtener todos los archivos .dart
$files = Get-ChildItem -Path $projectPath -Recurse -Filter "*.dart" -File

# 1. Buscar archivos duplicados por contenido (Hash MD5)
Write-Host "`n[1] Buscando archivos identicos (contenido duplicado)..." -ForegroundColor Yellow
$hashes = $files | ForEach-Object {
    $hash = Get-FileHash -Path $_.FullName -Algorithm MD5
    [PSCustomObject]@{
        Path = $_.FullName
        Name = $_.Name
        Hash = $hash.Hash
    }
}

$duplicates = $hashes | Group-Object Hash | Where-Object { $_.Count -gt 1 }

if ($duplicates) {
    foreach ($group in $duplicates) {
        Write-Host "`n[!] CONTENIDO IDENTICO ENCONTRADO:" -ForegroundColor Red
        foreach ($file in $group.Group) {
            # Mostrar ruta relativa para facilitar lectura
            $relativePath = $file.Path.Replace($PSScriptRoot, "")
            Write-Host "   - $relativePath"
        }
    }
} else {
    Write-Host "[OK] No se encontraron archivos con contenido identico." -ForegroundColor Green
}

# 2. Buscar archivos con el mismo nombre en diferentes carpetas
Write-Host "`n[2] Buscando archivos con el mismo nombre..." -ForegroundColor Yellow
$nameDuplicates = $files | Group-Object Name | Where-Object { $_.Count -gt 1 }

if ($nameDuplicates) {
    foreach ($group in $nameDuplicates) {
        Write-Host "`n[!] NOMBRE DUPLICADO: $($group.Name)" -ForegroundColor Magenta
        foreach ($file in $group.Group) {
            $relativePath = $file.FullName.Replace($PSScriptRoot, "")
            Write-Host "   - $relativePath"
        }
    }
} else {
    Write-Host "[OK] No se encontraron nombres de archivo duplicados." -ForegroundColor Green
}

# 3. Verificar ubicación lógica (Heurística simple)
Write-Host "`n[3] Verificando estructura de carpetas..." -ForegroundColor Yellow

$misplacedCount = 0
foreach ($file in $files) {
    $path = $file.FullName
    $name = $file.Name
    $relativePath = $path.Replace($PSScriptRoot, "")

    if ($name -match "_controller.dart$" -and $path -notmatch "controllers") {
        Write-Host "[!] Controlador fuera de lugar: $relativePath" -ForegroundColor Red
        $misplacedCount++
    }
    if ($name -match "_service.dart$" -and $path -notmatch "services") {
        Write-Host "[!] Servicio fuera de lugar: $relativePath" -ForegroundColor Red
        $misplacedCount++
    }
    if ($name -match "_screen.dart$" -and $path -notmatch "screens") {
        Write-Host "[!] Pantalla fuera de lugar: $relativePath" -ForegroundColor Red
        $misplacedCount++
    }
    if ($name -match "_model.dart$" -and $path -notmatch "models") {
        Write-Host "[!] Modelo fuera de lugar: $relativePath" -ForegroundColor Red
        $misplacedCount++
    }
}

if ($misplacedCount -eq 0) {
    Write-Host "[OK] La estructura de archivos parece coherente." -ForegroundColor Green
}

Write-Host "`nAnalisis completado." -ForegroundColor Cyan