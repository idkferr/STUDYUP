# Script de Limpieza y Recompilación
# STUDY UP - Flutter

Write-Host "🧹 Limpiando proyecto Flutter..." -ForegroundColor Cyan

# Navegar al directorio del proyecto
Set-Location "c:\Users\Fernanda\study_up\study_up"

# 1. Flutter clean
Write-Host "`n1️⃣ Ejecutando flutter clean..." -ForegroundColor Yellow
flutter clean

# 2. Eliminar archivos de caché adicionales
Write-Host "`n2️⃣ Eliminando archivos de caché..." -ForegroundColor Yellow
if (Test-Path ".dart_tool") {
    Remove-Item -Recurse -Force ".dart_tool"
    Write-Host "   ✅ .dart_tool eliminado" -ForegroundColor Green
}

if (Test-Path "build") {
    Remove-Item -Recurse -Force "build"
    Write-Host "   ✅ build eliminado" -ForegroundColor Green
}

# 3. Flutter pub get
Write-Host "`n3️⃣ Ejecutando flutter pub get..." -ForegroundColor Yellow
flutter pub get

# 4. Verificar análisis
Write-Host "`n4️⃣ Analizando código..." -ForegroundColor Yellow
flutter analyze --no-fatal-infos

Write-Host "`n✅ ¡Limpieza completada!" -ForegroundColor Green
Write-Host "`n🚀 Ahora puedes ejecutar: flutter run" -ForegroundColor Cyan
