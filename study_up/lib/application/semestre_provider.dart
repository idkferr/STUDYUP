// filepath: lib/application/semestre_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'materias_provider.dart';

/// Provider para el semestre actualmente seleccionado
/// Permite filtrar materias y calificaciones por semestre
class SemestreNotifier extends StateNotifier<String?> {
  SemestreNotifier() : super(null); // null = mostrar todos

  void setSemestre(String semestre) {
    state = semestre;
  }

  void limpiarFiltro() {
    state = null;
  }
}

final semestreSeleccionadoProvider =
    StateNotifierProvider<SemestreNotifier, String?>((ref) {
  return SemestreNotifier();
});

/// Provider que obtiene la lista de semestres disponibles a partir de las materias
final semestresDisponiblesProvider =
    Provider.family<List<String>, String>((ref, userId) {
  final materiasAsync = ref.watch(materiasStreamProvider(userId));
  return materiasAsync.maybeWhen(
    data: (materias) {
      final semestres = materias.map((m) => m.semestre).toSet().toList();
      semestres.sort((a, b) => b.compareTo(a)); // Más recientes primero
      return semestres;
    },
    orElse: () => [],
  );
});
