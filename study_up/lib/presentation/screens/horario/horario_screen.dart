// filepath: lib/presentation/screens/horario/horario_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widgets/calendario_profesional.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../application/user_provider.dart';
import '../../../application/horario_items_provider.dart';
import '../../../domain/entities/horario_item_entity.dart';
import '../../theme/app_theme.dart';
import 'horario_item_form_screen.dart';

class HorarioScreen extends ConsumerWidget {
  const HorarioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    initializeDateFormatting('es_ES', null);
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
                  const Icon(Icons.event_note,
                      size: 80, color: AppTheme.primaryBlue),
                  const SizedBox(height: 16),
                  const Text('No hay eventos en el horario',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HorarioItemFormScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: AppTheme.primaryBlue),
                    label: const Text('Crear Evento'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                      foregroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Mapear eventos por día para el calendario profesional
          final eventosPorDia = <DateTime, List<String>>{};
          for (final item in items) {
            final dia = DateTime(item.inicio.year, item.inicio.month, item.inicio.day);
            final descripcion = '${item.titulo} • ${item.tipo} • ${item.inicio.hour.toString().padLeft(2, '0')}:${item.inicio.minute.toString().padLeft(2, '0')}'
              + (item.fin != null ? ' - ${item.fin?.hour.toString().padLeft(2, '0')}:${item.fin?.minute.toString().padLeft(2, '0')}' : '');
            eventosPorDia.putIfAbsent(dia, () => []).add(descripcion);
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.all(16),
            child: CalendarioProfesional(
              eventos: eventosPorDia,
              primaryColor: AppTheme.primaryPurple,
              accentColor: AppTheme.primaryBlue,
            ),
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
}
