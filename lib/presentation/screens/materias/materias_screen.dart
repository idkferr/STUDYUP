import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/materias_provider.dart';
import '../../../application/user_provider.dart';
import '../../../domain/entities/materia_entity.dart';
import '../../../domain/entities/calificacion_entity.dart';
import '../../theme/app_theme.dart';
import '../../../application/calificaciones_provider.dart';
import '../../../application/progress_providers.dart';
import '../../../domain/services/progress_services.dart';
import '../../../application/semestre_provider.dart';
import 'materia_detail_screen.dart';

class MateriasScreen extends ConsumerWidget {
  const MateriasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    final semestreSeleccionado = ref.watch(semestreSeleccionadoProvider);
    final materiasAsync = ref.watch(materiasStreamProvider(user.uid));
    final semestresDisponibles =
        ref.watch(semestresDisponiblesProvider(user.uid));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Mis Materias',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Icon(
                        Icons.school,
                        size: 200,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppTheme.primaryBlue.withOpacity(0.9),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String?>(
                        value: semestreSeleccionado,
                        isExpanded: true,
                        dropdownColor: AppTheme.primaryBlue,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        underline: Container(),
                        hint: const Text('Todos los semestres',
                            style: TextStyle(color: Colors.white70)),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('📚 Todos los semestres'),
                          ),
                          ...semestresDisponibles.map((s) => DropdownMenuItem(
                                value: s,
                                child: Text('📅 $s'),
                              )),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            ref
                                .read(semestreSeleccionadoProvider.notifier)
                                .limpiarFiltro();
                          } else {
                            ref
                                .read(semestreSeleccionadoProvider.notifier)
                                .setSemestre(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          materiasAsync.when(
            data: (todasMaterias) {
              // Filtrar por semestre si está seleccionado
              final materias = semestreSeleccionado == null
                  ? todasMaterias
                  : todasMaterias
                      .where((m) => m.semestre == semestreSeleccionado)
                      .toList();

              if (materias.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 100,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          semestreSeleccionado == null
                              ? 'No tienes materias registradas'
                              : 'No hay materias en $semestreSeleccionado',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Presiona el botón + para agregar una',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final materia = materias[index];
                    return _MateriaCard(
                      materia: materia,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MateriaDetailScreen(materia: materia),
                        ),
                      ),
                      onDelete: () =>
                          _confirmarEliminar(context, ref, materia, user.uid),
                    );
                  }, childCount: materias.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: ${error.toString()}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navegarACrear(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Materia'),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );
  }

  void _navegarACrear(BuildContext context) {
    Navigator.pushNamed(context, '/materia-form');
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    WidgetRef ref,
    MateriaEntity materia,
    String userId,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Eliminar "${materia.nombre}"?\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      try {
        await ref
            .read(materiasNotifierProvider(userId).notifier)
            .eliminarMateria(materia.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Materia eliminada exitosamente')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _MateriaCard extends ConsumerWidget {
  final MateriaEntity materia;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MateriaCard({
    required this.materia,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener calificaciones de la materia para progreso
    final califsAsync = (materia.id != null)
        ? ref.watch(calificacionesPorMateriaStreamProvider(
            (materia.userId, materia.id!)))
        : const AsyncValue<List<CalificacionEntity>>.data([]);
    final progress = (materia.id != null)
        ? ref.watch(materiaProgressProvider((materia.userId, materia.id!)))
        : const MateriaProgressResult(
            porcentajeAcumulado: 0,
            promedioPonderado: 0,
            aprobada: false,
            excedido: false,
            enRiesgo: false,
          );

    final promedioPonderado = progress.promedioPonderado;
    final sumPorcentaje = progress.porcentajeAcumulado;
    final progreso = (sumPorcentaje.clamp(0, 100)) / 100;
    final excedido = progress.excedido;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: materia.color, width: 6)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: materia.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.book, color: materia.color, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            materia.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            materia.codigo,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.credit_card,
                      label: '${materia.creditos} créditos',
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.calendar_today,
                      label: materia.semestre,
                      color: AppTheme.primaryPurple,
                    ),
                  ],
                ),
                if (materia.descripcion != null &&
                    materia.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    materia.descripcion!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (materia.horario != null && materia.horario!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.schedule, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          materia.horario!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                // Progreso de calificaciones
                if (califsAsync.isLoading) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 4),
                  Text('Cargando progreso...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Avance: ${sumPorcentaje.toStringAsFixed(0)}%',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Promedio: ${promedioPonderado.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: promedioPonderado >= 4.0
                                ? Colors.green[700]
                                : Colors.red[700],
                          )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (progress.aprobada)
                    Text('Aprobada',
                        style: TextStyle(
                            color: Colors.green[800],
                            fontSize: 12,
                            fontWeight: FontWeight.w600))
                  else if (progress.enRiesgo)
                    Text('En riesgo (cerca de aprobar)',
                        style:
                            const TextStyle(color: Colors.orange, fontSize: 12))
                  else
                    Text('No aprobada',
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progreso,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        excedido ? Colors.red : AppTheme.primaryPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (excedido)
                    Text(
                        '⚠ Se excede 100% (${sumPorcentaje.toStringAsFixed(1)}%)',
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12)),
                  if (!excedido && sumPorcentaje < 100)
                    Text(
                        'Falta ${(100 - sumPorcentaje).toStringAsFixed(0)}% para completar',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                  if (sumPorcentaje == 100 && !excedido)
                    Text('Completado 100%',
                        style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
