import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study_up/domain/entities/user_entity.dart';
import 'package:study_up/infrastructure/datasources/firebase_auth_datasource.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late FirebaseAuthDatasource datasource;
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    datasource = FirebaseAuthDatasource(
      auth: mockAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('login', () {
    const email = 'test@test.com';
    const password = 'password123';

    test(
        'should return UserEntity when login is successful and email is verified',
        () async {
      when(() => mockUser.uid).thenReturn('123');
      when(() => mockUser.email).thenReturn(email);
      when(() => mockUser.emailVerified).thenReturn(true);
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockAuth.signInWithEmailAndPassword(
          email: email,
          password: password)).thenAnswer((_) async => mockUserCredential);

      final result = await datasource.login(email, password);

      expect(result, isA<UserEntity>());
      expect(result?.uid, '123');
      expect(result?.email, email);
      verify(() => mockAuth.signInWithEmailAndPassword(
          email: email, password: password)).called(1);
    });

    test('should throw FirebaseAuthException when email is not verified',
        () async {
      when(() => mockUser.emailVerified).thenReturn(false);
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockAuth.signInWithEmailAndPassword(
          email: email,
          password: password)).thenAnswer((_) async => mockUserCredential);
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      expect(
        () => datasource.login(email, password),
        throwsA(predicate((e) =>
            e is FirebaseAuthException && e.code == 'email-not-verified')),
      );
    });

    test('should rethrow FirebaseAuthException on login failure', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      expect(
        () => datasource.login(email, password),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('should handle null user in credentials', () async {
      when(() => mockUserCredential.user).thenReturn(null);
      when(() => mockAuth.signInWithEmailAndPassword(
          email: email,
          password: password)).thenAnswer((_) async => mockUserCredential);

      expect(
        () => datasource.login(email, password),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('register', () {
    const email = 'test@test.com';
    const password = 'password123';

    test('should return UserEntity when registration is successful', () async {
      when(() => mockUser.uid).thenReturn('123');
      when(() => mockUser.email).thenReturn(email);
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockAuth.createUserWithEmailAndPassword(
          email: email,
          password: password)).thenAnswer((_) async => mockUserCredential);

      final result = await datasource.register(email, password);

      expect(result, isA<UserEntity>());
      expect(result?.uid, '123');
      expect(result?.email, email);
    });

    test('should rethrow FirebaseAuthException on registration failure',
        () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      expect(
        () => datasource.register(email, password),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('should handle weak password error', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .thenThrow(FirebaseAuthException(code: 'weak-password'));

      expect(
        () => datasource.register(email, password),
        throwsA(predicate(
            (e) => e is FirebaseAuthException && e.code == 'weak-password')),
      );
    });
  });

  group('signInWithGoogle', () {
    test('should return UserEntity when Google sign-in is successful',
        () async {
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();

      when(() => mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleUser);
      when(() => mockGoogleUser.authentication)
          .thenAnswer((_) async => mockGoogleAuth);
      when(() => mockGoogleAuth.accessToken).thenReturn('accessToken');
      when(() => mockGoogleAuth.idToken).thenReturn('idToken');
      when(() => mockAuth.signInWithCredential(any()))
          .thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('123');
      when(() => mockUser.email).thenReturn('test@gmail.com');

      final result = await datasource.signInWithGoogle();

      expect(result, isA<UserEntity>());
      expect(result?.uid, '123');
      verify(() => mockGoogleSignIn.signIn()).called(1);
    });

    test('should return null when user cancels Google sign-in', () async {
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      final result = await datasource.signInWithGoogle();

      expect(result, isNull);
    });

    test('should rethrow exception on Google sign-in failure', () async {
      when(() => mockGoogleSignIn.signIn())
          .thenThrow(Exception('Google sign-in failed'));

      expect(
        () => datasource.signInWithGoogle(),
        throwsException,
      );
    });
  });

  group('logout', () {
    test('should call signOut on both FirebaseAuth and GoogleSignIn', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

      await datasource.logout();

      verify(() => mockAuth.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });

    test('should rethrow exception on logout failure', () async {
      when(() => mockAuth.signOut()).thenThrow(Exception('Logout failed'));
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

      expect(
        () => datasource.logout(),
        throwsException,
      );
    });
  });

  group('getCurrentUser', () {
    test('should return UserEntity when user is logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('123');
      when(() => mockUser.email).thenReturn('test@test.com');

      final result = await datasource.getCurrentUser();

      expect(result, isA<UserEntity>());
      expect(result?.uid, '123');
    });

    test('should return null when no user is logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await datasource.getCurrentUser();

      expect(result, isNull);
    });

    test('should return null on error', () async {
      when(() => mockAuth.currentUser).thenThrow(Exception('Error'));

      final result = await datasource.getCurrentUser();

      expect(result, isNull);
    });
  });
}
