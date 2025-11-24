# Script para ejecutar la aplicación con limpieza completa
Write-Host "🧹 Limpiando proyecto..." -ForegroundColor Yellow

# Detener procesos dart que puedan estar corriendo
Get-Process dart -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Limpiar directorios
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue

Write-Host "✅ Directorios de build eliminados" -ForegroundColor Green

# Ejecutar flutter clean
Write-Host "🧹 Ejecutando flutter clean..." -ForegroundColor Yellow
flutter clean

# Obtener dependencias
Write-Host "📦 Obteniendo dependencias..." -ForegroundColor Yellow
flutter pub get

Write-Host "✅ Proyecto limpio y listo" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Ejecutando aplicación en Edge..." -ForegroundColor Cyan
Write-Host ""

# Ejecutar la aplicación
flutter run -d edge
