// filepath: lib/infrastructure/repositories/horario_item_repository_impl.dart
import '../../domain/entities/horario_item_entity.dart';
import '../../domain/repositories/horario_item_repository.dart';
import '../datasources/firestore_horario_item_datasource.dart';

class HorarioItemRepositoryImpl implements HorarioItemRepository {
  final FirestoreHorarioItemDataSource datasource;
  HorarioItemRepositoryImpl(this.datasource);

  @override
  Future<HorarioItemEntity> crear(HorarioItemEntity item) =>
      datasource.crear(item);

  @override
  Future<void> actualizar(HorarioItemEntity item) =>
      datasource.actualizar(item);

  @override
  Future<void> eliminar(String id) => datasource.eliminar(id);

  @override
  Stream<List<HorarioItemEntity>> streamUsuario(String userId) =>
      datasource.streamPorUsuario(userId);

  @override
  Stream<List<HorarioItemEntity>> streamMateria(
          String userId, String materiaId) =>
      datasource.streamPorMateria(userId, materiaId);
}
