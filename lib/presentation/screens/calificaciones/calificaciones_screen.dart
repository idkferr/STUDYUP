import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../application/calificaciones_provider.dart';
import '../../../application/materias_provider.dart';
import '../../../application/user_provider.dart';
import '../../../application/semestre_provider.dart';
import '../../../presentation/theme/app_theme.dart';
import 'calificacion_form_screen.dart';

final materiaSeleccionadaProvider = StateProvider<String?>((ref) => null);

class CalificacionesScreen extends ConsumerStatefulWidget {
  const CalificacionesScreen({super.key});

  @override
  ConsumerState<CalificacionesScreen> createState() =>
      _CalificacionesScreenState();
}

class _CalificacionesScreenState extends ConsumerState<CalificacionesScreen> {
  @override
  void initState() {
    super.initState();
    // El provider .family se actualiza automáticamente cuando el userId cambia
    // No es necesario cargar manualmente
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Debes iniciar sesión'),
        ),
      );
    }

    final semestreSeleccionado = ref.watch(semestreSeleccionadoProvider);
    final calificacionesAsync =
        ref.watch(calificacionesStreamProvider(user.uid));
    final materiasAsync = ref.watch(materiasStreamProvider(user.uid));
    final semestresDisponibles =
        ref.watch(semestresDisponiblesProvider(user.uid));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con gradiente
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Mis Calificaciones',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1565C0), // Azul
                      Color(0xFF7E57C2), // Morado
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.grade_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: const Color(0xFF1565C0).withOpacity(0.9),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String?>(
                            value: semestreSeleccionado,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1565C0),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            underline: Container(),
                            hint: const Text('Todos los semestres',
                                style: TextStyle(color: Colors.white70)),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('📚 Todos los semestres'),
                              ),
                              ...semestresDisponibles
                                  .map((s) => DropdownMenuItem(
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
                  // Filtro de materia
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: const Color(0xFF7E57C2).withOpacity(0.9),
                    child: materiasAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (e, _) => Text('Error: $e'),
                      data: (materias) => Row(
                        children: [
                          const Icon(Icons.school,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String?>(
                              value: ref.watch(materiaSeleccionadaProvider),
                              isExpanded: true,
                              dropdownColor: const Color(0xFF7E57C2),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              underline: Container(),
                              hint: const Text('Todas las materias',
                                  style: TextStyle(color: Colors.white70)),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Todas las materias'),
                                ),
                                ...materias.map((m) => DropdownMenuItem(
                                      value: m.id,
                                      child: Text(m.nombre),
                                    )),
                              ],
                              onChanged: (value) {
                                ref
                                    .read(materiaSeleccionadaProvider.notifier)
                                    .state = value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido
          materiasAsync.when(
            loading: () => calificacionesAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) =>
                  SliverFillRemaining(child: Center(child: Text('Error: $e'))),
              data: (_) => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error materias: $e'))),
            data: (todasMaterias) {
              return calificacionesAsync.when(
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
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar calificaciones',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                data: (todasCalificaciones) {
                  // Filtrar calificaciones según semestre y materia seleccionados
                  final materiaSeleccionada =
                      ref.watch(materiaSeleccionadaProvider);

                    // Compatibilidad: aceptar calificaciones con campo 'materia' o 'materiaId'
                    final materiasIds = semestreSeleccionado == null
                      ? todasMaterias.map((m) => m.id).toSet()
                      : todasMaterias
                        .where((m) => m.semestre == semestreSeleccionado)
                        .map((m) => m.id)
                        .toSet();

                    final calificaciones = todasCalificaciones
                      .where((c) => materiasIds.contains(c.materiaId) || materiasIds.contains(c.materia))
                      .where((c) =>
                        materiaSeleccionada == null ||
                        c.materiaId == materiaSeleccionada ||
                        (c.materia != null && c.materia == materiaSeleccionada))
                      .toList();

                  // Agrupar calificaciones por materia
                  final materiaPorId = {
                    for (final m in todasMaterias)
                      if (m.id != null) m.id!: m
                  };

                  if (calificaciones.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.note_add_rounded,
                                size: 64,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              semestreSeleccionado == null
                                  ? '¡No hay calificaciones aún!'
                                  : 'No hay calificaciones en $semestreSeleccionado',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Agrega tu primera calificación',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Agrupar por materiaId
                  final calificacionesPorMateria = <String, List<dynamic>>{};
                  for (final c in calificaciones) {
                    calificacionesPorMateria.putIfAbsent(c.materiaId, () => []).add(c);
                  }

                  // Calcular estadísticas globales
                  final totalNotas = calificaciones.length;
                  final promedio = calificaciones.isEmpty
                      ? 0.0
                      : calificaciones.map((c) => c.nota).reduce((a, b) => a + b) / totalNotas;
                  final aprobadas = calificaciones.where((c) => c.aprobado).length;
                  final reprobadas = totalNotas - aprobadas;
                  final stats = {
                    'promedio': promedio,
                    'total': totalNotas,
                    'aprobadas': aprobadas,
                    'reprobadas': reprobadas,
                  };

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),
                      _buildStatsCard(context, stats),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Calificaciones por materia',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...calificacionesPorMateria.entries.map((entry) {
                        final materia = materiaPorId[entry.key];
                        final califs = List.from(entry.value);
                        // Ordenar por porcentaje descendente, luego fecha
                        califs.sort((a, b) {
                          final cmp = b.porcentaje.compareTo(a.porcentaje);
                          if (cmp != 0) return cmp;
                          return b.fecha.compareTo(a.fecha);
                        });
                        final notaFinal = califs.first;
                        final parciales = califs.length > 1 ? califs.sublist(1) : [];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: materia?.color ?? Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        materia?.nombre ?? 'Materia',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Nota final destacada
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.successGradient,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                                            const SizedBox(width: 8),
                                            Text('Nota Final', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                          ],
                                        ),
                                        Text(
                                          notaFinal.nota.toStringAsFixed(1),
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (parciales.isNotEmpty) ...[
                                    Text('Notas parciales:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    ...parciales.map((c) => _buildCalificacionCard(context, c, materia?.nombre ?? 'Materia')),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 80),
                    ]),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CalificacionFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentGreen.withOpacity(0.1),
            AppTheme.accentOrange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Resumen Académico',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.school_rounded,
                label: 'Total',
                value: '${stats['total']}',
                color: AppTheme.primaryBlue,
              ),
              _buildStatItem(
                context,
                icon: Icons.trending_up_rounded,
                label: 'Promedio',
                value: stats['promedio'].toStringAsFixed(2),
                color: AppTheme.primaryPurple,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.check_circle_rounded,
                label: 'Aprobadas',
                value: '${stats['aprobadas']}',
                color: AppTheme.accentGreen,
              ),
              _buildStatItem(
                context,
                icon: Icons.cancel_rounded,
                label: 'Reprobadas',
                value: '${stats['reprobadas']}',
                color: Colors.red.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCalificacionCard(
      BuildContext context, calificacion, String materiaNombre) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isAprobado = calificacion.aprobado;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isAprobado
              ? AppTheme.accentGreen.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CalificacionFormScreen(calificacion: calificacion),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono de nota
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isAprobado
                      ? AppTheme.accentGreen.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isAprobado
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color:
                      isAprobado ? AppTheme.accentGreen : Colors.red.shade400,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      materiaNombre,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      calificacion.descripcion,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(calificacion.fecha),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Nota
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isAprobado
                      ? AppTheme.successGradient
                      : LinearGradient(
                          colors: [
                            Colors.red.shade400,
                            Colors.red.shade600,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  calificacion.nota.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
