// filepath: lib/domain/services/progress_services.dart
import '../entities/calificacion_entity.dart';

class MateriaProgressResult {
  final double porcentajeAcumulado; // 0..100
  final double promedioPonderado; // 1.0..7.0
  final bool aprobada; // según reglas
  final bool excedido; // porcentaje > 100
  final bool enRiesgo; // cerca pero no alcanza
  const MateriaProgressResult({
    required this.porcentajeAcumulado,
    required this.promedioPonderado,
    required this.aprobada,
    required this.excedido,
    required this.enRiesgo,
  });
}

class MateriaProgressService {
  static const double passingGrade = 4.0; // Nota mínima
  static const double minProgressForPass =
      39.5; // Porcentaje mínimo acumulado que usuario indicó

  static MateriaProgressResult calcular(List<CalificacionEntity> califs) {
    double totalPorcentaje = 0;
    double sumaPonderada = 0;
    for (final c in califs) {
      totalPorcentaje += c.porcentaje;
      sumaPonderada += c.nota * c.porcentaje;
    }
    final promedio = totalPorcentaje > 0 ? sumaPonderada / totalPorcentaje : 0;
    final aprobada =
        promedio >= passingGrade && totalPorcentaje >= minProgressForPass;
    final excedido = totalPorcentaje > 100;
    final enRiesgo = !aprobada && promedio >= (passingGrade - 0.3); // margen
    return MateriaProgressResult(
      porcentajeAcumulado: totalPorcentaje,
      promedioPonderado: promedio.toDouble(),
      aprobada: aprobada,
      excedido: excedido,
      enRiesgo: enRiesgo,
    );
  }
}

class GlobalProgressResult {
  final double promedioGlobal;
  final double porcentajeTotal; // suma porcentajes (no limitado a 100)
  final int materiasAprobadas;
  final int materiasEnRiesgo;
  final int materiasTotales;
  const GlobalProgressResult({
    required this.promedioGlobal,
    required this.porcentajeTotal,
    required this.materiasAprobadas,
    required this.materiasEnRiesgo,
    required this.materiasTotales,
  });
}

class GlobalProgressService {
  static GlobalProgressResult calcular(
      Map<String, List<CalificacionEntity>> porMateria) {
    int aprobadas = 0;
    int enRiesgo = 0;
    int totales = porMateria.length;
    double sumaPromedios = 0;
    double sumaPorcentajes = 0;
    porMateria.forEach((_, califs) {
      final r = MateriaProgressService.calcular(califs);
      if (r.aprobada)
        aprobadas++;
      else if (r.enRiesgo) enRiesgo++;
      sumaPromedios += r.promedioPonderado;
      sumaPorcentajes += r.porcentajeAcumulado;
    });
    final promedioGlobal = totales > 0 ? (sumaPromedios / totales) : 0;
    return GlobalProgressResult(
      promedioGlobal: promedioGlobal.toDouble(),
      porcentajeTotal: sumaPorcentajes,
      materiasAprobadas: aprobadas,
      materiasEnRiesgo: enRiesgo,
      materiasTotales: totales,
    );
  }
}

// Simulación (calificaciones hipotéticas no persistidas)
class SimulationCalificacion {
  final double nota;
  final double porcentaje;
  final String descripcion;
  const SimulationCalificacion(
      {required this.nota,
      required this.porcentaje,
      required this.descripcion});
}

class SimulationResult {
  final MateriaProgressResult resultadoMateria;
  final List<SimulationCalificacion> simuladas;
  const SimulationResult(
      {required this.resultadoMateria, required this.simuladas});
}

class SimulationService {
  static SimulationResult simular(List<CalificacionEntity> reales,
      List<SimulationCalificacion> hipoteticas) {
    // Convertir simuladas a entidad temporal (userId/materiaId vacíos)
    final convertidas = hipoteticas
        .map((s) => CalificacionEntity(
              id: null,
              userId: '',
              materiaId: '',
              nota: s.nota,
              descripcion: s.descripcion,
              porcentaje: s.porcentaje,
              fecha: DateTime.now(),
            ))
        .toList();
    final todas = [...reales, ...convertidas];
    final resultado = MateriaProgressService.calcular(todas);
    return SimulationResult(
        resultadoMateria: resultado, simuladas: hipoteticas);
  }
}
