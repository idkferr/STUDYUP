// filepath: lib/application/materias_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../domain/entities/materia_entity.dart';
import '../domain/repositories/materia_repository.dart';
import '../infrastructure/datasources/firestore_materia_datasource.dart';
import '../infrastructure/repositories/materia_repository_impl.dart';

// Provider del repositorio
final materiaRepositoryProvider = Provider<MateriaRepository>((ref) {
  return MateriaRepositoryImpl(FirestoreMateriaDataSource());
});

// Provider para obtener una materia por ID
final materiaByIdProvider = FutureProvider.family<MateriaEntity?, String>(
  (ref, materiaId) async {
    final repository = ref.watch(materiaRepositoryProvider);
    return await repository.obtenerMateriaPorId(materiaId);
  },
);

// StreamProvider para materias
final materiasStreamProvider =
    StreamProvider.family<List<MateriaEntity>, String>((ref, userId) {
  final repository = ref.watch(materiaRepositoryProvider);
  return repository.streamMaterias(userId);
});

// StateNotifier para gestión de estado de materias
class MateriasNotifier extends StateNotifier<AsyncValue<List<MateriaEntity>>> {
  final MateriaRepository _repository;
  final String userId;
  StreamSubscription<List<MateriaEntity>>? _subscription;

  MateriasNotifier(this._repository, this.userId)
      : super(const AsyncValue.loading()) {
    _escucharMaterias();
  }

  void _escucharMaterias() {
    _subscription?.cancel();
    state = const AsyncValue.loading();
    _subscription = _repository.streamMaterias(userId).listen((materias) {
      state = AsyncValue.data(materias);
    }, onError: (e, stack) {
      state = AsyncValue.error(e, stack);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<MateriaEntity> crearMateria(MateriaEntity materia) async {
    final created = await _repository.crearMateria(materia);
    return created;
  }

  Future<void> actualizarMateria(MateriaEntity materia) async {
    await _repository.actualizarMateria(materia);
  }

  Future<void> eliminarMateria(String id) async {
    await _repository.eliminarMateria(id);
  }

  Future<bool> existeCodigo(String codigo, {String? excludeId}) async {
    return await _repository.existeCodigo(userId, codigo, excludeId: excludeId);
  }
}

// Provider del StateNotifier
final materiasNotifierProvider = StateNotifierProvider.family<MateriasNotifier,
    AsyncValue<List<MateriaEntity>>, String>(
  (ref, userId) {
    final repository = ref.watch(materiaRepositoryProvider);
    return MateriasNotifier(repository, userId);
  },
);
