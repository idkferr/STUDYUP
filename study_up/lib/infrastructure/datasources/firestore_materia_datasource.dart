// filepath: lib/infrastructure/datasources/firestore_materia_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/materia_entity.dart';

class FirestoreMateriaDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'materias';

  // Crear nueva materia
  Future<MateriaEntity> crearMateria(MateriaEntity materia) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(materia.toMap());
      print('[Materia][CREATE] id=${docRef.id} data=${materia.toMap()}');
      return materia.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Error al crear materia: $e');
    }
  }

  // Obtener todas las materias de un usuario
  Future<List<MateriaEntity>> obtenerMaterias(String userId) async {
    try {
      // DEBUG: inicio de fetch
      print('[Materias] Fetch inicial para userId=$userId');
      final query =
          _firestore.collection(_collection).where('userId', isEqualTo: userId);
      // NOTE: Se quitó orderBy('semestre') para evitar índice compuesto que provoca error silencioso en web.
      final snapshot = await query.get();
      print('[Materias] Docs obtenidos: ${snapshot.docs.length}');
      return snapshot.docs
          .map((doc) => MateriaEntity.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('[Materias][ERROR] obtenerMaterias: $e');
      throw Exception('Error al obtener materias: $e');
    }
  }

  // Stream en tiempo real de materias de un usuario
  Stream<List<MateriaEntity>> streamMaterias(String userId) {
    print('[Materias] Iniciando stream para userId=$userId');
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        // .orderBy('semestre', descending: true) // Quitado para evitar índice compuesto
        .snapshots()
        .map((snapshot) {
      print('[Materias] Snapshot stream docs=${snapshot.docs.length}');
      return snapshot.docs
          .map((doc) => MateriaEntity.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Obtener materia por ID
  Future<MateriaEntity?> obtenerMateriaPorId(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return MateriaEntity.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error al obtener materia: $e');
    }
  }

  // Actualizar materia
  Future<void> actualizarMateria(MateriaEntity materia) async {
    try {
      if (materia.id == null) {
        throw Exception('La materia debe tener un ID para actualizarse');
      }
      await _firestore
          .collection(_collection)
          .doc(materia.id)
          .update(materia.toMap());
      print('[Materia][UPDATE] id=${materia.id} data=${materia.toMap()}');
    } catch (e) {
      throw Exception('Error al actualizar materia: $e');
    }
  }

  // Eliminar materia
  Future<void> eliminarMateria(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      print('[Materia][DELETE] id=$id');
    } catch (e) {
      throw Exception('Error al eliminar materia: $e');
    }
  }

  // Verificar si un código ya existe para un usuario
  Future<bool> existeCodigo(String userId, String codigo,
      {String? excludeId}) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('codigo', isEqualTo: codigo);

      final snapshot = await query.get();

      if (excludeId != null) {
        // Excluir el documento actual (para ediciones)
        return snapshot.docs.any((doc) => doc.id != excludeId);
      }

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error al verificar código: $e');
    }
  }
}
