# ==========================================
# SOLUCIÓN FINAL - CERRAR Y REABRIR TODO
# ==========================================

Write-Host ""
Write-Host "🔄 CERRANDO VS CODE..." -ForegroundColor Cyan

# 1. Cerrar VS Code
Get-Process -Name "Code" -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host "✅ VS Code cerrado" -ForegroundColor Green
Start-Sleep -Seconds 2

# 2. Matar procesos Dart
Write-Host ""
Write-Host "🔪 Matando procesos Dart..." -ForegroundColor Cyan
Get-Process -Name "dart*" -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host "✅ Procesos Dart terminados" -ForegroundColor Green

# 3. Navegar al proyecto
cd c:\Users\Fernanda\study_up\study_up

# 4. Limpiar caché
Write-Host ""
Write-Host "🧹 Limpiando caché..." -ForegroundColor Cyan
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Write-Host "✅ Caché limpiado" -ForegroundColor Green

# 5. Flutter clean
Write-Host ""
Write-Host "🧼 Ejecutando flutter clean..." -ForegroundColor Cyan
flutter clean | Out-Null
Write-Host "✅ Flutter clean completado" -ForegroundColor Green

# 6. Flutter pub get
Write-Host ""
Write-Host "📦 Obteniendo dependencias..." -ForegroundColor Cyan
flutter pub get | Out-Null
Write-Host "✅ Dependencias actualizadas" -ForegroundColor Green

# 7. Reabrir VS Code
Write-Host ""
Write-Host "🚀 Reabriendo VS Code..." -ForegroundColor Cyan
Start-Process "code" -ArgumentList "c:\Users\Fernanda\study_up\study_up"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✅ PROCESO COMPLETADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "AHORA:" -ForegroundColor Yellow
Write-Host "1. Espera a que VS Code termine de cargar" -ForegroundColor White
Write-Host "2. Espera a que termine 'Analyzing...' (barra inferior)" -ForegroundColor White
Write-Host "3. Ejecuta: flutter run -d chrome" -ForegroundColor White
Write-Host ""
