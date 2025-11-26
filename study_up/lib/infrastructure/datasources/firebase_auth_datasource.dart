import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  /// Creates a new FirebaseAuthDatasource.
  /// 
  /// [auth] - The FirebaseAuth instance to use. Defaults to FirebaseAuth.instance.
  /// [googleSignIn] - The GoogleSignIn instance to use. Defaults to a new GoogleSignIn instance.
  FirebaseAuthDatasource({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  UserEntity? _mapUser(User? user) {
    if (user == null) return null;
    return UserEntity(uid: user.uid, email: user.email ?? "");
  }

  Future<UserEntity?> login(String email, String password) async {
    try {
      final creds = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Verificar si el correo está verificado
      if (!creds.user!.emailVerified) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Debes verificar tu correo antes de iniciar sesión.',
        );
      }
      return _mapUser(creds.user);
    } catch (e) {
      print("❌ Firebase Auth Login Error: $e");
      rethrow;
    }
  }

  Future<UserEntity?> register(String email, String password) async {
    try {
      final creds = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapUser(creds.user);
    } catch (e) {
      print("❌ Firebase Auth Register Error: $e");
      rethrow;
    }
  }

  Future<UserEntity?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      return _mapUser(userCredential.user);
    } catch (e) {
      print("❌ Firebase Auth Google Sign-In Error: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(), // Also sign out from Google
      ]);
    } catch (e) {
      print("❌ Firebase Auth Logout Error: $e");
      rethrow;
    }
  }

  Future<UserEntity?> getCurrentUser() async {
    try {
      return _mapUser(_auth.currentUser);
    } catch (e) {
      print("❌ Firebase Auth Get Current User Error: $e");
      return null;
    }
  }
}
