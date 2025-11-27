// filepath: lib/domain/repositories/horario_item_repository.dart
import '../entities/horario_item_entity.dart';

abstract class HorarioItemRepository {
  Future<HorarioItemEntity> crear(HorarioItemEntity item);
  Future<void> actualizar(HorarioItemEntity item);
  Future<void> eliminar(String id);
  Stream<List<HorarioItemEntity>> streamUsuario(String userId);
  Stream<List<HorarioItemEntity>> streamMateria(
      String userId, String materiaId);
}
