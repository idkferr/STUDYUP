import '../../domain/entities/calificacion_entity.dart';
import '../../domain/repositories/calificacion_repository.dart';
import '../datasources/firestore_calificacion_datasource.dart';

class CalificacionRepositoryImpl implements CalificacionRepository {
  final FirestoreCalificacionDatasource datasource;

  CalificacionRepositoryImpl(this.datasource);

  @override
  Future<List<CalificacionEntity>> getCalificaciones(String userId) {
    return datasource.getCalificaciones(userId);
  }

  @override
  Future<CalificacionEntity?> getCalificacionById(String id) {
    return datasource.getCalificacionById(id);
  }

  @override
  Future<CalificacionEntity> createCalificacion(
      CalificacionEntity calificacion) {
    return datasource.createCalificacion(calificacion);
  }

  @override
  Future<void> updateCalificacion(CalificacionEntity calificacion) {
    return datasource.updateCalificacion(calificacion);
  }

  @override
  Future<void> deleteCalificacion(String id) {
    return datasource.deleteCalificacion(id);
  }

  @override
  Future<List<CalificacionEntity>> getCalificacionesByMateria(
    String userId,
    String materia,
  ) {
    return datasource.getCalificacionesByMateria(userId, materia);
  }

  @override
  Stream<List<CalificacionEntity>> calificacionesStream(String userId) {
    return datasource.calificacionesStream(userId);
  }

  @override
  Stream<List<CalificacionEntity>> calificacionesByMateriaStream(
      String userId, String materiaId) {
    return datasource.calificacionesByMateriaStream(userId, materiaId);
  }
}
