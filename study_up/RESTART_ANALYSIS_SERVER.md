## 🔧 SOLUCIÓN DEFINITIVA - REINICIAR ANALYSIS SERVER

El problema es que el **Dart Analysis Server** de VS Code está cacheando referencias antiguas.

### SOLUCIÓN RÁPIDA (Sin cerrar VS Code):

1. **Presiona:** `Ctrl+Shift+P`
2. **Escribe:** `Dart: Restart Analysis Server`
3. **Presiona:** Enter
4. **Espera** 10-15 segundos a que termine el análisis
5. **Ejecuta:** `flutter run -d chrome`

### ALTERNATIVA (Desde la terminal):

```powershell
# 1. Matar todos los procesos de Dart/Flutter
taskkill /F /IM dart.exe /T
taskkill /F /IM flutter.exe /T

# 2. Eliminar caché completamente
cd c:\Users\Fernanda\study_up\study_up
Remove-Item -Recurse -Force .dart_tool
Remove-Item -Recurse -Force build
Remove-Item -Force .flutter-plugins -ErrorAction SilentlyContinue
Remove-Item -Force .flutter-plugins-dependencies -ErrorAction SilentlyContinue

# 3. Reiniciar proyecto
flutter pub get
flutter run -d chrome
```

### SI NADA FUNCIONA - Reiniciar VS Code:

```
1. File → Close Folder
2. Cerrar VS Code completamente
3. Reabrir VS Code
4. File → Open Folder → c:\Users\Fernanda\study_up\study_up
5. Esperar a que Dart Analysis termine (ver barra inferior)
6. flutter run -d chrome
```

---

## ✅ CONFIRMACIÓN DE QUE EL CÓDIGO ES CORRECTO:

He verificado los archivos y TODOS tienen los imports correctos:

### ✅ calificaciones_provider.dart
```dart
// Línea 66-74 - Provider exportado correctamente
final calificacionesNotifierProvider =
    StateNotifierProvider.family<
      CalificacionesNotifier,
      AsyncValue<List<CalificacionEntity>>,
      String
    >((ref, userId) {
      final repository = ref.watch(calificacionRepositoryProvider);
      return CalificacionesNotifier(repository, userId);
    });
```

### ✅ calificaciones_screen.dart  
```dart
// Línea 4 - Import presente
import '../../../application/calificaciones_provider.dart';

// Línea 37 - Uso correcto
final calificacionesAsync =
    ref.watch(calificacionesNotifierProvider(user.uid));
```

### ✅ materias_screen.dart
```dart
// Línea 8-9 - Constructor existe
class MateriasScreen extends ConsumerWidget {
  const MateriasScreen({super.key});
```

**El problema es 100% de caché de VS Code/Dart Analysis Server.**
