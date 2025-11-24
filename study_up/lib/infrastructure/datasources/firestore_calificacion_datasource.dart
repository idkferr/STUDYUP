import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/calificacion_entity.dart';

class FirestoreCalificacionDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'calificaciones';

  // Obtener todas las calificaciones de un usuario
  Future<List<CalificacionEntity>> getCalificaciones(String userId) async {
    try {
      final query = _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('fecha', descending: true);
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CalificacionEntity.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        print(
            '[Calificaciones][INDEX_MISSING] Crear índice compuesto userId ASC, fecha DESC. Fallback sin orderBy. Msg: ${e.message}');
        final snapshot = await _firestore
            .collection(_collectionName)
            .where('userId', isEqualTo: userId)
            .get();
        return snapshot.docs
            .map((doc) => CalificacionEntity.fromMap(doc.data(), doc.id))
            .toList();
      }
      rethrow;
    } catch (e) {
      print("❌ Error al obtener calificaciones: $e");
      rethrow;
    }
  }

  // Obtener una calificación por ID
  Future<CalificacionEntity?> getCalificacionById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();

      if (!doc.exists) return null;

      return CalificacionEntity.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print("❌ Error al obtener calificación por ID: $e");
      rethrow;
    }
  }

  // Crear una nueva calificación
  Future<CalificacionEntity> createCalificacion(
      CalificacionEntity calificacion) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(calificacion.toMap());
      print(
          '[Calificacion][CREATE] id=${docRef.id} data=${calificacion.toMap()}');
      return calificacion.copyWith(id: docRef.id);
    } catch (e) {
      print("❌ Error al crear calificación: $e");
      rethrow;
    }
  }

  // Actualizar una calificación existente
  Future<void> updateCalificacion(CalificacionEntity calificacion) async {
    try {
      if (calificacion.id == null) {
        throw Exception('No se puede actualizar una calificación sin ID');
      }

      await _firestore
          .collection(_collectionName)
          .doc(calificacion.id)
          .update(calificacion.toMap());
      print(
          '[Calificacion][UPDATE] id=${calificacion.id} data=${calificacion.toMap()}');
    } catch (e) {
      print("❌ Error al actualizar calificación: $e");
      rethrow;
    }
  }

  // Eliminar una calificación
  Future<void> deleteCalificacion(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      print('[Calificacion][DELETE] id=$id');
    } catch (e) {
      print("❌ Error al eliminar calificación: $e");
      rethrow;
    }
  }

  // Obtener calificaciones por materia
  Future<List<CalificacionEntity>> getCalificacionesByMateria(
    String userId,
    String materia,
  ) async {
    try {
      final query = _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('materia', isEqualTo: materia)
          .orderBy('fecha', descending: true);
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CalificacionEntity.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        print(
            '[Calificaciones][INDEX_MISSING] (materia) Crear índice userId+materiaId/fecha. Fallback sin orderBy. Msg: ${e.message}');
        final snapshot = await _firestore
            .collection(_collectionName)
            .where('userId', isEqualTo: userId)
            .where('materia', isEqualTo: materia)
            .get();
        return snapshot.docs
            .map((doc) => CalificacionEntity.fromMap(doc.data(), doc.id))
            .toList();
      }
      rethrow;
    } catch (e) {
      print("❌ Error al obtener calificaciones por materia: $e");
      rethrow;
    }
  }

  // Stream de calificaciones en tiempo real
  Stream<List<CalificacionEntity>> calificacionesStream(String userId) {
    final baseQuery = _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId);
    final orderedQuery = baseQuery.orderBy('fecha', descending: true);
    return orderedQuery.snapshots().handleError((e) {
      if (e is FirebaseException && e.code == 'failed-precondition') {
        print('[Calificaciones][INDEX_MISSING][STREAM] Fallback sin orderBy');
      }
    }).map((snapshot) => snapshot.docs
        .map((doc) => CalificacionEntity.fromMap(doc.data(), doc.id))
        .toList());
  }

  Stream<List<CalificacionEntity>> calificacionesByMateriaStream(
      String userId, String materiaId) {
    final baseQuery = _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('materiaId', isEqualTo: materiaId);
    final orderedQuery = baseQuery.orderBy('fecha', descending: true);
    return orderedQuery.snapshots().handleError((e) {
      if (e is FirebaseException && e.code == 'failed-precondition') {
        print(
            '[Calificaciones][INDEX_MISSING][STREAM_BY_MATERIA] Fallback sin orderBy');
      }
    }).map((snapshot) => snapshot.docs
        .map((doc) => CalificacionEntity.fromMap(doc.data(), doc.id))
        .toList());
  }
}
