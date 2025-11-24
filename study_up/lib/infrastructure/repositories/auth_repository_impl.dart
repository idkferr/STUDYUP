import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<UserEntity?> login(String email, String password) {
    return datasource.login(email, password);
  }

  @override
  Future<UserEntity?> register(String email, String password) {
    return datasource.register(email, password);
  }

  @override
  Future<UserEntity?> signInWithGoogle() {
    return datasource.signInWithGoogle();
  }

  @override
  Future<void> logout() {
    return datasource.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return datasource.getCurrentUser();
  }
}
