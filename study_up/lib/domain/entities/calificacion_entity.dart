class CalificacionEntity {
  final String? id; // ID de Firestore (null cuando es nueva)
  final String userId; // ID del usuario dueño
  final String materiaId; // ID de la materia (relación con MateriaEntity)
  final double nota; // Calificación (1.0 - 7.0 sistema chileno)
  final String descripcion; // Descripción opcional (parcial, final, etc.)
  final double porcentaje; // Porcentaje que vale (obligatorio)
  final DateTime fecha; // Fecha de creación / aplicacion

  CalificacionEntity({
    this.id,
    required this.userId,
    required this.materiaId,
    required this.nota,
    required this.descripcion,
    required this.porcentaje,
    required this.fecha,
  });

  // Método para determinar si aprobó (nota >= 4.0 sistema chileno)
  bool get aprobado => nota >= 4.0;
  // CopyWith para crear copias con modificaciones
  CalificacionEntity copyWith({
    String? id,
    String? userId,
    String? materiaId,
    double? nota,
    String? descripcion,
    double? porcentaje,
    DateTime? fecha,
  }) {
    return CalificacionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      materiaId: materiaId ?? this.materiaId,
      nota: nota ?? this.nota,
      descripcion: descripcion ?? this.descripcion,
      porcentaje: porcentaje ?? this.porcentaje,
      fecha: fecha ?? this.fecha,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'materiaId': materiaId,
      'nota': nota,
      'descripcion': descripcion,
      'porcentaje': porcentaje,
      'fecha': fecha.toIso8601String(),
    };
  }

  // Crear desde Map de Firestore
  factory CalificacionEntity.fromMap(Map<String, dynamic> map, String id) {
    return CalificacionEntity(
      id: id,
      userId: map['userId'] ?? '',
      materiaId: map['materiaId'] ?? '',
      nota: (map['nota'] ?? 1.0).toDouble(),
      descripcion: map['descripcion'] ?? '',
      porcentaje: (map['porcentaje'] ?? 0).toDouble(),
      fecha: DateTime.tryParse(map['fecha'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  String toString() {
    return 'CalificacionEntity(id: $id, materiaId: $materiaId, nota: $nota, porcentaje: $porcentaje%, fecha: $fecha)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CalificacionEntity &&
        other.id == id &&
        other.userId == userId &&
        other.materiaId == materiaId &&
        other.nota == nota &&
        other.descripcion == descripcion &&
        other.porcentaje == porcentaje &&
        other.fecha == fecha;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        materiaId.hashCode ^
        nota.hashCode ^
        descripcion.hashCode ^
        porcentaje.hashCode ^
        fecha.hashCode;
  }
}
