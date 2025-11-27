import 'dart:ui';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_up/domain/entities/horario_item_entity.dart';
import 'package:study_up/infrastructure/datasources/firestore_horario_item_datasource.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreHorarioItemDataSource dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = FirestoreHorarioItemDataSource(firestore: fakeFirestore);
  });

  group('FirestoreHorarioItemDataSource', () {
    final testItem = HorarioItemEntity(
      id: null,
      userId: 'user123',
      materiaId: 'materia123',
      inicio: DateTime(2024, 1, 1, 10, 0),
      fin: DateTime(2024, 1, 1, 11, 0),
      titulo: 'Titulo',
      tipo: 'Prueba',
      color: const Color(0xFF2196F3),
    );

    test('crear - should create item and return with id', () async {
      final result = await dataSource.crear(testItem);

      expect(result.id, isNotNull);
      expect(result.userId, 'user123');
      expect(result.materiaId, 'materia123');
    });

    test('actualizar - should update item when id is present', () async {
      final created = await dataSource.crear(testItem);
      final updated = created.copyWith(titulo: "Nuevo Titulo");

      await dataSource.actualizar(updated);

      final doc =
          await fakeFirestore.collection('horarioItems').doc(created.id).get();
      expect(doc.data()?['titulo'], 'Nuevo Titulo');
    });

    test('actualizar - should throw exception when id is null', () async {
      expect(
        () => dataSource.actualizar(testItem),
        throwsException,
      );
    });

    test('eliminar - should delete document by id', () async {
      final created = await dataSource.crear(testItem);

      await dataSource.eliminar(created.id!);

      final doc =
          await fakeFirestore.collection('horarioItems').doc(created.id).get();
      expect(doc.exists, false);
    });

    test('streamPorUsuario - should return stream of items for user', () async {
      await dataSource.crear(testItem);
      await dataSource.crear(testItem.copyWith(userId: 'other'));

      final stream = dataSource.streamPorUsuario('user123');
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.userId, 'user123');
    });

    test(
        'streamPorMateria - should return stream of items for user and materia',
        () async {
      await dataSource.crear(testItem);
      await dataSource.crear(testItem.copyWith(materiaId: 'other'));

      final stream = dataSource.streamPorMateria('user123', 'materia123');
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.userId, 'user123');
      expect(result.first.materiaId, 'materia123');
    });
  });
}
