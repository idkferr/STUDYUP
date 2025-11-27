import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:study_up/domain/entities/materia_entity.dart';
import 'package:study_up/domain/repositories/materia_repository.dart';

class MockMateriaRepository extends Mock implements MateriaRepository {}

class FakeMateriaEntity extends Fake implements MateriaEntity {}

void main() {
  late MockMateriaRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeMateriaEntity());
  });

  setUp(() {
    mockRepository = MockMateriaRepository();
  });

  group('MateriaRepository Tests', () {
    final testMateria = MateriaEntity(
      id: '1',
      userId: 'user123',
      nombre: 'Matemáticas',
      codigo: 'MAT101',
      color: const Color(0xFF2196F3),
      creditos: 4,
      semestre: '2024-1',
    );

    test('crearMateria returns created materia', () async {
      // Arrange
      when(() => mockRepository.crearMateria(any()))
          .thenAnswer((_) async => testMateria);

      // Act
      final result = await mockRepository.crearMateria(testMateria);

      // Assert
      expect(result, testMateria);
      verify(() => mockRepository.crearMateria(testMateria)).called(1);
    });

    test('obtenerMaterias returns list of materias', () async {
      // Arrange
      final materias = [testMateria];
      when(() => mockRepository.obtenerMaterias(any()))
          .thenAnswer((_) async => materias);

      // Act
      final result = await mockRepository.obtenerMaterias('user123');

      // Assert
      expect(result, materias);
      expect(result.length, 1);
      verify(() => mockRepository.obtenerMaterias('user123')).called(1);
    });

    test('obtenerMaterias returns empty list when no materias exist', () async {
      // Arrange
      when(() => mockRepository.obtenerMaterias(any()))
          .thenAnswer((_) async => []);

      // Act
      final result = await mockRepository.obtenerMaterias('user123');

      // Assert
      expect(result, isEmpty);
      verify(() => mockRepository.obtenerMaterias('user123')).called(1);
    });

    test('obtenerMateriaPorId returns materia when found', () async {
      // Arrange
      when(() => mockRepository.obtenerMateriaPorId(any()))
          .thenAnswer((_) async => testMateria);

      // Act
      final result = await mockRepository.obtenerMateriaPorId('1');

      // Assert
      expect(result, testMateria);
      expect(result?.id, '1');
      verify(() => mockRepository.obtenerMateriaPorId('1')).called(1);
    });

    test('obtenerMateriaPorId returns null when not found', () async {
      // Arrange
      when(() => mockRepository.obtenerMateriaPorId(any()))
          .thenAnswer((_) async => null);

      // Act
      final result = await mockRepository.obtenerMateriaPorId('999');

      // Assert
      expect(result, isNull);
      verify(() => mockRepository.obtenerMateriaPorId('999')).called(1);
    });

    test('actualizarMateria completes successfully', () async {
      // Arrange
      when(() => mockRepository.actualizarMateria(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      await mockRepository.actualizarMateria(testMateria);

      // Assert
      verify(() => mockRepository.actualizarMateria(testMateria)).called(1);
    });

    test('eliminarMateria completes successfully', () async {
      // Arrange
      when(() => mockRepository.eliminarMateria(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      await mockRepository.eliminarMateria('1');

      // Assert
      verify(() => mockRepository.eliminarMateria('1')).called(1);
    });

    test('existeCodigo returns true when code exists', () async {
      // Arrange
      when(() => mockRepository.existeCodigo(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      final result = await mockRepository.existeCodigo('user123', 'MAT101');

      // Assert
      expect(result, true);
      verify(() => mockRepository.existeCodigo('user123', 'MAT101')).called(1);
    });

    test('existeCodigo returns false when code does not exist', () async {
      // Arrange
      when(() => mockRepository.existeCodigo(any(), any()))
          .thenAnswer((_) async => false);

      // Act
      final result = await mockRepository.existeCodigo('user123', 'FIS101');

      // Assert
      expect(result, false);
      verify(() => mockRepository.existeCodigo('user123', 'FIS101')).called(1);
    });

    test('existeCodigo with excludeId returns false', () async {
      // Arrange
      when(() => mockRepository.existeCodigo(
            any(),
            any(),
            excludeId: any(named: 'excludeId'),
          )).thenAnswer((_) async => false);

      // Act
      final result = await mockRepository.existeCodigo(
        'user123',
        'MAT101',
        excludeId: '1',
      );

      // Assert
      expect(result, false);
      verify(() => mockRepository.existeCodigo(
            'user123',
            'MAT101',
            excludeId: '1',
          )).called(1);
    });

    test('streamMaterias emits list of materias', () async {
      // Arrange
      final materias = [testMateria];
      when(() => mockRepository.streamMaterias(any()))
          .thenAnswer((_) => Stream.value(materias));

      // Act
      final stream = mockRepository.streamMaterias('user123');

      // Assert
      expect(stream, emits(materias));
      verify(() => mockRepository.streamMaterias('user123')).called(1);
    });

    test('streamMaterias emits empty list', () async {
      // Arrange
      when(() => mockRepository.streamMaterias(any()))
          .thenAnswer((_) => Stream.value([]));

      // Act
      final stream = mockRepository.streamMaterias('user123');

      // Assert
      expect(stream, emits([]));
      verify(() => mockRepository.streamMaterias('user123')).called(1);
    });

    test('streamMaterias emits multiple updates', () async {
      // Arrange
      final materia2 = MateriaEntity(
        id: '2',
        userId: 'user123',
        nombre: 'Física',
        codigo: 'FIS101',
        color: const Color(0xFFF44336),
        creditos: 4,
        semestre: "2024-1",
      );
      final materias1 = [testMateria];
      final materias2 = [testMateria, materia2];

      when(() => mockRepository.streamMaterias(any()))
          .thenAnswer((_) => Stream.fromIterable([materias1, materias2]));

      // Act
      final stream = mockRepository.streamMaterias('user123');

      // Assert
      expect(stream, emitsInOrder([materias1, materias2]));
    });

    test('streamMaterias emits error when something fails', () async {
      // Arrange
      when(() => mockRepository.streamMaterias(any()))
          .thenAnswer((_) => Stream.error(Exception('Error de conexión')));

      // Act
      final stream = mockRepository.streamMaterias('user123');

      // Assert
      expect(stream, emitsError(isA<Exception>()));
    });
  });
}
