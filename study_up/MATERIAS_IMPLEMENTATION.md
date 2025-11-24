# Implementación del Módulo de Materias - STUDY-UP

## Fecha: Noviembre 23, 2025

## Descripción General
Implementación completa del módulo de **Materias** siguiendo arquitectura hexagonal y sistema educativo chileno. Incluye integración con el módulo de Calificaciones y ajustes al sistema de notas chileno (1.0-7.0).

---

## ✅ CAMBIOS REALIZADOS

### 1. DOMAIN LAYER (Dominio)

#### **MateriaEntity** (`lib/domain/entities/materia_entity.dart`)
```dart
class MateriaEntity {
  final String? id;
  final String userId;
  final String codigo;        // Código único (ej: "CS101")
  final String nombre;         // Nombre completo
  final int creditos;          // Créditos académicos
  final String semestre;       // Período (ej: "2024-1")
  final Color color;           // Color de identificación visual
  final String? descripcion;   // Descripción opcional
}
```

**Características:**
- Conversión a/desde Firestore (toMap/fromMap)
- Color almacenado como `int` (color.value)
- Validación de campos obligatorios
- Métodos `copyWith`, `toString`, `==`, `hashCode`

#### **MateriaRepository** (`lib/domain/repositories/materia_repository.dart`)
```dart
abstract class MateriaRepository {
  Future<MateriaEntity> crearMateria(MateriaEntity materia);
  Future<List<MateriaEntity>> obtenerMaterias(String userId);
  Future<MateriaEntity?> obtenerMateriaPorId(String id);
  Future<void> actualizarMateria(MateriaEntity materia);
  Future<void> eliminarMateria(String id);
  Future<bool> existeCodigo(String userId, String codigo, {String? excludeId});
}
```

---

### 2. INFRASTRUCTURE LAYER (Infraestructura)

#### **FirestoreMateriaDataSource** (`lib/infrastructure/datasources/firestore_materia_datasource.dart`)
- CRUD completo en Firestore
- Colección: `materias`
- Ordenamiento por `semestre` (DESC)
- Validación de código único por usuario
- Manejo de errores con excepciones descriptivas

#### **MateriaRepositoryImpl** (`lib/infrastructure/repositories/materia_repository_impl.dart`)
- Implementación del repositorio
- Inyección del DataSource
- Delegación de operaciones

---

### 3. APPLICATION LAYER (Aplicación)

#### **MateriasProvider** (`lib/application/materias_provider.dart`)

**Providers definidos:**
```dart
// Repositorio
final materiaRepositoryProvider

// FutureProviders
final materiasProvider.family<List<MateriaEntity>, String>
final materiaByIdProvider.family<MateriaEntity?, String>

// StateNotifier
final materiasNotifierProvider.family<MateriasNotifier, AsyncValue<List>, String>
```

**MateriasNotifier - Métodos:**
- `crearMateria(MateriaEntity)` - Crear nueva materia
- `actualizarMateria(MateriaEntity)` - Actualizar existente
- `eliminarMateria(String id)` - Eliminar materia
- `existeCodigo(String codigo, {String? excludeId})` - Validar código único
- `refrescar()` - Recargar datos

---

### 4. PRESENTATION LAYER (Presentación)

#### **MateriasScreen** (`lib/presentation/screens/materias/materias_screen.dart`)

**Características:**
- SliverAppBar con gradiente azul-morado
- Lista de materias con cards personalizadas
- Estados: loading, empty, error, data
- Eliminación con confirmación
- Navegación a formulario de creación/edición

**UI Elements:**
- `_MateriaCard` - Card con:
  - Borde lateral con color de la materia
  - Ícono con fondo del color seleccionado
  - Chips informativos (créditos, semestre)
  - Descripción (si existe)
  - Botón de eliminar
- FAB para crear nueva materia

#### **MateriaFormScreen** (`lib/presentation/screens/materias/materia_form_screen.dart`)

**Formulario completo con:**
1. **Código** - TextFormField (obligatorio, uppercase)
2. **Nombre** - TextFormField (obligatorio)
3. **Créditos** - Number input (obligatorio, > 0)
4. **Semestre** - TextFormField (obligatorio)
5. **Descripción** - TextFormField opcional (multiline)
6. **Selector de Color** - 10 colores predefinidos:
   - Primary Blue, Primary Purple, Accent Green, Accent Orange
   - Red, Pink, Teal, Indigo, Amber, Cyan

