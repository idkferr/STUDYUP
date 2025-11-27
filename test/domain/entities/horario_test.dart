import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_up/domain/entities/horario_item_entity.dart';

/// Tests para HorarioItemEntity
///
/// ESTRATEGIA:
/// - Testear construcción con valores requeridos y opcionales
/// - Testear copyWith para inmutabilidad
/// - Testear serialización/deserialización (toMap/fromMap)
/// - Testear edge cases (nulls, fechas inválidas, colores)
void main() {
  group('HorarioItemEntity Construction', () {
    test('should create entity with required fields only', () {
      // Arrange
      final inicio = DateTime(2024, 1, 15, 10, 0);
      const color = Color(0xFF7E57C2);

      // Act
      final entity = HorarioItemEntity(
        userId: 'user123',
        titulo: 'Matemáticas',
        tipo: 'tarea',
        inicio: inicio,
        color: color,
      );

      // Assert
      expect(entity.id, isNull);
      expect(entity.userId, 'user123');
      expect(entity.materiaId, isNull);
      expect(entity.titulo, 'Matemáticas');
      expect(entity.tipo, 'tarea');
      expect(entity.inicio, inicio);
      expect(entity.fin, isNull);
      expect(entity.recordatorioMinutosAntes, isNull);
      expect(entity.descripcion, isNull);
      expect(entity.color, color);
    });

    test('should create entity with all fields', () {
      // Arrange
      final inicio = DateTime(2024, 1, 15, 10, 0);
      final fin = DateTime(2024, 1, 15, 12, 0);
      const color = Color(0xFFFF5722);

      // Act
      final entity = HorarioItemEntity(
        id: 'horario123',
        userId: 'user456',
        materiaId: 'materia789',
        titulo: 'Examen Final',
        tipo: 'prueba',
        inicio: inicio,
        fin: fin,
        recordatorioMinutosAntes: 30,
        descripcion: 'Estudiar capítulos 1-5',
        color: color,
      );

      // Assert
      expect(entity.id, 'horario123');
      expect(entity.userId, 'user456');
      expect(entity.materiaId, 'materia789');
      expect(entity.titulo, 'Examen Final');
      expect(entity.tipo, 'prueba');
      expect(entity.inicio, inicio);
      expect(entity.fin, fin);
      expect(entity.recordatorioMinutosAntes, 30);
      expect(entity.descripcion, 'Estudiar capítulos 1-5');
      expect(entity.color, color);
    });
  });

  group('HorarioItemEntity copyWith', () {
    late HorarioItemEntity originalEntity;

    setUp(() {
      originalEntity = HorarioItemEntity(
        id: 'original123',
        userId: 'user123',
        materiaId: 'materia123',
        titulo: 'Original',
        tipo: 'tarea',
        inicio: DateTime(2024, 1, 15, 10, 0),
        fin: DateTime(2024, 1, 15, 11, 0),
        recordatorioMinutosAntes: 15,
        descripcion: 'Descripción original',
        color: const Color(0xFF7E57C2),
      );
    });

    test('should create copy with updated titulo', () {
      // Act
      final updated = originalEntity.copyWith(titulo: 'Nuevo Título');

      // Assert
      expect(updated.titulo, 'Nuevo Título');
      expect(updated.id, originalEntity.id);
      expect(updated.userId, originalEntity.userId);
      expect(updated.tipo, originalEntity.tipo);
    });

    test('should create copy with updated fecha inicio', () {
      // Arrange
      final nuevaFecha = DateTime(2024, 2, 20, 14, 30);

      // Act
      final updated = originalEntity.copyWith(inicio: nuevaFecha);

      // Assert
      expect(updated.inicio, nuevaFecha);
      expect(updated.fin, originalEntity.fin);
      expect(updated.titulo, originalEntity.titulo);
    });

    test('should create copy with multiple updated fields', () {
      // Arrange
      final nuevaFecha = DateTime(2024, 3, 10, 9, 0);
      const nuevoColor = Color(0xFFFF5722);

      // Act
      final updated = originalEntity.copyWith(
        titulo: 'Actualizado',
        inicio: nuevaFecha,
        recordatorioMinutosAntes: 60,
        color: nuevoColor,
      );

      // Assert
      expect(updated.titulo, 'Actualizado');
      expect(updated.inicio, nuevaFecha);
      expect(updated.recordatorioMinutosAntes, 60);
      expect(updated.color, nuevoColor);
      expect(updated.userId, originalEntity.userId);
      expect(updated.tipo, originalEntity.tipo);
    });

    test('should create copy without changes when no parameters', () {
      // Act
      final copy = originalEntity.copyWith();

      // Assert
      expect(copy.id, originalEntity.id);
      expect(copy.userId, originalEntity.userId);
      expect(copy.titulo, originalEntity.titulo);
      expect(copy.inicio, originalEntity.inicio);
      expect(copy.color.value, originalEntity.color.value);
    });
  });

  group('HorarioItemEntity Serialization (toMap)', () {
    test('should convert entity to map with all fields', () {
      // Arrange
      final inicio = DateTime(2024, 1, 15, 10, 0);
      final fin = DateTime(2024, 1, 15, 12, 0);
      final entity = HorarioItemEntity(
        id: 'horario123',
        userId: 'user123',
        materiaId: 'materia456',
        titulo: 'Test',
        tipo: 'prueba',
        inicio: inicio,
        fin: fin,
        recordatorioMinutosAntes: 30,
        descripcion: 'Test descripción',
        color: const Color(0xFF7E57C2),
      );

      // Act
      final map = entity.toMap();

      // Assert
      expect(map['userId'], 'user123');
      expect(map['materiaId'], 'materia456');
      expect(map['titulo'], 'Test');
      expect(map['tipo'], 'prueba');
      expect(map['inicio'], inicio.toIso8601String());
      expect(map['fin'], fin.toIso8601String());
      expect(map['recordatorioMinutosAntes'], 30);
      expect(map['descripcion'], 'Test descripción');
      expect(map['color'], 0xFF7E57C2);
    });

    test('should convert entity to map with null optional fields', () {
      // Arrange
      final entity = HorarioItemEntity(
        userId: 'user123',
        titulo: 'Test',
        tipo: 'otro',
        inicio: DateTime(2024, 1, 15, 10, 0),
        color: const Color(0xFF7E57C2),
      );

      // Act
      final map = entity.toMap();

      // Assert
      expect(map['materiaId'], isNull);
      expect(map['fin'], isNull);
      expect(map['recordatorioMinutosAntes'], isNull);
      expect(map['descripcion'], isNull);
      expect(map['userId'], isNotNull);
      expect(map['titulo'], isNotNull);
    });
  });

  group('HorarioItemEntity Deserialization (fromMap)', () {
    test('should create entity from complete map', () {
      // Arrange
      final map = {
        'userId': 'user123',
        'materiaId': 'materia456',
        'titulo': 'Examen',
        'tipo': 'prueba',
        'inicio': '2024-01-15T10:00:00.000',
        'fin': '2024-01-15T12:00:00.000',
        'recordatorioMinutosAntes': 45,
        'descripcion': 'Importante',
        'color': 0xFFFF5722,
      };

      // Act
      final entity = HorarioItemEntity.fromMap(map, 'horario123');

      // Assert
      expect(entity.id, 'horario123');
      expect(entity.userId, 'user123');
      expect(entity.materiaId, 'materia456');
      expect(entity.titulo, 'Examen');
      expect(entity.tipo, 'prueba');
      expect(entity.inicio, DateTime.parse('2024-01-15T10:00:00.000'));
      expect(entity.fin, DateTime.parse('2024-01-15T12:00:00.000'));
      expect(entity.recordatorioMinutosAntes, 45);
      expect(entity.descripcion, 'Importante');
      expect(entity.color.value, 0xFFFF5722);
    });

    test('should handle missing optional fields with defaults', () {
      // Arrange
      final map = {
        'userId': 'user123',
        'titulo': 'Tarea',
        'inicio': '2024-01-15T10:00:00.000',
      };

      // Act
      final entity = HorarioItemEntity.fromMap(map, 'horario456');

      // Assert
      expect(entity.id, 'horario456');
      expect(entity.userId, 'user123');
      expect(entity.materiaId, isNull);
      expect(entity.titulo, 'Tarea');
      expect(entity.tipo, 'otro'); // Default
      expect(entity.fin, isNull);
      expect(entity.recordatorioMinutosAntes, isNull);
      expect(entity.descripcion, isNull);
      expect(entity.color.value, 0xFF7E57C2); // Default
    });

    test('should handle empty strings as-is (not as null)', () {
      // Arrange
      final map = {
        'userId': '',
        'titulo': '',
        'tipo': '',
        'inicio': '',
        'fin': '',
      };

      // Act
      final entity = HorarioItemEntity.fromMap(map, 'test123');

      // Assert
      expect(entity.userId, ''); // Empty string se mantiene
      expect(entity.titulo, ''); // Empty string se mantiene
      expect(entity.tipo, ''); // Empty string se mantiene (no default)
      expect(entity.inicio, isA<DateTime>()); // Invalid date → DateTime.now()
      expect(entity.fin, isNull); // Invalid date → null
    });

    test('should handle invalid date with DateTime.now fallback', () {
      // Arrange
      final map = {
        'userId': 'user123',
        'titulo': 'Test',
        'inicio': 'invalid-date',
      };

      // Act
      final entity = HorarioItemEntity.fromMap(map, 'test789');

      // Assert
      expect(entity.inicio, isA<DateTime>());
      expect(
          entity.inicio
              .isBefore(DateTime.now().add(const Duration(seconds: 1))),
          true);
    });
  });

  group('HorarioItemEntity Round-trip Serialization', () {
    test('should maintain data integrity in toMap -> fromMap cycle', () {
      // Arrange
      final original = HorarioItemEntity(
        userId: 'user123',
        materiaId: 'materia456',
        titulo: 'Round Trip Test',
        tipo: 'tarea',
        inicio: DateTime(2024, 1, 15, 10, 0),
        fin: DateTime(2024, 1, 15, 11, 0),
        recordatorioMinutosAntes: 20,
        descripcion: 'Test description',
        color: const Color(0xFFFF5722),
      );

      // Act
      final map = original.toMap();
      final reconstructed = HorarioItemEntity.fromMap(map, 'newId');

      // Assert
      expect(reconstructed.userId, original.userId);
      expect(reconstructed.materiaId, original.materiaId);
      expect(reconstructed.titulo, original.titulo);
      expect(reconstructed.tipo, original.tipo);
      expect(reconstructed.inicio, original.inicio);
      expect(reconstructed.fin, original.fin);
      expect(reconstructed.recordatorioMinutosAntes,
          original.recordatorioMinutosAntes);
      expect(reconstructed.descripcion, original.descripcion);
      expect(reconstructed.color.value, original.color.value);
    });
  });

  group('HorarioItemEntity Edge Cases', () {
    test('should handle same inicio and fin times', () {
      // Arrange
      final fecha = DateTime(2024, 1, 15, 10, 0);

      // Act
      final entity = HorarioItemEntity(
        userId: 'user123',
        titulo: 'Evento Instantáneo',
        tipo: 'otro',
        inicio: fecha,
        fin: fecha,
        color: const Color(0xFF7E57C2),
      );

      // Assert
      expect(entity.inicio, entity.fin);
      expect(entity.inicio.isAtSameMomentAs(entity.fin!), true);
    });

    test('should allow recordatorioMinutosAntes to be zero', () {
      // Act
      final entity = HorarioItemEntity(
        userId: 'user123',
        titulo: 'Test',
        tipo: 'tarea',
        inicio: DateTime.now(),
        recordatorioMinutosAntes: 0,
        color: const Color(0xFF7E57C2),
      );

      // Assert
      expect(entity.recordatorioMinutosAntes, 0);
    });

    test('should handle very long strings', () {
      // Arrange
      final longString = 'a' * 1000;

      // Act
      final entity = HorarioItemEntity(
        userId: 'user123',
        titulo: longString,
        tipo: 'tarea',
        inicio: DateTime.now(),
        descripcion: longString,
        color: const Color(0xFF7E57C2),
      );

      // Assert
      expect(entity.titulo.length, 1000);
      expect(entity.descripcion?.length, 1000);
    });

    test('should handle different color values', () {
      // Arrange
      const colors = [
        Color(0x00000000), // Transparent
        Color(0xFFFFFFFF), // White
        Color(0xFF000000), // Black
        Color(0x80FF5722), // Semi-transparent
      ];

      for (final color in colors) {
        // Act
        final entity = HorarioItemEntity(
          userId: 'user123',
          titulo: 'Test',
          tipo: 'otro',
          inicio: DateTime.now(),
          color: color,
        );

        // Assert
        expect(entity.color, color);
        expect(entity.color.value, color.value);
      }
    });
  });
}
