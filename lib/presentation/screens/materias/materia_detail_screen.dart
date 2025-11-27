import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/user_provider.dart';
import '../../../application/calificaciones_provider.dart';
import '../../../application/progress_providers.dart';
import '../../../domain/entities/materia_entity.dart';
import '../../../presentation/theme/app_theme.dart';
import '../calificaciones/calificacion_form_screen.dart';
import '../../../domain/entities/calificacion_entity.dart';
import '../../../domain/services/progress_services.dart';

class MateriaDetailScreen extends ConsumerWidget {
  final MateriaEntity materia;
  const MateriaDetailScreen({super.key, required this.materia});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Debes iniciar sesión')));
    }
    if (materia.id == null) {
      return const Scaffold(body: Center(child: Text('Materia inválida')));
    }

    final califsAsync = ref.watch(
        calificacionesPorMateriaStreamProvider((materia.userId, materia.id!)));
    final progress =
        ref.watch(materiaProgressProvider((materia.userId, materia.id!)));

    return Scaffold(
      appBar: AppBar(
        title: Text(materia.nombre),
        actions: [
          IconButton(
            tooltip: 'Editar materia',
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/materia-form', arguments: materia);
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [materia.color, AppTheme.primaryBlue],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CalificacionFormScreen(),
              settings: RouteSettings(arguments: materia.id),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Calificación'),
        backgroundColor: materia.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderInfo(materia: materia, progress: progress),
            const SizedBox(height: 24),
            Text('Calificaciones',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            califsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (califs) {
                if (califs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.note_add,
                            size: 48, color: AppTheme.primaryPurple),
                        SizedBox(height: 12),
                        Text('No hay calificaciones en esta materia'),
                        SizedBox(height: 8),
                        Text('Pulsa "+" para agregar la primera',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  );
                }
                return Column(
                  children: califs.map((c) => _CalificacionRow(c)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final MateriaEntity materia;
  final MateriaProgressResult progress;
  const _HeaderInfo({required this.materia, required this.progress});

  @override
  Widget build(BuildContext context) {
    final sumPorc = progress.porcentajeAcumulado;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: materia.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.book, color: materia.color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(materia.nombre,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${materia.codigo} • ${materia.semestre}',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(
                    icon: Icons.credit_card,
                    label: '${materia.creditos} créditos',
                    color: AppTheme.primaryBlue),
                _Chip(
                    icon: Icons.percent,
                    label: 'Avance ${sumPorc.toStringAsFixed(0)}%',
                    color: materia.color),
                _Chip(
                    icon: Icons.trending_up,
                    label:
                        'Promedio ${progress.promedioPonderado.toStringAsFixed(2)}',
                    color: progress.promedioPonderado >= 4.0
                        ? Colors.green
                        : Colors.red),
                if (sumPorc >= 100 && progress.aprobada)
                  _Chip(
                      icon: Icons.check_circle,
                      label: 'Aprobada',
                      color: Colors.green),
                if (sumPorc >= 100 && !progress.aprobada)
                  _Chip(
                      icon: Icons.cancel,
                      label: 'Reprobada',
                      color: Colors.red),
                if (sumPorc < 100)
                  _Chip(
                      icon: Icons.info_outline,
                      label:
                          'Falta ${(100 - sumPorc).toStringAsFixed(0)}% para resultado',
                      color: AppTheme.primaryPurple),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (sumPorc.clamp(0, 100)) / 100,
                minHeight: 10,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                    progress.excedido ? Colors.red : materia.color),
              ),
            ),
            if (materia.descripcion != null &&
                materia.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(materia.descripcion!, style: const TextStyle(fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }
}

class _CalificacionRow extends StatelessWidget {
  final CalificacionEntity calificacion;
  const _CalificacionRow(this.calificacion);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CalificacionFormScreen(calificacion: calificacion),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: calificacion.aprobado
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  calificacion.nota.toStringAsFixed(1),
                  style: TextStyle(
                    color: calificacion.aprobado ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(calificacion.descripcion,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                        'Nota: ${calificacion.nota.toStringAsFixed(1)} • ${calificacion.porcentaje.toStringAsFixed(0)}%',
                        style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    Text(_fechaStr(calificacion.fecha),
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fechaStr(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
