# 🚨 ERRORES ACTUALES Y SOLUCIONES - STUDY-UP

## Fecha: 23 de Noviembre, 2025

## ❌ PROBLEMAS IDENTIFICADOS

### 1. **archivo: `materias_screen.dart` - CORRUPTO** 🔴
**Problema:** El archivo está duplicado y tiene errores de sintaxis graves.

**Solución:**
1. Eliminar el archivo completamente
2. Recrear desde cero
3. Usar `user.uid` en lugar de `user.id`

### 2. **archivo: `materia_form_screen.dart` - ERRORES MENORES** 🟡
**Problemas:**
- `userAsync.value` puede ser null
- Método `_validarCodigo` no referenciado

**Solución:**
```dart
// Cambiar:
final user = userAsync.value;
// Por:
final user = ref.watch(userProvider);

// Eliminar método no usado:
// Future<String?> _validarCodigo(...) 
```

### 3. **archivo: `calificacion_form_screen.dart` - DESACTUALIZADO** 🔴
**Problemas:**
- Usa `widget.calificacion?.materia` (ya no existe)
- Usa `widget.calificacion?.fecha` (eliminado)
- No tiene `materiaId` ni `porcentaje`
- No usa validaciones del sistema chileno

**Solución:** REESCRIBIR COMPLETAMENTE
- Agregar dropdown de materias
- Usar `materiaId` en lugar de `materia`
- Eliminar campo `fecha`
- Agregar validación de `porcentaje` obligatorio
- Usar `FormValidators.validateNotaChilena()`

### 4. **archivo: `calificaciones_screen.dart` - WARNING** 🟡
**Problema:**
- Variable `user` no usada

**Solución:**
```dart
// El usuario se necesita para cargar calificaciones
final calificacionesAsync = ref.watch(calificacionesNotifierProvider(user.uid));
```

### 5. **archivo: `calificaciones_provider.dart` - SOLUCIONADO** ✅
**Estado:** Ya fue recreado correctamente con el patrón `.family`

---

## 🔧 PASOS PARA CORREGIR TODOS LOS ERRORES

### PASO 1: Eliminar archivos corruptos
```powershell
cd c:\Users\Fernanda\study_up\study_up
Remove-Item "lib\presentation\screens\materias\materias_screen.dart" -Force
```

### PASO 2: Recrear `materias_screen.dart`
Ver archivo adjunto: `materias_screen_FIXED.dart`

### PASO 3: Corregir `materia_form_screen.dart`
```dart
// En línea ~60, cambiar:
- final user = userAsync.value;
+ final user = ref.watch(userProvider);

// En línea ~120, eliminar método completo:
- Future<String?> _validarCodigo(...) { ... }
```

### PASO 4: REESCRIBIR `calificacion_form_screen.dart`
Ver archivo adjunto: `calificacion_form_screen_FIXED.dart`

### PASO 5: Actualizar `calificaciones_screen.dart`
```dart
// Agregar después de obtener user:
final calificacionesAsync = ref.watch(calificacionesNotifierProvider(user.uid));

// Usar calificacionesAsync para mostrar datos
```

---

## 📝 ARCHIVOS DE REFERENCIA CORRECTOS

### `materias_screen.dart` - CORRECTO
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/materias_provider.dart';
import '../../../application/user_provider.dart';
import '../../../domain/entities/materia_entity.dart';
import '../../theme/app_theme.dart';

class MateriasScreen extends ConsumerWidget {
  const MateriasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    // IMPORTANTE: user.uid NO user.id
    final materiasAsync = ref.watch(materiasNotifierProvider(user.uid));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ... SliverAppBar y resto del código
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/materia-form'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Materia'),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );
  }
}
```

### `calificacion_form_screen.dart` - ESTRUCTURA CORRECTA
```dart
class CalificacionFormScreen extends ConsumerStatefulWidget {
  const CalificacionFormScreen({super.key});
  
  @override
  ConsumerState<CalificacionFormScreen> createState() => _CalificacionFormScreenState();
}

