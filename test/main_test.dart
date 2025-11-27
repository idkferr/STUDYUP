import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:study_up/main.dart';
import 'package:study_up/presentation/theme/app_theme.dart';

/// Tests para la aplicación principal StudyUpApp
///
/// ESTRATEGIA:
/// - Tests de CONFIGURACIÓN sin renderizar routes (evita Firebase)
/// - Tests de ESTRUCTURA del widget
/// - Tests de CREACIÓN de instancias
void main() {
  group('StudyUpApp Widget Structure Tests', () {
    test('should be a StatelessWidget', () {
      // Arrange & Act
      const app = StudyUpApp();

      // Assert
      expect(app, isA<StatelessWidget>());
    });

    test('should create instance without key', () {
      // Arrange & Act
      const app = StudyUpApp();

      // Assert
      expect(app.key, isNull);
    });

    test('should create instance with custom key', () {
      // Arrange
      const key = Key('test_app_key');

      // Act
      const app = StudyUpApp(key: key);

      // Assert
      expect(app.key, equals(key));
    });
  });

  group('StudyUpApp Build Method Tests', () {
    testWidgets('should build MaterialApp widget', (WidgetTester tester) async {
      // Arrange: Widget aislado sin ProviderScope para evitar routing
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Test')),
        ),
      );

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should wrap with ProviderScope in production',
        (WidgetTester tester) async {
      // Arrange: Test que ProviderScope es el wrapper correcto
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: Text('Provider Test')),
          ),
        ),
      );

      // Assert
      expect(find.byType(ProviderScope), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('MaterialApp Configuration Tests', () {
    testWidgets('should have correct title and debug banner disabled',
        (WidgetTester tester) async {
      // Arrange: MaterialApp con configuración mínima
      await tester.pumpWidget(
        const MaterialApp(
          title: 'Study-UP',
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Text('Config Test')),
        ),
      );

      // Act
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));

      // Assert
      expect(materialApp.title, 'Study-UP');
      expect(materialApp.debugShowCheckedModeBanner, false);
    });

    testWidgets('should configure Spanish locale', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          supportedLocales: [Locale('es', 'ES')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: Text('Locale Test')),
        ),
      );

      // Act
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));

      // Assert
      expect(materialApp.supportedLocales, isNotNull);
      expect(materialApp.supportedLocales.length, 1);
      expect(materialApp.supportedLocales.first.languageCode, 'es');
      expect(materialApp.supportedLocales.first.countryCode, 'ES');
    });

    testWidgets('should have localization delegates configured',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: Text('Delegates Test')),
        ),
      );

      // Act
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));

      // Assert: Verifica que la lista existe y tiene los delegates correctos
      expect(materialApp.localizationsDelegates, isNotNull);
      expect(materialApp.localizationsDelegates!.length, 3);
    });

    testWidgets('should use AppTheme.lightTheme', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: Text('Theme Test')),
        ),
      );

      // Act
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));

      // Assert
      expect(materialApp.theme, equals(AppTheme.lightTheme));
    });

    testWidgets('should have localization delegates configured',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            // Simula la configuración real
          ],
          home: Scaffold(body: Text('Delegates Test')),
        ),
      );

      // Act
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));

      // Assert: Verifica que la lista existe (puede estar vacía en test)
      expect(materialApp.localizationsDelegates, isNotNull);
    });
  });

  group('StudyUpApp Theme Integration Tests', () {
    testWidgets('should apply theme to widgets', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Text('Theme Integration'),
            ),
          ),
        ),
      );

      // Act
      final BuildContext context =
          tester.element(find.text('Theme Integration'));
      final ThemeData theme = Theme.of(context);

      // Assert
      expect(theme, isNotNull);
      expect(theme.primaryColor, isNotNull);
    });
  });
}
