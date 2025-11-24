@echo off
echo ========================================
echo  REINICIANDO DART ANALYSIS SERVER
echo ========================================
echo.
echo Matando procesos de Dart...
taskkill /F /IM dart.exe /T >nul 2>&1
taskkill /F /IM dartaotruntime.exe /T >nul 2>&1
echo.
echo Esperando 3 segundos...
timeout /t 3 /nobreak >nul
echo.
echo ========================================
echo LISTO! Ahora:
echo 1. Abre VS Code
echo 2. Abre el proyecto
echo 3. Ejecuta: flutter run -d chrome
echo ========================================
pause
