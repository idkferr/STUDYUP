// filepath: lib/presentation/screens/horario/horario_screen_new.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/user_provider.dart';
import '../../../application/horario_items_provider.dart';
import '../../../domain/entities/horario_item_entity.dart';
import '../../theme/app_theme.dart';
import 'horario_item_form_screen.dart';

class HorarioScreen extends ConsumerWidget {
  const HorarioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Debes iniciar sesión')));
    }

    final itemsAsync = ref.watch(horarioItemsStreamProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horario & Eventos'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
            ),
          ),
        ),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_note, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No hay eventos en el horario'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HorarioItemFormScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Evento'),
                  ),
                ],
              ),
            );
          }

          // Agrupar por fecha
          final agrupados = <String, List<HorarioItemEntity>>{};
          for (final item in items) {
            final key =
                '${item.inicio.day}/${item.inicio.month}/${item.inicio.year}';
            agrupados.putIfAbsent(key, () => []).add(item);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: agrupados.length,
            itemBuilder: (ctx, idx) {
              final entry = agrupados.entries.elementAt(idx);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(entry.key,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  ...entry.value.map((item) => Card(
                        child: ListTile(
                          leading:
                              Icon(_iconoTipo(item.tipo), color: item.color),
                          title: Text(item.titulo),
                          subtitle: Text(
                              '${item.inicio.hour.toString().padLeft(2, '0')}:${item.inicio.minute.toString().padLeft(2, '0')}${item.fin != null ? ' - ${item.fin!.hour.toString().padLeft(2, '0')}:${item.fin!.minute.toString().padLeft(2, '0')}' : ''}'),
                          trailing: item.recordatorioMinutosAntes != null
                              ? const Icon(Icons.notifications_active,
                                  color: AppTheme.accentOrange)
                              : null,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HorarioItemFormScreen(item: item),
                            ),
                          ),
                        ),
                      )),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HorarioItemFormScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Evento'),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );
  }

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case 'tarea':
        return Icons.assignment;
      case 'prueba':
        return Icons.quiz;
      case 'examen':
        return Icons.school;
      case 'clase':
        return Icons.class_;
      default:
        return Icons.event;
    }
  }
}
