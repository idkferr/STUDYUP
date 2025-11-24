// filepath: lib/infrastructure/repositories/materia_repository_impl.dart
import '../../domain/entities/materia_entity.dart';
import '../../domain/repositories/materia_repository.dart';
import '../datasources/firestore_materia_datasource.dart';

class MateriaRepositoryImpl implements MateriaRepository {
  final FirestoreMateriaDataSource _dataSource;

  MateriaRepositoryImpl(this._dataSource);

  @override
  Future<MateriaEntity> crearMateria(MateriaEntity materia) async {
    return await _dataSource.crearMateria(materia);
  }

  @override
  Future<List<MateriaEntity>> obtenerMaterias(String userId) async {
    return await _dataSource.obtenerMaterias(userId);
  }

  @override
  Future<MateriaEntity?> obtenerMateriaPorId(String id) async {
    return await _dataSource.obtenerMateriaPorId(id);
  }

  @override
  Future<void> actualizarMateria(MateriaEntity materia) async {
    await _dataSource.actualizarMateria(materia);
  }

  @override
  Future<void> eliminarMateria(String id) async {
    await _dataSource.eliminarMateria(id);
  }

  @override
  Future<bool> existeCodigo(String userId, String codigo,
      {String? excludeId}) async {
    return await _dataSource.existeCodigo(userId, codigo, excludeId: excludeId);
  }

  @override
  Stream<List<MateriaEntity>> streamMaterias(String userId) {
    return _dataSource.streamMaterias(userId);
  }
}
