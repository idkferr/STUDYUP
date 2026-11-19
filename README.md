# StudyUp

App móvil multiplataforma para que estudiantes universitarios organicen su semestre: **asignaturas, horario, calificaciones y progreso académico** en un solo lugar.

Desarrollada con **Flutter** y **Firebase**, siguiendo una **arquitectura hexagonal** (dominio, aplicación, infraestructura y presentación).

## Funcionalidades

| Módulo | Qué permite |
|---|---|
| **Cuenta** | Registro e inicio de sesión con correo o con Google (Firebase Auth) |
| **Asignaturas** | Crear, editar y ver el detalle de cada asignatura del semestre |
| **Horario** | Calendario semanal con los bloques de clases y recordatorios con notificaciones locales |
| **Calificaciones** | Registrar notas por asignatura y **simular** qué nota se necesita para aprobar |
| **Progreso** | Resumen del avance académico del semestre |

## Tecnologías

- **Flutter / Dart** (Android, iOS, web y escritorio)
- **Firebase**: Authentication, Cloud Firestore
- **Riverpod** para el manejo de estado
- `table_calendar`, `flutter_local_notifications`, `google_fonts`, `intl`
- Pruebas: `flutter_test`, `mockito`, `mocktail`, `fake_cloud_firestore`
- Pruebas de rendimiento con **Locust** (`locustfile.py`)

## Arquitectura

```
lib/
├── domain/           Entidades, contratos de repositorios y servicios (sin dependencias externas)
├── application/      Providers de Riverpod que coordinan los casos de uso
├── infrastructure/   Implementaciones con Firebase (datasources, repositorios, validadores)
└── presentation/     Pantallas, rutas, tema y widgets
test/                 Pruebas de entidades, repositorios y datasources
```

Patrones aplicados: **Repository**, **Observer** (providers reactivos) y **Factory Method**.

## Cómo ejecutarlo

Requisitos: Flutter 3.16 o superior y un proyecto de Firebase propio.

```bash
git clone https://github.com/idkferr/STUDYUP.git
cd STUDYUP
flutter pub get
flutterfire configure   # genera lib/firebase_options.dart con tu proyecto
flutter run
```

Para correr las pruebas:

```bash
flutter test
```

## Contexto

Proyecto desarrollado en equipo para un curso de Ingeniería de Software (2025).
