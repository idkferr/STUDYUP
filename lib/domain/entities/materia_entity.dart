// filepath: lib/domain/entities/materia_entity.dart
import 'package:flutter/material.dart';

class MateriaEntity {
  final String? id; // ID de Firestore (null cuando es nueva)
  final String userId; // ID del usuario dueño
  final String codigo; // Código de la materia (ej: "CS101")
  final String nombre; // Nombre de la materia (ej: "Programación I")
  final int creditos; // Créditos académicos
  final String semestre; // Semestre (ej: "2024-1")
  final Color color; // Color para identificar visualmente la materia
  final String? descripcion; // Descripción opcional
  final String?
      horario; // Horario opcional (ej: "Lun 09:00-10:30, Mie 11:00-12:30")

  MateriaEntity({
    this.id,
    required this.userId,
    required this.codigo,
    required this.nombre,
    required this.creditos,
    required this.semestre,
    required this.color,
    this.descripcion,
    this.horario,
  });

  // CopyWith para crear copias con modificaciones
  MateriaEntity copyWith({
    String? id,
    String? userId,
    String? codigo,
    String? nombre,
    int? creditos,
    String? semestre,
    Color? color,
    String? descripcion,
    String? horario,
  }) {
    return MateriaEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      creditos: creditos ?? this.creditos,
      semestre: semestre ?? this.semestre,
      color: color ?? this.color,
      descripcion: descripcion ?? this.descripcion,
      horario: horario ?? this.horario,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'codigo': codigo,
      'nombre': nombre,
      'creditos': creditos,
      'semestre': semestre,
      'color': color.value, // Guardar como int
      'descripcion': descripcion,
      'horario': horario,
    };
  }

  // Crear desde Map de Firestore
  factory MateriaEntity.fromMap(Map<String, dynamic> map, String id) {
    return MateriaEntity(
      id: id,
      userId: map['userId'] ?? '',
      codigo: map['codigo'] ?? '',
      nombre: map['nombre'] ?? '',
      creditos: map['creditos'] ?? 0,
      semestre: map['semestre'] ?? '',
      color: Color(map['color'] ?? 0xFF1565C0), // Azul por defecto
      descripcion: map['descripcion'],
      horario: map['horario'],
    );
  }

  @override
  String toString() {
    return 'MateriaEntity(id: $id, codigo: $codigo, nombre: $nombre, semestre: $semestre, horario: $horario)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MateriaEntity &&
        other.id == id &&
        other.userId == userId &&
        other.codigo == codigo &&
        other.nombre == nombre &&
        other.creditos == creditos &&
        other.semestre == semestre &&
        other.color == color &&
        other.descripcion == descripcion &&
        other.horario == horario;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        codigo.hashCode ^
        nombre.hashCode ^
        creditos.hashCode ^
        semestre.hashCode ^
        color.hashCode ^
        descripcion.hashCode ^
        horario.hashCode;
  }
}
