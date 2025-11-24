// filepath: lib/application/horario_items_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/horario_item_entity.dart';
import '../domain/repositories/horario_item_repository.dart';
import '../infrastructure/datasources/firestore_horario_item_datasource.dart';
import '../infrastructure/repositories/horario_item_repository_impl.dart';

final horarioItemRepositoryProvider = Provider<HorarioItemRepository>((ref) {
  return HorarioItemRepositoryImpl(FirestoreHorarioItemDataSource());
});

final horarioItemsStreamProvider =
    StreamProvider.family<List<HorarioItemEntity>, String>((ref, userId) {
  final repo = ref.watch(horarioItemRepositoryProvider);
  return repo.streamUsuario(userId);
});

final horarioItemsPorMateriaStreamProvider = StreamProvider.family<
    List<HorarioItemEntity>, (String userId, String materiaId)>((ref, tuple) {
  final repo = ref.watch(horarioItemRepositoryProvider);
  return repo.streamMateria(tuple.$1, tuple.$2);
});

class HorarioItemsNotifier
    extends StateNotifier<AsyncValue<List<HorarioItemEntity>>> {
  final HorarioItemRepository _repo;
  final String userId;
  HorarioItemsNotifier(this._repo, this.userId)
      : super(const AsyncValue.loading()) {
    _listen();
  }
  void _listen() {
    _repo.streamUsuario(userId).listen((data) => state = AsyncValue.data(data),
        onError: (e, st) => state = AsyncValue.error(e, st));
  }

  Future<void> crear(HorarioItemEntity item) async => _repo.crear(item);
  Future<void> actualizar(HorarioItemEntity item) async =>
      _repo.actualizar(item);
  Future<void> eliminar(String id) async => _repo.eliminar(id);
}

final horarioItemsNotifierProvider = StateNotifierProvider.family<
    HorarioItemsNotifier,
    AsyncValue<List<HorarioItemEntity>>,
    String>((ref, userId) {
  final repo = ref.watch(horarioItemRepositoryProvider);
  return HorarioItemsNotifier(repo, userId);
});
