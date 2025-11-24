# 🚀 INSTRUCCIONES DE EJECUCIÓN - STUDY UP

## ✅ Estado del Proyecto: LISTO PARA EJECUTAR

---

## 📋 PRE-REQUISITOS

### 1. Verificar Instalaciones
```powershell
# Flutter
flutter --version

# Dart
dart --version

# Firebase CLI (opcional)
firebase --version
```

### 2. Configuración de Firebase
Asegúrate de tener:
- ✅ `google-services.json` en `android/app/`
- ✅ `GoogleService-Info.plist` en `ios/Runner/`
- ✅ `firebase_options.dart` en `lib/`

---

## 🏃 PASOS PARA EJECUTAR

### 1. Limpiar y Obtener Dependencias
```powershell
# Navegar al proyecto
cd c:\Users\Fernanda\study_up\study_up

# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get
```

### 2. Verificar Dispositivos Disponibles
```powershell
# Ver dispositivos conectados
flutter devices

# Listar emuladores
flutter emulators
```

### 3. Ejecutar la Aplicación
```powershell
# Modo Debug (con hot reload)
flutter run

# Modo Debug en dispositivo específico
flutter run -d <device-id>

# Modo Release (optimizado)
flutter run --release
```

---

## 🔍 VERIFICACIÓN DE ERRORES

### Antes de ejecutar, verifica:
```powershell
# Análisis estático
flutter analyze

# Verificar formato
flutter format --set-exit-if-changed .

# Ejecutar tests (si existen)
flutter test
```

---

## 🎯 FLUJO DE PRUEBA RECOMENDADO

### 1. **Registro/Login** (5 min)
- [ ] Abrir app
- [ ] Crear nueva cuenta con email
- [ ] Verificar redirección a Home
- [ ] Cerrar sesión
- [ ] Iniciar sesión nuevamente

### 2. **Crear Materias** (5 min)
- [ ] Ir a "Materias"
- [ ] Crear materia: "MAT101 - Matemáticas"
  - Código: MAT101
  - Nombre: Matemáticas
  - Créditos: 4
  - Semestre: 2024-1
  - Color: Azul
- [ ] Crear materia: "FIS201 - Física"
  - Código: FIS201
  - Nombre: Física
  - Créditos: 5
  - Semestre: 2024-1
  - Color: Verde
- [ ] Verificar que aparezcan en la lista

### 3. **Crear Calificaciones** (10 min)
- [ ] Ir a "Calificaciones"
- [ ] Crear calificación 1:
  - Materia: MAT101 - Matemáticas
  - Nota: 6.5
  - Porcentaje: 30
  - Descripción: Parcial 1
- [ ] Crear calificación 2:
  - Materia: MAT101 - Matemáticas
  - Nota: 5.8
  - Porcentaje: 20
  - Descripción: Tarea 1
- [ ] Crear calificación 3:
  - Materia: FIS201 - Física
  - Nota: 4.2
  - Porcentaje: 40
  - Descripción: Examen Parcial
- [ ] Verificar que aparezcan en la lista
- [ ] Verificar colores de materias en las cards

### 4. **Editar y Eliminar** (5 min)
- [ ] Editar una calificación
  - Cambiar nota
  - Guardar
  - Verificar cambios
- [ ] Eliminar una calificación
  - Presionar botón eliminar
  - Confirmar
  - Verificar que desapareció

### 5. **Validaciones** (5 min)
- [ ] Intentar crear calificación sin seleccionar materia → Error
- [ ] Intentar ingresar nota 8.0 → Error (máximo 7.0)
- [ ] Intentar ingresar nota 0.5 → Error (mínimo 1.0)
- [ ] Intentar ingresar porcentaje 150 → Error (máximo 100)
- [ ] Intentar ingresar porcentaje -10 → Error (mínimo 0)

---

## 🐛 SOLUCIÓN DE PROBLEMAS COMUNES

### Error: "FirebaseException"
```powershell
# Verificar configuración de Firebase
ls android/app/google-services.json
ls lib/firebase_options.dart

# Re-generar configuración
firebase login
flutterfire configure
```

### Error: "Gradle build failed"
```powershell
# Limpiar build
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Error: "CocoaPods not installed" (iOS)
```bash
# Instalar CocoaPods
sudo gem install cocoapods

