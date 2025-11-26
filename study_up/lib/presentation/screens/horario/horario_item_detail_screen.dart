import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/horario_item_entity.dart';
import '../../../domain/entities/materia_entity.dart';
import '../../../application/materias_provider.dart';
import 'package:intl/intl.dart';

class HorarioItemDetailScreen extends ConsumerWidget {
  final HorarioItemEntity item;
  const HorarioItemDetailScreen({Key? key, required this.item}) : super(key: key);

  String _formatDateTime(DateTime dt) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    return df.format(dt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<MateriaEntity?> materiaAsync = const AsyncValue.data(null);
    if (item.materiaId != null) {
      materiaAsync = ref.watch(materiaByIdProvider(item.materiaId!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del evento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed('/editar_tarea', arguments: item);
            },
            tooltip: 'Editar',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.titulo,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.completado)
                    Chip(label: const Text('Hecho'), backgroundColor: Colors.green[100]),
                ],
              ),
              const SizedBox(height: 12),
              // Tipo y materia asociada
              Text('Tipo: ${item.tipo}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              materiaAsync.when(
                data: (materia) {
                  if (materia == null) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('Materia: ${materia.nombre} (${materia.codigo})', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text('Semestre: ${materia.semestre} • Créditos: ${materia.creditos}'),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: LinearProgressIndicator(),
                ),
                error: (_, __) => const Text('No se pudo cargar la materia'),
              ),
              const SizedBox(height: 8),
              Text('Inicio: ${_formatDateTime(item.inicio)}'),
              if (item.fin != null) ...[
                const SizedBox(height: 8),
                Text('Fin: ${_formatDateTime(item.fin!)}'),
              ],
              const SizedBox(height: 8),
              Text('Recordatorio: ${item.recordatorioMinutosAntes != null ? '${item.recordatorioMinutosAntes} minutos antes' : 'Sin recordatorio'}'),
              const SizedBox(height: 12),
              const Text('Descripción', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(item.descripcion ?? '—'),
              const SizedBox(height: 16),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
