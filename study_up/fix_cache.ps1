# ==========================================
# SCRIPT DE SOLUCIÓN COMPLETA
# STUDY UP - Flutter Cache Reset
# ==========================================

Write-Host ""
Write-Host "🔧 INICIANDO LIMPIEZA PROFUNDA DE FLUTTER..." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Navegar al directorio del proyecto
$projectPath = "c:\Users\Fernanda\study_up\study_up"
Set-Location $projectPath

# ==========================================
# PASO 1: Detener procesos de Dart/Flutter
# ==========================================
Write-Host "1️⃣  Deteniendo procesos de Dart y Flutter..." -ForegroundColor Yellow
try {
    taskkill /F /IM dart.exe /T 2>$null
    taskkill /F /IM flutter.exe /T 2>$null
    Write-Host "   ✅ Procesos detenidos" -ForegroundColor Green
} catch {
    Write-Host "   ℹ️  No había procesos corriendo" -ForegroundColor Gray
}
Start-Sleep -Seconds 2

# ==========================================
# PASO 2: Eliminar archivos de caché
# ==========================================
Write-Host ""
Write-Host "2️⃣  Eliminando archivos de caché..." -ForegroundColor Yellow

$filesToDelete = @(
    ".dart_tool",
    "build",
    ".flutter-plugins",
    ".flutter-plugins-dependencies",
    "pubspec.lock"
)

foreach ($file in $filesToDelete) {
    if (Test-Path $file) {
        Remove-Item -Recurse -Force $file -ErrorAction SilentlyContinue
        Write-Host "   ✅ $file eliminado" -ForegroundColor Green
    } else {
        Write-Host "   ⏭️  $file no existe (omitido)" -ForegroundColor Gray
    }
}

# ==========================================
# PASO 3: Flutter Clean
# ==========================================
Write-Host ""
Write-Host "3️⃣  Ejecutando flutter clean..." -ForegroundColor Yellow
flutter clean | Out-Null
Write-Host "   ✅ Flutter clean completado" -ForegroundColor Green

# ==========================================
# PASO 4: Flutter Pub Get
# ==========================================
Write-Host ""
Write-Host "4️⃣  Obteniendo dependencias..." -ForegroundColor Yellow
flutter pub get
Write-Host "   ✅ Dependencias actualizadas" -ForegroundColor Green

# ==========================================
# PASO 5: Verificación
# ==========================================
Write-Host ""
Write-Host "5️⃣  Verificando archivos críticos..." -ForegroundColor Yellow

$criticalFiles = @(
    "lib\application\calificaciones_provider.dart",
    "lib\presentation\screens\calificaciones\calificaciones_screen.dart",
    "lib\presentation\screens\calificaciones\calificacion_form_screen.dart",
    "lib\presentation\screens\materias\materias_screen.dart"
)

$allExist = $true
foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        Write-Host "   ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $file NO ENCONTRADO" -ForegroundColor Red
        $allExist = $false
    }
}

# ==========================================
# RESULTADO
# ==========================================
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
if ($allExist) {
    Write-Host "✅ LIMPIEZA COMPLETADA EXITOSAMENTE" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 PRÓXIMOS PASOS:" -ForegroundColor Cyan
    Write-Host "   1. En VS Code: Ctrl+Shift+P" -ForegroundColor White
    Write-Host "   2. Escribe: 'Dart: Restart Analysis Server'" -ForegroundColor White
    Write-Host "   3. Presiona Enter y espera 10-15 segundos" -ForegroundColor White
    Write-Host "   4. Ejecuta: flutter run -d chrome" -ForegroundColor White
    Write-Host ""
    Write-Host "🚀 O ejecuta directamente:" -ForegroundColor Cyan
    Write-Host "   flutter run -d chrome" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "⚠️  ADVERTENCIA: Algunos archivos no se encontraron" -ForegroundColor Yellow
    Write-Host "   Verifica que estés en el directorio correcto" -ForegroundColor White
}
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
