import 'dart:ui';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_up/domain/entities/materia_entity.dart';
import 'package:study_up/infrastructure/datasources/firestore_materia_datasource.dart';

void main() {
  late FirestoreMateriaDataSource dataSource;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = FirestoreMateriaDataSource(fakeFirestore);
  });

  group('FirestoreMateriaDataSource', () {
    final testMateria = MateriaEntity(
      id: null,
      nombre: 'Matemáticas',
      codigo: 'MAT101',
      color: const Color(0xFF2196F3),
      semestre: '2024-1',
      creditos: 4,
      userId: 'user-123',
    );

    group('crearMateria', () {
      test('debe crear materia y retornar con ID asignado', () async {
        final created = await dataSource.crearMateria(testMateria);

        expect(created.id, isNotNull);
        expect(created.nombre, testMateria.nombre);
        expect(created.codigo, testMateria.codigo);
        expect(created.creditos, testMateria.creditos);
      });
    });

    group('obtenerMaterias', () {
      test('debe retornar lista de materias para un usuario', () async {
        // Setup: Create test data
        await fakeFirestore.collection('materias').add({
          'nombre': 'Física',
          'codigo': 'FIS101',
          'color': 0xFF4CAF50,
          'semestre': '2024-1',
          'creditos': 3,
          'userId': 'user-123',
          'activo': true,
        });

        final materias = await dataSource.obtenerMaterias('user-123');

        expect(materias.length, 1);
        expect(materias.first.nombre, 'Física');
        expect(materias.first.creditos, 3);
      });

      test('debe retornar lista vacía cuando no hay materias', () async {
        final materias = await dataSource.obtenerMaterias('user-456');

        expect(materias, isEmpty);
      });
    });

    group('streamMaterias', () {
      test('debe emitir lista de materias en tiempo real', () async {
        await fakeFirestore.collection('materias').add({
          'nombre': 'Química',
          'codigo': 'QUI101',
          'color': 0xFFFF9800,
          'semestre': '2024-1',
          'creditos': 5,
          'userId': 'user-123',
          'activo': true,
        });

        final stream = dataSource.streamMaterias('user-123');
        final materias = await stream.first;

        expect(materias.length, 1);
        expect(materias.first.nombre, 'Química');
      });
    });

    group('obtenerMateriaPorId', () {
      test('debe retornar materia cuando existe', () async {
        final docRef = await fakeFirestore.collection('materias').add({
          'nombre': 'Historia',
          'codigo': 'HIS101',
          'color': 0xFF9C27B0,
          'semestre': '2024-1',
          'creditos': 2,
          'userId': 'user-123',
          'activo': true,
        });

        final materia = await dataSource.obtenerMateriaPorId(docRef.id);

        expect(materia, isNotNull);
        expect(materia!.nombre, 'Historia');
        expect(materia.id, docRef.id);
      });

      test('debe retornar null cuando no existe', () async {
        final materia = await dataSource.obtenerMateriaPorId('non-existent-id');

        expect(materia, isNull);
      });
    });

    group('actualizarMateria', () {
      test('debe actualizar materia correctamente', () async {
        final created = await dataSource.crearMateria(testMateria);
        final updated =
            created.copyWith(nombre: 'Matemáticas Avanzadas', creditos: 6);

        await dataSource.actualizarMateria(updated);

        final materia = await dataSource.obtenerMateriaPorId(created.id!);
        expect(materia!.nombre, 'Matemáticas Avanzadas');
        expect(materia.creditos, 6);
      });
    });

    group('eliminarMateria', () {
      test('debe eliminar materia por ID', () async {
        final created = await dataSource.crearMateria(testMateria);

        await dataSource.eliminarMateria(created.id!);

        final materia = await dataSource.obtenerMateriaPorId(created.id!);
        expect(materia, isNull);
      });
    });

    group('existeCodigo', () {
      test('debe retornar true cuando código existe para el usuario', () async {
        await dataSource.crearMateria(testMateria);

        final exists = await dataSource.existeCodigo('user-123', 'MAT101');

        expect(exists, isTrue);
      });

      test('debe retornar false cuando código no existe', () async {
        final exists = await dataSource.existeCodigo('user-123', 'NONEXISTENT');

        expect(exists, isFalse);
      });

      test('debe excluir ID actual en ediciones', () async {
        final created = await dataSource.crearMateria(testMateria);

        final exists = await dataSource.existeCodigo(
          'user-123',
          'MAT101',
          excludeId: created.id,
        );

        expect(exists, isFalse);
      });
    });
  });
}