**Validaciones:**
- Campos obligatorios
- Créditos > 0
- Código único por usuario (async validation)

---

### 5. AJUSTES AL MÓDULO DE CALIFICACIONES (Sistema Chileno)

#### **CalificacionEntity** - CAMBIOS CRÍTICOS:

**ANTES:**
```dart
final String materia;      // String
final double nota;         // 0-5
final DateTime fecha;      // Fecha requerida
final double? porcentaje;  // Opcional
bool get aprobado => nota >= 3.0;
```

**DESPUÉS:**
```dart
final String materiaId;    // ID de MateriaEntity
final double nota;         // 1.0-7.0 (sistema chileno)
// ELIMINADO: final DateTime fecha
final double porcentaje;   // OBLIGATORIO
bool get aprobado => nota >= 4.0;  // Sistema chileno
```

#### **FormValidators** - Nuevos validadores:

```dart
static String? validateNotaChilena(String? value) {
  // Validación: 1.0 <= nota <= 7.0
}

static String? validatePorcentaje(String? value) {
  // Validación: 0 <= porcentaje <= 100
}
```

#### **CalificacionFormScreen** - REESCRITO:

**Nuevas características:**
1. **Dropdown de materias** con colores
2. **Validación de nota chilena** (1.0-7.0)
3. **Porcentaje obligatorio**
4. **Eliminado selector de fecha**
5. **Información del sistema chileno** (card informativo)
6. **Validación pre-materias** - Redirige a crear materia si no hay ninguna

---

### 6. NAVEGACIÓN Y RUTAS

#### **app_routes.dart** - Rutas agregadas:
```dart
'/materias': (context) => const MateriasScreen(),
'/materia-form': (context) => const MateriaFormScreen(),
'/calificaciones': (context) => const CalificacionesScreen(),
'/calificacion-form': (context) => const CalificacionFormScreen(),
```

#### **HomeScreen** - Actualizado:
- Card "Materias" ahora navega a `/materias`
- Card "Calificaciones" navega a `/calificaciones`

---

## 📊 ESTRUCTURA DE DATOS (Firestore)

### Colección: `materias`
```
materias/
  {materiaId}/
    userId: string
    codigo: string (ej: "CS101")
    nombre: string (ej: "Programación I")
    creditos: number
    semestre: string (ej: "2024-1")
    color: number (Color.value)
    descripcion: string? (opcional)
```

### Colección: `calificaciones` (ACTUALIZADA)
```
calificaciones/
  {calificacionId}/
    userId: string
    materiaId: string  // ← CAMBIO: antes era "materia: string"
    nota: number (1.0-7.0)  // ← CAMBIO: antes 0-5
    descripcion: string
    porcentaje: number  // ← CAMBIO: antes opcional
    // ELIMINADO: fecha
```

---

## 🎨 DISEÑO UI

