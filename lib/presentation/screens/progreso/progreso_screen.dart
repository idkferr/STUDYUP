// filepath: lib/presentation/screens/progreso/progreso_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/user_provider.dart';
import '../../../application/materias_provider.dart';
import '../../../application/progress_providers.dart';
import '../../../domain/services/progress_services.dart';
import '../../theme/app_theme.dart';

class ProgresoScreen extends ConsumerWidget {
  const ProgresoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión')),
      );
    }

    final globalProgress = ref.watch(globalProgressProvider);
    final materiasAsync = ref.watch(materiasStreamProvider(user.uid));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Progreso Académico',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.trending_up,
                      size: 80, color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Resumen Global
                _GlobalCard(global: globalProgress),
                const SizedBox(height: 24),

                // Título de materias
                const Text('Progreso por Materia',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Lista de materias con progreso
                materiasAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (materias) {
                    if (materias.isEmpty) {
                      return const Center(child: Text('No hay materias'));
                    }

                    // Agrupar por semestre
                    final porSemestre = <String, List<dynamic>>{};
                    for (final m in materias) {
                      porSemestre.putIfAbsent(m.semestre, () => []).add(m);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: porSemestre.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text('Semestre ${entry.key}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                            ...entry.value.map((m) => _MateriaProgressCard(
                                  materia: m,
                                  userId: user.uid,
                                )),
                            const SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobalCard extends StatelessWidget {
  final GlobalProgressResult global;
  const _GlobalCard({required this.global});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentGreen.withOpacity(0.15),
            AppTheme.primaryBlue.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen Global',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                  label: 'Promedio',
                  value: global.promedioGlobal.toStringAsFixed(2),
                  icon: Icons.star,
                  color: global.promedioGlobal >= 4.0
                      ? AppTheme.accentGreen
                      : Colors.red),
              _StatItem(
                  label: 'Aprobadas',
                  value: '${global.materiasAprobadas}',
                  icon: Icons.check_circle,
                  color: AppTheme.accentGreen),
              _StatItem(
                  label: 'En Riesgo',
                  value: '${global.materiasEnRiesgo}',
                  icon: Icons.warning,
                  color: Colors.orange),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _MateriaProgressCard extends ConsumerWidget {
  final dynamic materia;
  final String userId;
  const _MateriaProgressCard({required this.materia, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = (materia.id != null)
        ? ref.watch(materiaProgressProvider((userId, materia.id!)))
        : const MateriaProgressResult(
            porcentajeAcumulado: 0,
            promedioPonderado: 0,
            aprobada: false,
            excedido: false,
            enRiesgo: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: materia.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(materia.nombre,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                _StatusChip(progress: progress),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (progress.porcentajeAcumulado.clamp(0, 100)) / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(
                progress.excedido
                    ? Colors.red
                    : progress.aprobada
                        ? AppTheme.accentGreen
                        : AppTheme.primaryPurple,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Avance: ${progress.porcentajeAcumulado.toStringAsFixed(0)}%'),
                Text(
                    'Promedio: ${progress.promedioPonderado.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: progress.promedioPonderado >= 4.0
                            ? AppTheme.accentGreen
                            : Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final MateriaProgressResult progress;
  const _StatusChip({required this.progress});

  @override
  Widget build(BuildContext context) {
    final status = progress.aprobada
        ? ('Aprobada', AppTheme.accentGreen)
        : progress.enRiesgo
            ? ('En Riesgo', Colors.orange)
            : ('No Aprobada', Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.$2.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status.$1,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: status.$2)),
    );
  }
}
