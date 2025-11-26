import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_up/presentation/routes/app_routes.dart';

/// Tests para la configuración de rutas de la aplicación
///
/// NOTA: Tests completos de navegación requieren mockear Firebase
/// Aquí solo validamos la estructura de rutas
void main() {
  group('AppRoutes Configuration Tests', () {
    test('should have initial route defined', () {
      // Assert
      expect(AppRoutes.initialRoute, isNotNull);
      expect(AppRoutes.initialRoute, isNotEmpty);
    });

    test('should have routes map defined', () {
      // Assert
      expect(AppRoutes.routes, isNotNull);
      expect(AppRoutes.routes, isNotEmpty);
    });

    test('routes map should contain initial route', () {
      // Assert
      expect(AppRoutes.routes.containsKey(AppRoutes.initialRoute), isTrue);
    });

    test('all routes should have valid builder functions', () {
      // Act & Assert
      AppRoutes.routes.forEach((key, builder) {
        expect(key, isNotEmpty, reason: 'Route key should not be empty');
        expect(builder, isNotNull,
            reason: 'Builder for route $key should not be null');
        expect(builder, isA<WidgetBuilder>(),
            reason: 'Builder should be a WidgetBuilder');
      });
    });

    test('should have at least one route defined', () {
      // Assert
      expect(AppRoutes.routes.length, greaterThan(0));
    });
  });

  group('AppRoutes Named Routes Tests', () {
    // Si AppRoutes tiene rutas estáticas como login, register, etc.
    // Descomenta y ajusta según tu implementación:

    // test('should have login route', () {
    //   expect(AppRoutes.login, isNotNull);
    //   expect(AppRoutes.routes.containsKey(AppRoutes.login), isTrue);
    // });

    // test('should have register route', () {
    //   expect(AppRoutes.register, isNotNull);
    //   expect(AppRoutes.routes.containsKey(AppRoutes.register), isTrue);
    // });

    // test('should have home route', () {
    //   expect(AppRoutes.home, isNotNull);
    //   expect(AppRoutes.routes.containsKey(AppRoutes.home), isTrue);
    // });
  });
}