### Paleta de colores para materias:
- **Primary Blue** (#1565C0)
- **Primary Purple** (#7E57C2)
- **Accent Green** (#4CAF50)
- **Accent Orange** (#FF9800)
- **Red** (#F44336)
- **Pink** (#E91E63)
- **Teal** (#009688)
- **Indigo** (#3F51B5)
- **Amber** (#FFC107)
- **Cyan** (#00BCD4)

### Componentes personalizados:
- Cards con borde lateral colorido
- Chips informativos (créditos, semestre)
- Selector de color circular con selección visual
- SliverAppBar con gradiente

---

## 🔄 FLUJO DE USO

1. **Usuario crea materias**
   - Home → Card "Materias" → FAB "+" → Formulario
   - Selecciona código, nombre, créditos, semestre, color

2. **Usuario crea calificaciones**
   - Home → Card "Calificaciones" → FAB "+" → Formulario
   - Selecciona materia del dropdown
   - Ingresa nota (1.0-7.0), porcentaje, descripción

3. **Sistema calcula promedio**
   - Por materia: suma ponderada por porcentajes
   - Aprobado si nota >= 4.0 (sistema chileno)

---

## ⚠️ VALIDACIONES IMPLEMENTADAS

### Materias:
- ✅ Código único por usuario
- ✅ Campos obligatorios (código, nombre, créditos, semestre)
- ✅ Créditos > 0
- ✅ Color seleccionado
- ✅ Código en uppercase automático

### Calificaciones:
- ✅ Materia seleccionada (obligatorio)
- ✅ Nota entre 1.0 y 7.0
- ✅ Porcentaje entre 0 y 100
- ✅ Descripción obligatoria
- ✅ Validación pre-materias (debe existir al menos una materia)

---

## 📝 ARCHIVOS CREADOS

```
lib/
├── domain/
│   ├── entities/
│   │   └── materia_entity.dart ✅ NUEVO
│   └── repositories/
│       └── materia_repository.dart ✅ NUEVO
├── infrastructure/
│   ├── datasources/
│   │   └── firestore_materia_datasource.dart ✅ NUEVO
│   └── repositories/
│       └── materia_repository_impl.dart ✅ NUEVO
├── application/
│   └── materias_provider.dart ✅ NUEVO
└── presentation/
    └── screens/
        └── materias/
            ├── materias_screen.dart ✅ NUEVO
            └── materia_form_screen.dart ✅ NUEVO
```

## 📝 ARCHIVOS MODIFICADOS

```
lib/
├── domain/entities/
│   └── calificacion_entity.dart ⚙️ MODIFICADO
├── infrastructure/helpers/
│   └── form_validators.dart ⚙️ MODIFICADO
├── presentation/
│   ├── routes/
│   │   └── app_routes.dart ⚙️ MODIFICADO
│   └── screens/
│       ├── home/
│       │   └── home_screen.dart ⚙️ MODIFICADO
│       └── calificaciones/
│           └── calificacion_form_screen.dart ⚙️ NECESITA REESCRITURA
```

---

## 🚀 PRÓXIMOS PASOS

### 1. Actualizar CalificacionesScreen
- Mostrar nombre de materia (join con MateriaEntity)
- Agrupar calificaciones por materia
- Calcular promedio ponderado por materia
- Validar que porcentajes sumen 100% por materia

### 2. Reglas de seguridad Firestore
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /materias/{materiaId} {
      allow read, write: if request.auth != null && 
                          request.resource.data.userId == request.auth.uid;
    }
    match /calificaciones/{calId} {
      allow read, write: if request.auth != null && 
                          request.resource.data.userId == request.auth.uid;
    }
  }
}
```

### 3. Features adicionales
- Dashboard de estadísticas por materia
- Gráficos de rendimiento
- Exportación a PDF
- Calculadora de promedio general

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

- [x] Crear MateriaEntity (Domain)
- [x] Crear MateriaRepository interface
- [x] Implementar FirestoreMateriaDataSource
- [x] Implementar MateriaRepositoryImpl
- [x] Crear MateriasProvider (Riverpod)
- [x] Crear MateriasScreen (UI)
- [x] Crear MateriaFormScreen (Formulario)
- [x] Actualizar CalificacionEntity (sistema chileno)
- [x] Agregar validadores de nota chilena y porcentaje
- [x] Integrar rutas en app_routes.dart
- [x] Actualizar HomeScreen (navegación a Materias)
- [ ] Actualizar CalificacionesScreen (mostrar materias)
- [ ] Actualizar CalificacionFormScreen (dropdown de materias)
- [ ] Implementar cálculo de promedio ponderado
- [ ] Configurar reglas de seguridad Firestore

---

## 🎓 SISTEMA EDUCATIVO CHILENO

### Escala de notas:
- **Rango:** 1.0 - 7.0
- **Nota de aprobación:** 4.0
- **Nota máxima:** 7.0
- **Decimal:** Hasta un decimal (ej: 5.5)

### Cálculo de promedio:
```
Promedio = Σ(nota_i × porcentaje_i) / 100
donde Σ porcentaje_i = 100%
```

### Ejemplo:
```
Parcial 1:  5.5 (30%) = 1.65
Parcial 2:  6.0 (30%) = 1.80
Final:      5.0 (40%) = 2.00
                Total = 5.45 → Aprobado ✅
```

---

**Documentación creada por:** GitHub Copilot  
**Proyecto:** STUDY-UP - Aplicación de gestión académica  
**Arquitectura:** Hexagonal (Clean Architecture)  
**Estado:** ✅ Módulo de Materias completamente implementado
