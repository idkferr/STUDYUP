// filepath: lib/domain/entities/horario_item_entity.dart
import 'package:flutter/material.dart';

class HorarioItemEntity {
  final String? id;
  final String userId;
  final String? materiaId; // Puede ser null para eventos generales
  final String titulo;
  final String tipo; // tarea, prueba, otro
  final DateTime inicio;
  final DateTime? fin;
  final int? recordatorioMinutosAntes; // null = sin recordatorio
  final String? descripcion;
  final Color color;

  HorarioItemEntity({
    this.id,
    required this.userId,
    this.materiaId,
    required this.titulo,
    required this.tipo,
    required this.inicio,
    this.fin,
    this.recordatorioMinutosAntes,
    this.descripcion,
    required this.color,
  });

  HorarioItemEntity copyWith({
    String? id,
    String? userId,
    String? materiaId,
    String? titulo,
    String? tipo,
    DateTime? inicio,
    DateTime? fin,
    int? recordatorioMinutosAntes,
    String? descripcion,
    Color? color,
  }) {
    return HorarioItemEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      materiaId: materiaId ?? this.materiaId,
      titulo: titulo ?? this.titulo,
      tipo: tipo ?? this.tipo,
      inicio: inicio ?? this.inicio,
      fin: fin ?? this.fin,
      recordatorioMinutosAntes:
          recordatorioMinutosAntes ?? this.recordatorioMinutosAntes,
      descripcion: descripcion ?? this.descripcion,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'materiaId': materiaId,
      'titulo': titulo,
      'tipo': tipo,
      'inicio': inicio.toIso8601String(),
      'fin': fin?.toIso8601String(),
      'recordatorioMinutosAntes': recordatorioMinutosAntes,
      'descripcion': descripcion,
      'color': color.value,
    };
  }

  factory HorarioItemEntity.fromMap(Map<String, dynamic> map, String id) {
    return HorarioItemEntity(
      id: id,
      userId: map['userId'] ?? '',
      materiaId: map['materiaId'],
      titulo: map['titulo'] ?? '',
      tipo: map['tipo'] ?? 'otro',
      inicio: DateTime.tryParse(map['inicio'] ?? '') ?? DateTime.now(),
      fin: DateTime.tryParse(map['fin'] ?? ''),
      recordatorioMinutosAntes: map['recordatorioMinutosAntes'],
      descripcion: map['descripcion'],
      color: Color(map['color'] ?? 0xFF7E57C2),
    );
  }
}
