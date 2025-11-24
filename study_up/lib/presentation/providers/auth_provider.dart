import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provider global de FirebaseAuth
final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

/// Estado del usuario actual
final authStateProvider = StreamProvider<User?>(
  (ref) {
    final auth = ref.watch(firebaseAuthProvider);
    return auth.authStateChanges();
  },
);

/// Provider para las acciones de autenticación
final authActionsProvider = Provider<AuthActions>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthActions(auth);
});

class AuthActions {
  final FirebaseAuth _auth;
  AuthActions(this._auth);

  /// LOGIN
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // éxito
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// REGISTRO
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // éxito
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