# Instalar pods
cd ios
pod install
cd ..
flutter run
```

### Error: "Provider not found"
```powershell
# Verificar imports en archivos modificados
# Asegurarse de que todos usen:
# - calificacionesNotifierProvider (NO calificacionesProvider)
# - materiasNotifierProvider (NO materiasProvider)
```

---

## 📱 CARACTERÍSTICAS IMPLEMENTADAS

### ✅ Autenticación
- Login con email/password
- Registro de nuevos usuarios
- Persistencia de sesión
- Logout

### ✅ Materias
- CRUD completo (Crear, Leer, Actualizar, Eliminar)
- Código único por materia
- Colores personalizados
- Validación de campos

### ✅ Calificaciones
- CRUD completo
- Sistema chileno (1.0 - 7.0)
- Validación de nota >= 1.0 y <= 7.0
- Aprobación con nota >= 4.0
- Campo de porcentaje (0-100)
- Relación con materias
- Dropdown de materias con colores
- Descripción de evaluación

### ✅ UI/UX
- Gradientes en AppBars
- Cards con sombras
- Colores personalizados por materia
- Mensajes de confirmación/error
- Loading states
- Empty states (sin datos)

---

## 📊 ARQUITECTURA DEL PROYECTO

```
lib/
├── application/              # Providers (Riverpod)
│   ├── calificaciones_provider.dart
│   ├── materias_provider.dart
│   └── user_provider.dart
│
├── domain/                   # Entidades y repositorios
│   ├── entities/
│   │   ├── calificacion_entity.dart
│   │   ├── materia_entity.dart
│   │   └── user_entity.dart
│   └── repositories/
│       ├── calificaciones_repository.dart
│       ├── materias_repository.dart
│       └── auth_repository.dart
│
├── infrastructure/           # Implementaciones y helpers
│   ├── datasources/
│   │   ├── firebase_calificaciones_datasource.dart
│   │   ├── firebase_materias_datasource.dart
│   │   └── firebase_auth_datasource.dart
│   ├── helpers/
│   │   └── form_validators.dart
│   └── repositories/
│       └── (implementaciones)
│
└── presentation/             # UI
    ├── routes/
    │   └── app_routes.dart
    ├── screens/
    │   ├── auth_guard_screen.dart
    │   ├── home/
    │   ├── user/
    │   ├── materias/
    │   └── calificaciones/
    └── theme/
        └── app_theme.dart
```

---

## 🎨 PALETA DE COLORES

```dart
// Primarios
primaryBlue: #1565C0
primaryPurple: #7E57C2

// Acentos
accentGreen: #4CAF50
accentOrange: #FF9800

// Texto
textPrimary: #212121
textSecondary: #757575
```

---

## 📝 NOTAS IMPORTANTES

### Sistema de Calificación Chileno
- **Escala:** 1.0 - 7.0
- **Aprobación:** >= 4.0
- **Decimales:** Permitidos (ej: 5.5, 6.3, 6.8)
- **Validación:** `FormValidators.validateNotaChilena()`

### Providers con .family
```dart
// Calificaciones
ref.watch(calificacionesNotifierProvider(userId))

// Materias
ref.watch(materiasNotifierProvider(userId))

// User
ref.watch(userProvider) // No usa .family
```

### Firestore Collections
```
users/
  {userId}/
    - email
    - uid
    - createdAt

materias/
  {materiaId}/
    - userId
    - codigo
    - nombre
    - creditos
    - semestre
    - color
    - descripcion

calificaciones/
  {calificacionId}/
    - userId
    - materiaId
    - nota
    - porcentaje
    - descripcion
    - createdAt
```

---

## 🔐 SEGURIDAD (PENDIENTE)

### Configurar Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /materias/{materiaId} {
      allow read, write: if request.auth != null 
        && request.resource.data.userId == request.auth.uid;
    }
    
    match /calificaciones/{calificacionId} {
      allow read, write: if request.auth != null 
        && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## ✅ CHECKLIST DE EJECUCIÓN

- [ ] Flutter instalado y funcionando
- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] Firebase configurado correctamente
- [ ] Sin errores de análisis (`flutter analyze`)
- [ ] Dispositivo/emulador conectado
- [ ] App ejecutándose sin crashes
- [ ] Registro/login funcional
- [ ] Crear materia funcional
- [ ] Crear calificación funcional
- [ ] Editar/eliminar funcional
- [ ] Validaciones funcionando
- [ ] UI/UX correcta

---

## 🎉 ¡LISTO PARA USAR!

Si todos los pasos fueron exitosos, tu aplicación **STUDY UP** está completamente funcional y lista para gestionar materias y calificaciones en el sistema chileno.

**¡Éxito en tus estudios! 📚🎓**
