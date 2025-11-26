import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_up/domain/entities/materia_entity.dart';

void main() {
  group('Materia Entity Tests', () {
    test('should create MateriaEntity with valid properties', () {
      // Arrange & Act
      final materia = MateriaEntity(
        id: '1',
        userId: 'user123',
        codigo: 'MAT101',
        nombre: 'Matemáticas',
        creditos: 4,
        semestre: '2024-1',
        color: Colors.blue,
      );

      // Assert
      expect(materia.id, '1');
      expect(materia.nombre, 'Matemáticas');
      expect(materia.creditos, 4);
      expect(materia.semestre, '2024-1');
    });

    test(
        'should compare two MateriaEntity instances with same properties as equal',
        () {
      // Arrange
      final materia1 = MateriaEntity(
        id: '1',
        userId: 'user123',
        codigo: 'MAT101',
        nombre: 'Math',
        creditos: 4,
        semestre: '2024-1',
        color: Colors.blue,
      );
      final materia2 = MateriaEntity(
        id: '1',
        userId: 'user123',
        codigo: 'MAT101',
        nombre: 'Math',
        creditos: 4,
        semestre: '2024-1',
        color: Colors.blue,
      );

      // Assert
      expect(materia1, equals(materia2));
    });

    test('should convert MateriaEntity to Map', () {
      // Arrange
      final materia = MateriaEntity(
        id: '1',
        userId: 'user123',
        codigo: 'MAT101',
        nombre: 'Math',
        creditos: 4,
        semestre: '2024-1',
        color: Colors.blue,
      );

      // Act
      final map = materia.toMap();

      // Assert
      expect(map['userId'], 'user123');
      expect(map['codigo'], 'MAT101');
      expect(map['nombre'], 'Math');
      expect(map['creditos'], 4);
      expect(map['semestre'], '2024-1');
      expect(map['color'], Colors.blue.value);
    });

    test('should create MateriaEntity from Map', () {
      // Arrange
      final map = {
        'userId': 'user123',
        'codigo': 'MAT101',
        'nombre': 'Math',
        'creditos': 4,
        'semestre': '2024-1',
        'color': Colors.blue.value,
      };

      // Act
      final materia = MateriaEntity.fromMap(map, '1');

      // Assert
      expect(materia.id, '1');
      expect(materia.userId, 'user123');
      expect(materia.codigo, 'MAT101');
      expect(materia.nombre, 'Math');
      expect(materia.creditos, 4);
    });
  });
}
