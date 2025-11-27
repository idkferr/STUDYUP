import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study_up/domain/entities/horario_item_entity.dart';
import 'package:study_up/domain/repositories/horario_item_repository.dart';

class MockHorarioItemRepository extends Mock implements HorarioItemRepository {}

class FakeHorarioItemEntity extends Fake implements HorarioItemEntity {}

void main() {
  late MockHorarioItemRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeHorarioItemEntity());
  });

  setUp(() {
    mockRepository = MockHorarioItemRepository();
  });

  group('HorarioItemRepository', () {
    final testItem = HorarioItemEntity(
      id: '1',
      userId: 'user123',
      materiaId: 'materia456',
      titulo: 'Examen Final',
      tipo: 'prueba',
      inicio: DateTime(2024, 1, 15, 8, 0),
      fin: DateTime(2024, 1, 15, 10, 0),
      recordatorioMinutosAntes: 30,
      descripcion: 'Estudiar capítulos 1-5',
      color: Colors.blue,
    );

    test('crear should return created HorarioItemEntity', () async {
      when(() => mockRepository.crear(any())).thenAnswer((_) async => testItem);

      final result = await mockRepository.crear(testItem);

      expect(result.id, testItem.id);
      expect(result.userId, testItem.userId);
      expect(result.titulo, testItem.titulo);
      verify(() => mockRepository.crear(testItem)).called(1);
    });

    test('crear should handle item without materiaId', () async {
      final itemSinMateria = HorarioItemEntity(
        id: '2',
        userId: 'user123',
        materiaId: null,
        titulo: 'Evento General',
        tipo: 'otro',
        inicio: DateTime(2024, 1, 15, 8, 0),
        color: Colors.blue,
      );

      when(() => mockRepository.crear(any()))
          .thenAnswer((_) async => itemSinMateria);

      final result = await mockRepository.crear(itemSinMateria);

      expect(result.materiaId, isNull);
      verify(() => mockRepository.crear(itemSinMateria)).called(1);
    });

    test('crear should handle item without recordatorio', () async {
      final itemSinRecordatorio = HorarioItemEntity(
        id: '3',
        userId: 'user123',
        materiaId: 'materia456',
        titulo: 'Sin recordatorio',
        tipo: 'tarea',
        inicio: DateTime(2024, 1, 15, 8, 0),
        recordatorioMinutosAntes: null,
        color: Colors.blue,
      );

      when(() => mockRepository.crear(any()))
          .thenAnswer((_) async => itemSinRecordatorio);

      final result = await mockRepository.crear(itemSinRecordatorio);

      expect(result.recordatorioMinutosAntes, isNull);
    });

    test('crear should handle item without descripcion', () async {
      final itemSinDescripcion = HorarioItemEntity(
        id: '4',
        userId: 'user123',
        materiaId: 'materia456',
        titulo: 'Sin descripción',
        tipo: 'tarea',
        inicio: DateTime(2024, 1, 15, 8, 0),
        descripcion: null,
        color: Colors.blue,
      );

      when(() => mockRepository.crear(any()))
          .thenAnswer((_) async => itemSinDescripcion);

      final result = await mockRepository.crear(itemSinDescripcion);

      expect(result.descripcion, isNull);
    });

    test('crear should handle item without fin', () async {
      final itemSinFin = HorarioItemEntity(
        id: '5',
        userId: 'user123',
        materiaId: 'materia456',
        titulo: 'Sin fecha fin',
        tipo: 'tarea',
        inicio: DateTime(2024, 1, 15, 8, 0),
        fin: null,
        color: Colors.blue,
      );

      when(() => mockRepository.crear(any()))
          .thenAnswer((_) async => itemSinFin);

      final result = await mockRepository.crear(itemSinFin);

      expect(result.fin, isNull);
    });

    test('actualizar should complete successfully', () async {
      when(() => mockRepository.actualizar(any())).thenAnswer((_) async {});

      await mockRepository.actualizar(testItem);

      verify(() => mockRepository.actualizar(testItem)).called(1);
    });

    test('actualizar should throw exception on error', () async {
      when(() => mockRepository.actualizar(any()))
          .thenThrow(Exception('Error updating item'));

      expect(
        () => mockRepository.actualizar(testItem),
        throwsException,
      );
    });

    test('eliminar should complete successfully', () async {
      when(() => mockRepository.eliminar(any())).thenAnswer((_) async {});

      await mockRepository.eliminar('1');

      verify(() => mockRepository.eliminar('1')).called(1);
    });

    test('eliminar should throw exception on error', () async {
      when(() => mockRepository.eliminar(any()))
          .thenThrow(Exception('Error deleting item'));

      expect(
        () => mockRepository.eliminar('1'),
        throwsException,
      );
    });

    test('streamUsuario should emit list of HorarioItemEntity', () {
      final items = [testItem];
      when(() => mockRepository.streamUsuario(any()))
          .thenAnswer((_) => Stream.value(items));

      expect(mockRepository.streamUsuario('user123'), emits(items));
      verify(() => mockRepository.streamUsuario('user123')).called(1);
    });

    test('streamUsuario should emit multiple items', () {
      final items = [
        testItem,
        HorarioItemEntity(
          id: '2',
          userId: 'user123',
          materiaId: 'materia456',
          titulo: 'Tarea 1',
          tipo: 'tarea',
          inicio: DateTime(2024, 1, 16, 8, 0),
          color: Colors.blue,
        ),
      ];
      when(() => mockRepository.streamUsuario(any()))
          .thenAnswer((_) => Stream.value(items));

      expect(mockRepository.streamUsuario('user123'), emits(items));
    });

    test('streamUsuario should emit empty list when no items', () {
      when(() => mockRepository.streamUsuario(any()))
          .thenAnswer((_) => Stream.value([]));

      expect(mockRepository.streamUsuario('user123'), emits([]));
    });

    test('streamUsuario should emit updates over time', () async {
      final controller = StreamController<List<HorarioItemEntity>>();
      when(() => mockRepository.streamUsuario(any()))
          .thenAnswer((_) => controller.stream);

      final stream = mockRepository.streamUsuario('user123');

      final item2 = HorarioItemEntity(
        id: '2',
        userId: 'user123',
        materiaId: 'materia456',
        titulo: 'Item 2',
        tipo: 'tarea',
        inicio: DateTime(2024, 1, 16, 8, 0),
        color: Colors.blue,
      );

      expectLater(
        stream,
        emitsInOrder([
          [testItem],
          [testItem, item2],
        ]),
      );

      controller.add([testItem]);
      await Future.delayed(Duration(milliseconds: 10));
      controller.add([testItem, item2]);
      await Future.delayed(Duration(milliseconds: 10));

      await controller.close();
    });

    test('streamUsuario should emit error when repository fails', () {
      when(() => mockRepository.streamUsuario(any()))
          .thenAnswer((_) => Stream.error(Exception('Stream error')));

      expect(
        mockRepository.streamUsuario('user123'),
        emitsError(isA<Exception>()),
      );
    });

    test('streamMateria should emit list of HorarioItemEntity', () {
      final items = [testItem];
      when(() => mockRepository.streamMateria(any(), any()))
          .thenAnswer((_) => Stream.value(items));

      expect(
        mockRepository.streamMateria('user123', 'materia456'),
        emits(items),
      );
      verify(() => mockRepository.streamMateria('user123', 'materia456'))
          .called(1);
    });

    test('streamMateria should emit empty list when no items', () {
      when(() => mockRepository.streamMateria(any(), any()))
          .thenAnswer((_) => Stream.value([]));

      expect(mockRepository.streamMateria('user123', 'materia456'), emits([]));
    });

    test('streamMateria should only emit items for specific materia', () {
      final items = [
        testItem,
        HorarioItemEntity(
          id: '2',
          userId: 'user123',
          materiaId: 'materia456',
          titulo: 'Tarea 2',
          tipo: 'tarea',
          inicio: DateTime(2024, 1, 16, 8, 0),
          color: Colors.blue,
        ),
      ];
      when(() => mockRepository.streamMateria(any(), any()))
          .thenAnswer((_) => Stream.value(items));

      expect(
        mockRepository.streamMateria('user123', 'materia456'),
        emits(items),
      );
    });

    test('streamMateria should handle different materias', () {
      final itemsMateria1 = [testItem];
      final itemsMateria2 = [
        HorarioItemEntity(
          id: '2',
          userId: 'user123',
          materiaId: 'materia789',
          titulo: 'Otro item',
          tipo: 'tarea',
          inicio: DateTime(2024, 1, 16, 8, 0),
          color: Colors.red,
        ),
      ];

      when(() => mockRepository.streamMateria('user123', 'materia456'))
          .thenAnswer((_) => Stream.value(itemsMateria1));
      when(() => mockRepository.streamMateria('user123', 'materia789'))
          .thenAnswer((_) => Stream.value(itemsMateria2));

      expect(
        mockRepository.streamMateria('user123', 'materia456'),
        emits(itemsMateria1),
      );
      expect(
        mockRepository.streamMateria('user123', 'materia789'),
        emits(itemsMateria2),
      );
    });

    test('streamMateria should emit error when repository fails', () {
      when(() => mockRepository.streamMateria(any(), any()))
          .thenAnswer((_) => Stream.error(Exception('Stream error')));

      expect(
        mockRepository.streamMateria('user123', 'materia456'),
        emitsError(isA<Exception>()),
      );
    });

    test('crear should throw exception on error', () async {
      when(() => mockRepository.crear(any()))
          .thenThrow(Exception('Error creating item'));

      expect(
        () => mockRepository.crear(testItem),
        throwsException,
      );
    });

    test('crear should handle different tipos', () async {
      final tipos = ['tarea', 'prueba', 'otro'];

      for (final tipo in tipos) {
        final item = HorarioItemEntity(
          id: tipo,
          userId: 'user123',
          materiaId: 'materia456',
          titulo: 'Test $tipo',
          tipo: tipo,
          inicio: DateTime(2024, 1, 15, 8, 0),
          color: Colors.blue,
        );

        when(() => mockRepository.crear(any())).thenAnswer((_) async => item);

        final result = await mockRepository.crear(item);
        expect(result.tipo, tipo);
      }
    });
  });
}
