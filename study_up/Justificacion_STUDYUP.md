# Justificación Técnica y Cobertura de Requerimientos – STUDY-UP

## Arquitectura Hexagonal

STUDY-UP está estructurada bajo el paradigma de arquitectura hexagonal (Ports & Adapters), lo que permite una clara separación entre la lógica de dominio, los casos de uso, la infraestructura y la presentación. Esto facilita la mantenibilidad, escalabilidad y testabilidad del sistema.

**Estructura de carpetas:**
```text
lib/
├── domain/         # Núcleo de negocio (entidades, repositorios, servicios)
├── application/    # Casos de uso (lógica de aplicación)
├── infrastructure/ # Adaptadores a tecnologías externas (Firebase, SQLite)
└── presentation/   # Interfaz de usuario y proveedores de estado
```

**Ejemplo de separación de capas:**
- `domain/entities/calificacion.dart`: Define la entidad Calificación y sus reglas de negocio.
- `application/use_cases/registrar_calificacion_use_case.dart`: Caso de uso para registrar una calificación.
- `infrastructure/repositories/firestore_calificacion_repository.dart`: Implementa la persistencia en Firestore.
- `presentation/screens/calificaciones_screen.dart`: Pantalla de UI para gestionar calificaciones.

---

## Patrones de Diseño Aplicados

### Repository Pattern

Permite desacoplar la lógica de dominio de la infraestructura de persistencia, facilitando el cambio entre Firestore y SQLite sin afectar el resto del sistema.

```dart
// domain/repositories/i_calificacion_repository.dart
abstract class ICalificacionRepository {
  Future<List<Calificacion>> obtenerTodas();
  Future<Calificacion> guardar(Calificacion calificacion);
  Future<void> eliminar(String id);
}
```
```dart
// infrastructure/repositories/firestore_calificacion_repository.dart
class FirestoreCalificacionRepository implements ICalificacionRepository {
  @override
  Future<List<Calificacion>> obtenerTodas() async {
    // Lógica con Firebase Firestore
  }
  // ...otros métodos...
}
```

### Observer Pattern

Utilizado para el sistema de notificaciones automáticas. Cuando se registra o modifica un recordatorio, los observadores (por ejemplo, el servicio de notificaciones) son notificados sin acoplar la lógica de negocio.

```dart
// domain/services/recordatorio_observer.dart
abstract class RecordatorioObserver {
  void onRecordatorioActivado(Recordatorio recordatorio);
}
```
```dart
// infrastructure/services/firebase_notification_service.dart
class FirebaseNotificationService implements RecordatorioObserver {
  @override
  void onRecordatorioActivado(Recordatorio recordatorio) {
    // Enviar notificación push
  }
}
```

### Factory Method

Permite la creación flexible de objetos de recordatorio según el tipo y los datos recibidos.

```dart
// domain/entities/recordatorio_factory.dart
class RecordatorioFactory {
  static Recordatorio crear(TipoRecordatorio tipo, Map<String, dynamic> datos) {
    // Lógica de creación según tipo
  }
}
```

---

## Requerimientos Extrafuncionales Cubiertos

- **Seguridad:** Contraseñas fuertes, verificación de email, reglas de Firestore, hash seguro y TLS 1.3.
- **Escalabilidad:** Backend serverless con Firebase, sincronización eficiente con almacenamiento local.
- **Usabilidad:** UI intuitiva (Material Design 3), validaciones y mensajes claros, flujos optimizados.
- **Compatibilidad:** Android 8+, iOS 12+, Web, persistencia local con SQLite/Drift e IndexedDB.
- **Rendimiento:** Carga inicial ≤3s, operaciones CRUD <2s, lazy loading, pruebas de carga con Locust.io.
- **Disponibilidad:** 99% uptime, modo offline-first, RTO ≤4h.
- **Mantenibilidad:** Código modular, documentado, principios SOLID, tests automatizados.
- **Trazabilidad:** Documentación de prompts LLM y decisiones técnicas.

---

## Caso de Uso Implementado al 100%: Gestión de Calificaciones (RF01)

**Descripción:**  
Permite a los estudiantes registrar, consultar, modificar y eliminar calificaciones, calculando automáticamente el promedio ponderado.

**Cobertura:**
- CRUD completo de calificaciones.
- Validación de nota (1.0-7.0) y pesos (100%).
- Sincronización online/offline (Firestore y SQLite).
- Cálculo automático de promedio.
- Notificaciones automáticas (Observer + FCM).
- Control de acceso y ownership por usuario.

**Extracto de código de validación de negocio:**
```dart
// domain/entities/calificacion.dart
class Calificacion {
  final double nota;
  final double peso;
  // ...
  Calificacion({required this.nota, required this.peso}) {
    if (nota < 1.0 || nota > 7.0) throw Exception('Nota fuera de rango');
    if (peso <= 0 || peso > 100) throw Exception('Peso inválido');
  }
}
```

**Extracto de caso de uso:**
```dart
// application/use_cases/registrar_calificacion_use_case.dart
class RegistrarCalificacionUseCase {
  final ICalificacionRepository repository;
  Future<void> call(Calificacion calificacion) async {
    // Validaciones y lógica de negocio
    await repository.guardar(calificacion);
  }
}
```

**Extracto de test unitario:**
```dart
// test/domain/entities/calificacion_test.dart
void main() {
  test('No permite notas fuera de rango', () {
    expect(() => Calificacion(nota: 8.0, peso: 20), throwsException);
  });
}
```

---

## Casos de Uso No Completos

- **Gestión de Tareas (RF02):** En desarrollo, no cubre todas las operaciones y validaciones requeridas.
- **Gestión de Horario Académico (RF03):** Parcialmente implementado, falta integración completa con notificaciones y validaciones avanzadas.
- **Notificaciones y Recordatorios (RF04):** Implementado solo para calificaciones y recordatorios básicos.
- **Gestión de Perfil de Usuario (RF05):** Funcionalidad básica, pendiente de mejoras en edición y seguridad avanzada.

---

## Conclusión

STUDY-UP implementa de forma profesional la arquitectura hexagonal y los principales patrones de diseño recomendados para aplicaciones modernas. El caso de uso de gestión de calificaciones está cubierto al 100%, cumpliendo con los requerimientos funcionales y extrafuncionales, y respaldado por código, pruebas y documentación clara. El resto de los casos de uso están en desarrollo o parcialmente implementados, lo cual se refleja en la planificación y entregables del proyecto.