class _CalificacionFormScreenState extends ConsumerState<CalificacionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _porcentajeController = TextEditingController();
  
  String? _selectedMateriaId;  // ← IMPORTANTE
  bool _isLoading = false;
  CalificacionEntity? _calificacionExistente;
  
  // ... resto del código
  
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }
    
    final materiasAsync = ref.watch(materiasNotifierProvider(user.uid));
    
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Calificación')),
      body: materiasAsync.when(
        data: (materias) {
          if (materias.isEmpty) {
            return Center(
              child: Text('Crea materias primero'),
            );
          }
          
          return Form(
            key: _formKey,
            child: Column(
              children: [
                // Dropdown de Materias
                DropdownButtonFormField<String>(
                  value: _selectedMateriaId,
                  decoration: InputDecoration(
                    labelText: 'Materia',
                    prefixIcon: Icon(Icons.book),
                  ),
                  items: materias.map((m) => DropdownMenuItem(
                    value: m.id,
                    child: Text(m.nombre),
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedMateriaId = value),
                ),
                
                // Campo Nota (1.0-7.0)
                TextFormField(
                  controller: _notaController,
                  decoration: InputDecoration(labelText: 'Nota (1.0-7.0)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: FormValidators.validateNotaChilena,
                ),
                
                // Campo Porcentaje (OBLIGATORIO)
                TextFormField(
                  controller: _porcentajeController,
                  decoration: InputDecoration(labelText: 'Porcentaje (%)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: FormValidators.validatePorcentaje,
                ),
                
                // Campo Descripción
                TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                ),
                
                // Botón Guardar
                ElevatedButton(
                  onPressed: _guardarCalificacion,
                  child: Text('Guardar'),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
  
  Future<void> _guardarCalificacion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMateriaId == null) return;
    
    final user = ref.read(userProvider);
    if (user == null) return;
    
    final calificacion = CalificacionEntity(
      id: _calificacionExistente?.id,
      userId: user.uid,
      materiaId: _selectedMateriaId!,  // ← IMPORTANTE
      nota: double.parse(_notaController.text),
      descripcion: _descripcionController.text,
      porcentaje: double.parse(_porcentajeController.text),  // ← IMPORTANTE
    );
    
    final notifier = ref.read(calificacionesNotifierProvider(user.uid).notifier);
    
    if (_calificacionExistente == null) {
      await notifier.crearCalificacion(calificacion);
    } else {
      await notifier.actualizarCalificacion(calificacion);
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
```

---

## ✅ CHECKLIST DE CORRECCIÓN

- [x] calificaciones_provider.dart - Recreado con `.family`
- [ ] materias_screen.dart - Eliminar y recrear
- [ ] materia_form_screen.dart - Corregir `user.uid` y eliminar método no usado
- [ ] calificacion_form_screen.dart - REESCRIBIR COMPLETAMENTE
- [ ] calificaciones_screen.dart - Usar user.uid

---

## 🎯 ERRORES CRÍTICOS RESUELTOS

### UserEntity - Propiedad correcta:
```dart
class UserEntity {
  final String uid;  // ← CORRECTO
  final String email;
}

// Uso correcto:
user.uid  // ✅
user.id   // ❌ NO EXISTE
```

### CalificacionEntity - Propiedades actualizadas:
```dart
class CalificacionEntity {
  final String? id;
  final String userId;
  final String materiaId;     // ✅ Era "materia"
  final double nota;          // ✅ Rango 1.0-7.0
  final String descripcion;
  final double porcentaje;    // ✅ OBLIGATORIO (antes opcional)
  // ❌ ELIMINADO: final DateTime fecha;
}
```

---

## 📋 COMANDOS ÚTILES

```powershell
# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Analizar errores
flutter analyze

# Ejecutar aplicación
flutter run -d chrome
```

---

## 🚨 PRIORIDADES

1. **CRÍTICO:** Recrear `materias_screen.dart`
2. **CRÍTICO:** Reescribir `calificacion_form_screen.dart`
3. **ALTO:** Corregir `materia_form_screen.dart`
4. **MEDIO:** Actualizar `calificaciones_screen.dart`

---

**Última Actualización:** 23 de Noviembre, 2025  
**Estado:** 🔴 Errores pendientes de corrección  
**Archivos afectados:** 4 archivos  
**Archivos corregidos:** 1 archivo (calificaciones_provider.dart)
