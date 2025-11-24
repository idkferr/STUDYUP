import '../entities/calificacion_entity.dart';

abstract class CalificacionRepository {
  // Obtener todas las calificaciones de un usuario
  Future<List<CalificacionEntity>> getCalificaciones(String userId);

  // Obtener una calificación por ID
  Future<CalificacionEntity?> getCalificacionById(String id);

  // Crear una nueva calificación
  Future<CalificacionEntity> createCalificacion(
      CalificacionEntity calificacion);

  // Actualizar una calificación existente
  Future<void> updateCalificacion(CalificacionEntity calificacion);

  // Eliminar una calificación
  Future<void> deleteCalificacion(String id);

  // Obtener calificaciones por materia
  Future<List<CalificacionEntity>> getCalificacionesByMateria(
    String userId,
    String materia,
  );

  // Stream de calificaciones en tiempo real
  Stream<List<CalificacionEntity>> calificacionesStream(String userId);

  // Stream de calificaciones por materia en tiempo real
  Stream<List<CalificacionEntity>> calificacionesByMateriaStream(
      String userId, String materiaId);
}
