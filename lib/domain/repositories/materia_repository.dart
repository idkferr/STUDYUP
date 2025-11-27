// filepath: lib/domain/repositories/materia_repository.dart
import '../entities/materia_entity.dart';

abstract class MateriaRepository {
  // Crear una nueva materia
  Future<MateriaEntity> crearMateria(MateriaEntity materia);

  // Obtener todas las materias de un usuario
  Future<List<MateriaEntity>> obtenerMaterias(String userId);

  // Obtener una materia por ID
  Future<MateriaEntity?> obtenerMateriaPorId(String id);

  // Actualizar una materia existente
  Future<void> actualizarMateria(MateriaEntity materia);

  // Eliminar una materia
  Future<void> eliminarMateria(String id);

  // Verificar si un código ya existe para un usuario
  Future<bool> existeCodigo(String userId, String codigo, {String? excludeId});

  // Stream en tiempo real de materias
  Stream<List<MateriaEntity>> streamMaterias(String userId);
}
