import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study_up/presentation/providers/auth_provider.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  group('AuthActions', () {
    late AuthActions authActions;

    setUp(() {
      authActions = AuthActions(mockAuth);
    });

    group('login', () {
      test('should return null on successful login', () async {
        // Arrange
        final mockCredential = MockUserCredential();
        when(() => mockAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);

        // Act
        final result = await authActions.login('test@test.com', 'password123');

        // Assert
        expect(result, isNull);
        verify(() => mockAuth.signInWithEmailAndPassword(
              email: 'test@test.com',
              password: 'password123',
            )).called(1);
      });

      test('should return error message on FirebaseAuthException', () async {
        // Arrange
        when(() => mockAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(FirebaseAuthException(
          code: 'user-not-found',
          message: 'Usuario no encontrado',
        ));

        // Act
        final result = await authActions.login('test@test.com', 'wrong');

        // Assert
        expect(result, 'Usuario no encontrado');
      });

      test('should return error message on invalid credentials', () async {
        // Arrange
        when(() => mockAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(FirebaseAuthException(
          code: 'wrong-password',
          message: 'Contraseña incorrecta',
        ));

        // Act
        final result = await authActions.login('test@test.com', 'wrong');

        // Assert
        expect(result, isNotNull);
        expect(result, 'Contraseña incorrecta');
      });
    });

    group('register', () {
      test('should return null on successful registration', () async {
        // Arrange
        final mockCredential = MockUserCredential();
        when(() => mockAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);

        // Act
        final result =
            await authActions.register('new@test.com', 'password123');

        // Assert
        expect(result, isNull);
        verify(() => mockAuth.createUserWithEmailAndPassword(
              email: 'new@test.com',
              password: 'password123',
            )).called(1);
      });

      test('should return error message on FirebaseAuthException', () async {
        // Arrange
        when(() => mockAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Email ya registrado',
        ));

        // Act
        final result = await authActions.register('exist@test.com', 'password');

        // Assert
        expect(result, 'Email ya registrado');
      });

      test('should return error message on weak password', () async {
        // Arrange
        when(() => mockAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(FirebaseAuthException(
          code: 'weak-password',
          message: 'Contraseña débil',
        ));

        // Act
        final result = await authActions.register('test@test.com', '123');

        // Assert
        expect(result, 'Contraseña débil');
      });
    });

    group('logout', () {
      test('should call signOut on FirebaseAuth', () async {
        // Arrange
        when(() => mockAuth.signOut()).thenAnswer((_) async => {});

        // Act
        await authActions.logout();

        // Assert
        verify(() => mockAuth.signOut()).called(1);
      });
    });
  });

  group('Providers', () {
    test('firebaseAuthProvider should provide FirebaseAuth instance', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
        ],
      );

      // Act
      final auth = container.read(firebaseAuthProvider);

      // Assert
      expect(auth, mockAuth);

      // Cleanup
      container.dispose();
    });

    test('authActionsProvider should provide AuthActions instance', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
        ],
      );

      // Act
      final actions = container.read(authActionsProvider);

      // Assert
      expect(actions, isA<AuthActions>());

      // Cleanup
      container.dispose();
    });

    test('authStateProvider should emit auth state changes', () async {
      // Arrange
      final mockUser = MockUser();
      final streamController = StreamController<User?>();

      when(() => mockAuth.authStateChanges())
          .thenAnswer((_) => streamController.stream);

      final container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
        ],
      );

      // Act - Primero suscribirse al stream
      final subscription = container.listen(
        authStateProvider,
        (previous, next) {},
      );

      // Luego emitir el valor
      streamController.add(mockUser);

      // Esperar a que el stream procese el valor
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(authStateProvider);

      // Assert
      expect(state.hasValue, true);
      expect(state.value, mockUser);

      // Cleanup
      subscription.close();
      streamController.close();
      container.dispose();
    });

    test('authStateProvider should emit null when user logs out', () async {
      // Arrange
      final streamController = StreamController<User?>();

      when(() => mockAuth.authStateChanges())
          .thenAnswer((_) => streamController.stream);

      final container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
        ],
      );

      // Act
      final subscription = container.listen(
        authStateProvider,
        (previous, next) {},
      );

      streamController.add(null);
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(authStateProvider);

      // Assert
      expect(state.hasValue, true);
      expect(state.value, isNull);

      // Cleanup
      subscription.close();
      streamController.close();
      container.dispose();
    });
  });
}
