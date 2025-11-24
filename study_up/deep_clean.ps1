#!/usr/bin/env pwsh
# Script de limpieza profunda para Flutter

Write-Host "🧹 LIMPIEZA PROFUNDA DE FLUTTER" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Matar procesos
Write-Host "1️⃣ Matando procesos Dart y Flutter..." -ForegroundColor Yellow
Get-Process dart -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process flutter -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "   ✅ Procesos terminados" -ForegroundColor Green
Start-Sleep -Seconds 1

# Paso 2: Eliminar archivos de caché
Write-Host ""
Write-Host "2️⃣ Eliminando archivos de caché..." -ForegroundColor Yellow
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Force .flutter-plugins -ErrorAction SilentlyContinue
Remove-Item -Force .flutter-plugins-dependencies -ErrorAction SilentlyContinue
Remove-Item -Force .packages -ErrorAction SilentlyContinue
Remove-Item -Force pubspec.lock -ErrorAction SilentlyContinue
Write-Host "   ✅ Archivos de caché eliminados" -ForegroundColor Green

# Paso 3: Flutter clean
Write-Host ""
Write-Host "3️⃣ Ejecutando flutter clean..." -ForegroundColor Yellow
flutter clean | Out-Null
Write-Host "   ✅ Flutter clean completado" -ForegroundColor Green

# Paso 4: Flutter pub get
Write-Host ""
Write-Host "4️⃣ Descargando dependencias..." -ForegroundColor Yellow
flutter pub get
Write-Host "   ✅ Dependencias instaladas" -ForegroundColor Green

# Paso 5: Información final
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ LIMPIEZA COMPLETADA" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 PRÓXIMOS PASOS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. En VS Code:" -ForegroundColor White
Write-Host "   - Presiona: Ctrl + Shift + P" -ForegroundColor Gray
Write-Host "   - Escribe: 'Dart: Restart Analysis Server'" -ForegroundColor Gray
Write-Host "   - Presiona: Enter" -ForegroundColor Gray
Write-Host "   - Espera 15 segundos" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Ejecuta la aplicación:" -ForegroundColor White
Write-Host "   flutter run -d edge" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎯 DEBERÍAS VER:" -ForegroundColor Yellow
Write-Host "   ✓ Built build\web\main.dart.js" -ForegroundColor Green
Write-Host "   Launching lib\main.dart on Edge in debug mode..." -ForegroundColor Green
Write-Host ""
Write-Host "❌ NO DEBERÍAS VER:" -ForegroundColor Red
Write-Host "   Error: Method not found: 'MateriasScreen'" -ForegroundColor Red
Write-Host "   Error: Couldn't find constructor" -ForegroundColor Red
Write-Host ""
