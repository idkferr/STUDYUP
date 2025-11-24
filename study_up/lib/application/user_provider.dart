import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/auth_repository.dart';
import '../infrastructure/datasources/firebase_auth_datasource.dart';
import '../infrastructure/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(FirebaseAuthDatasource());
});

final userProvider = StateNotifierProvider<UserNotifier, UserEntity?>((ref) {
  return UserNotifier(ref.read(authRepositoryProvider));
});

class UserNotifier extends StateNotifier<UserEntity?> {
  final AuthRepository repository;

  UserNotifier(this.repository) : super(null) {
    _checkInitialUser();
  }
  Future<void> _checkInitialUser() async {
    try {
      // Check if user is already logged in
      final currentUser = await repository.getCurrentUser();
      if (currentUser != null) {
        state = currentUser;
      }
    } catch (e) {
      print("❌ Error checking initial user: $e");
    }
  }

  Future<bool> login(String email, String password) async {
    final user = await repository.login(email, password);
    state = user;
    return user != null;
  }

  Future<bool> register(String email, String password) async {
    final user = await repository.register(email, password);
    state = user;
    return user != null;
  }

  Future<bool> signInWithGoogle() async {
    final user = await repository.signInWithGoogle();
    state = user;
    return user != null;
  }

  Future<void> logout() async {
    try {
      await repository.logout();
      state = null;
    } catch (e) {
      print("❌ Error en logout: $e");
    }
  }
}
