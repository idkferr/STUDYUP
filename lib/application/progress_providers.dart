// filepath: lib/application/progress_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/services/progress_services.dart';
import '../domain/entities/calificacion_entity.dart';
import 'calificaciones_provider.dart';
import 'materias_provider.dart';
import 'user_provider.dart';

// Progreso por materia (usa stream de calificaciones por materia)
final materiaProgressProvider =
    Provider.family<MateriaProgressResult, (String userId, String materiaId)>(
        (ref, tuple) {
  final califsAsync = ref.watch(calificacionesPorMateriaStreamProvider(tuple));
  return califsAsync.maybeWhen(
    data: (califs) => MateriaProgressService.calcular(califs),
    orElse: () => const MateriaProgressResult(
      porcentajeAcumulado: 0,
      promedioPonderado: 0,
      aprobada: false,
      excedido: false,
      enRiesgo: false,
    ),
  );
});

// Progreso global (agrega por materia)
final globalProgressProvider = Provider<GlobalProgressResult>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) {
    return const GlobalProgressResult(
      promedioGlobal: 0,
      porcentajeTotal: 0,
      materiasAprobadas: 0,
      materiasEnRiesgo: 0,
      materiasTotales: 0,
    );
  }
  final materiasAsync = ref.watch(materiasStreamProvider(user.uid));
  final califsAsync = ref.watch(calificacionesStreamProvider(user.uid));

  if (materiasAsync.isLoading || califsAsync.isLoading) {
    return const GlobalProgressResult(
      promedioGlobal: 0,
      porcentajeTotal: 0,
      materiasAprobadas: 0,
      materiasEnRiesgo: 0,
      materiasTotales: 0,
    );
  }
  final materias =
      materiasAsync.maybeWhen(data: (m) => m, orElse: () => <dynamic>[]);
  final califs = califsAsync.maybeWhen(
      data: (c) => c, orElse: () => <CalificacionEntity>[]);
  final porMateria = <String, List<CalificacionEntity>>{};
  for (final m in materias) {
    porMateria[m.id ?? ''] = califs.where((c) => c.materiaId == m.id).toList();
  }
  return GlobalProgressService.calcular(porMateria);
});

// Simulación (StateNotifier) por materia
class SimulationState {
  final List<SimulationCalificacion> simuladas;
  final SimulationResult resultado;
  const SimulationState({required this.simuladas, required this.resultado});
}

class SimulationNotifier extends StateNotifier<SimulationState> {
  final List<CalificacionEntity> _reales;
  SimulationNotifier(this._reales)
      : super(SimulationState(
          simuladas: const [],
          resultado: SimulationService.simular(_reales, const []),
        ));

  void agregar(double nota, double porcentaje, String descripcion) {
    final nueva = SimulationCalificacion(
        nota: nota, porcentaje: porcentaje, descripcion: descripcion);
    final lista = [...state.simuladas, nueva];
    state = SimulationState(
      simuladas: lista,
      resultado: SimulationService.simular(_reales, lista),
    );
  }

  void eliminar(int index) {
    final lista = [...state.simuladas]..removeAt(index);
    state = SimulationState(
      simuladas: lista,
      resultado: SimulationService.simular(_reales, lista),
    );
  }

  void limpiar() {
    state = SimulationState(
      simuladas: const [],
      resultado: SimulationService.simular(_reales, const []),
    );
  }
}

final simulationProvider = StateNotifierProvider.family<SimulationNotifier,
    SimulationState, List<CalificacionEntity>>((ref, reales) {
  return SimulationNotifier(reales);
});
