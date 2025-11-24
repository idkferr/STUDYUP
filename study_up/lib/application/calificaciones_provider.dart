import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/calificacion_entity.dart';
import '../domain/repositories/calificacion_repository.dart';
import '../infrastructure/datasources/firestore_calificacion_datasource.dart';
import '../infrastructure/repositories/calificacion_repository_impl.dart';

// Provider del repositorio
final calificacionRepositoryProvider = Provider<CalificacionRepository>((ref) {
  return CalificacionRepositoryImpl(FirestoreCalificacionDatasource());
});

// StateNotifier para gestión de estado de calificaciones
class CalificacionesNotifier
    extends StateNotifier<AsyncValue<List<CalificacionEntity>>> {
  final CalificacionRepository _repository;
  final String userId;

  CalificacionesNotifier(this._repository, this.userId)
      : super(const AsyncValue.loading()) {
    _cargarCalificaciones();
  }

  Future<void> _cargarCalificaciones() async {
    state = const AsyncValue.loading();
    try {
      final calificaciones = await _repository.getCalificaciones(userId);
      state = AsyncValue.data(calificaciones);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> crearCalificacion(CalificacionEntity calificacion) async {
    try {
      await _repository.createCalificacion(calificacion);
      await _cargarCalificaciones();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> actualizarCalificacion(CalificacionEntity calificacion) async {
    try {
      await _repository.updateCalificacion(calificacion);
      await _cargarCalificaciones();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminarCalificacion(String id) async {
    try {
      await _repository.deleteCalificacion(id);
      await _cargarCalificaciones();
    } catch (e) {
      rethrow;
    }
  }

  void refrescar() {
    _cargarCalificaciones();
  }
}

// Provider del StateNotifier por usuario
final calificacionesNotifierProvider = StateNotifierProvider.family<
    CalificacionesNotifier,
    AsyncValue<List<CalificacionEntity>>,
    String>((ref, userId) {
  final repository = ref.watch(calificacionRepositoryProvider);
  return CalificacionesNotifier(repository, userId);
});

final calificacionesStreamProvider =
    StreamProvider.family<List<CalificacionEntity>, String>((ref, userId) {
  final repo = ref.watch(calificacionRepositoryProvider);
  return repo.calificacionesStream(userId);
});

final calificacionesPorMateriaStreamProvider = StreamProvider.family<
    List<CalificacionEntity>, (String userId, String materiaId)>((ref, tuple) {
  final repo = ref.watch(calificacionRepositoryProvider);
  return repo.calificacionesByMateriaStream(tuple.$1, tuple.$2);
});
