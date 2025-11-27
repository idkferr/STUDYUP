// filepath: lib/infrastructure/datasources/firestore_horario_item_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/horario_item_entity.dart';

class FirestoreHorarioItemDataSource {
  final FirebaseFirestore _firestore;
  final _collection = 'horarioItems';

  FirestoreHorarioItemDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<HorarioItemEntity> crear(HorarioItemEntity item) async {
    final doc = await _firestore.collection(_collection).add(item.toMap());
    return item.copyWith(id: doc.id);
  }

  Future<void> actualizar(HorarioItemEntity item) async {
    if (item.id == null) throw Exception('ID requerido para actualizar');
    await _firestore.collection(_collection).doc(item.id).update(item.toMap());
  }

  Future<void> eliminar(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Stream<List<HorarioItemEntity>> streamPorUsuario(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('inicio')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => HorarioItemEntity.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<HorarioItemEntity>> streamPorMateria(
      String userId, String materiaId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('materiaId', isEqualTo: materiaId)
        .orderBy('inicio')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => HorarioItemEntity.fromMap(d.data(), d.id))
            .toList());
  }
}
