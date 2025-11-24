# 🎯 GUÍA PASO A PASO - SOLUCIÓN DEFINITIVA

## ⚠️ PROBLEMA ACTUAL:
```
Error: Couldn't find constructor 'MateriasScreen'
Error: The method 'calificacionesNotifierProvider' isn't defined
```

**Causa:** Dart Analysis Server tiene caché antiguo
**Solución:** Reiniciar Analysis Server + Limpieza

---

## ✅ SOLUCIÓN EN 3 PASOS (ELIGE UNO):

### 🥇 OPCIÓN 1: RÁPIDA (Recomendada - 30 segundos)

#### En VS Code:
1. Presiona: **`Ctrl + Shift + P`**
2. Escribe: **`Dart: Restart Analysis Server`**
3. Presiona: **Enter**
4. Espera 15 segundos (verás "Analyzing..." en la barra inferior)
5. Cuando termine, ejecuta en terminal:
   ```powershell
   flutter run -d chrome
   ```

---

### 🥈 OPCIÓN 2: COMPLETA (Si Opción 1 no funciona - 2 minutos)

#### Paso 1: Cerrar VS Code completamente
- File → Exit (o Alt+F4)

#### Paso 2: En PowerShell (como Administrador):
```powershell
# Navegar al proyecto
cd c:\Users\Fernanda\study_up\study_up

# Matar procesos
taskkill /F /IM dart.exe /T
taskkill /F /IM flutter.exe /T

# Eliminar caché
Remove-Item -Recurse -Force .dart_tool
Remove-Item -Recurse -Force build
Remove-Item -Force .flutter-plugins -ErrorAction SilentlyContinue
Remove-Item -Force .flutter-plugins-dependencies -ErrorAction SilentlyContinue
Remove-Item -Force pubspec.lock -ErrorAction SilentlyContinue

# Limpiar Flutter
flutter clean

# Obtener dependencias
flutter pub get
```

#### Paso 3: Reabrir VS Code
- Abrir VS Code
- File → Open Folder → `c:\Users\Fernanda\study_up\study_up`
- Esperar a que termine "Analyzing..."
- Ejecutar: `flutter run -d chrome`

---

### 🥉 OPCIÓN 3: AUTOMÁTICA (Usar script - 1 minuto)

```powershell
# Ejecutar script automático
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\fix_cache.ps1

# Luego en VS Code:
# Ctrl+Shift+P → "Dart: Restart Analysis Server"

# Finalmente:
flutter run -d chrome
```

---

## 📊 VERIFICACIÓN POST-LIMPIEZA

### ✅ Cómo saber si funcionó:

Después de ejecutar `flutter run -d chrome`, deberías ver:

```
✓ Built build\web\main.dart.js
Launching lib\main.dart on Chrome in debug mode...
√ Built build\web\main.dart.js.
Attempting to connect to browser instance...
```

**SIN** estos errores:
```
❌ Error: Couldn't find constructor 'MateriasScreen'
❌ Error: The method 'calificacionesNotifierProvider' isn't defined
```

---

## 🔍 SI AÚN HAY ERRORES

### Verificar que el código sea correcto:

```powershell
# Ver si el provider existe
Select-String -Path "lib\application\calificaciones_provider.dart" -Pattern "calificacionesNotifierProvider"

# Debería mostrar:
# lib\application\calificaciones_provider.dart:66:final calificacionesNotifierProvider =
```

### Verificar imports:

```powershell
# Ver si el import está presente
Select-String -Path "lib\presentation\screens\calificaciones\calificaciones_screen.dart" -Pattern "calificaciones_provider"

# Debería mostrar:
# lib\presentation\screens\calificaciones\calificaciones_screen.dart:4:import '../../../application/calificaciones_provider.dart';
```

---

## 🆘 ÚLTIMA OPCIÓN - REINSTALAR PROYECTO

Si NADA funciona (muy raro):

```powershell
# 1. Hacer backup de archivos importantes
Copy-Item -Path lib -Destination lib_backup -Recurse
Copy-Item -Path android\app\google-services.json -Destination google-services_backup.json

# 2. Crear proyecto nuevo
cd c:\Users\Fernanda\study_up
flutter create study_up_new

# 3. Copiar archivos
Copy-Item -Path study_up_backup\lib\* -Destination study_up_new\lib\ -Recurse -Force
Copy-Item -Path google-services_backup.json -Destination study_up_new\android\app\google-services.json

# 4. Copiar pubspec.yaml
Copy-Item -Path study_up_backup\pubspec.yaml -Destination study_up_new\pubspec.yaml

# 5. Instalar dependencias
cd study_up_new
flutter pub get
flutter run
```

**PERO NO DEBERÍA SER NECESARIO** - La Opción 1 o 2 debería funcionar.

---

## 💡 EXPLICACIÓN TÉCNICA

### ¿Por qué pasa esto?

1. **Cambios en Providers:** Modificamos de `StateNotifierProvider` a `StateNotifierProvider.family`
2. **Caché del Analysis Server:** Dart mantiene un servidor de análisis que cachea símbolos
3. **Hot Reload limitado:** Los cambios arquitectónicos requieren restart completo
4. **Archivos compilados:** `.dart_tool` y `build` tienen referencias antiguas

### ¿Qué hace cada solución?

- **Restart Analysis Server:** Limpia caché en memoria de símbolos
- **Eliminar .dart_tool:** Limpia análisis estático guardado
- **Eliminar build:** Limpia binarios compilados
- **flutter clean:** Limpia todos los archivos generados
- **flutter pub get:** Regenera configuración de dependencias

---

## ✅ CONFIRMACIÓN FINAL

Después de aplicar la solución, el proyecto debería:

1. ✅ Compilar sin errores
2. ✅ Iniciar en Chrome
3. ✅ Mostrar pantalla de login
4. ✅ Permitir navegación a Materias
5. ✅ Permitir navegación a Calificaciones
6. ✅ CRUD completo funcional

---

## 📝 RESUMEN DE COMANDOS

### Comando único (todo en uno):
```powershell
cd c:\Users\Fernanda\study_up\study_up; taskkill /F /IM dart.exe /T 2>$null; Remove-Item -Recurse -Force .dart_tool,.flutter-plugins,.flutter-plugins-dependencies,build,pubspec.lock -ErrorAction SilentlyContinue; flutter clean; flutter pub get; flutter run -d chrome
```

### Después del comando:
- En VS Code: `Ctrl+Shift+P` → `Dart: Restart Analysis Server`
- Esperar 15 segundos
- ✅ Listo

---

🎯 **ACCIÓN INMEDIATA:** Usa la **Opción 1** primero. Si no funciona, usa la **Opción 2**.
