// filepath: lib/presentation/screens/horario/horario_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/calendario_horario.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../application/user_provider.dart';
import '../../../application/horario_items_provider.dart';
import '../../../domain/entities/horario_item_entity.dart';
import '../../theme/app_theme.dart';
import 'horario_item_form_screen.dart';

class HorarioScreen extends ConsumerStatefulWidget {
  const HorarioScreen({super.key});

  @override
  ConsumerState<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends ConsumerState<HorarioScreen> {
  DateTime? _selectedDayForCreate;

  @override
  Widget build(BuildContext context) {
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
                        builder: (_) => HorarioItemFormScreen(
                            initialDate: _selectedDayForCreate),
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
          // Mapear eventos por día con los objetos completos
          final eventosPorDia = <DateTime, List<HorarioItemEntity>>{};
          for (final item in items) {
            final dia =
                DateTime(item.inicio.year, item.inicio.month, item.inicio.day);
            eventosPorDia.putIfAbsent(dia, () => []).add(item);
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
            child: CalendarioHorario(
              eventos: eventosPorDia,
              onToggleCompletado: (item, value) async {
                final notifier =
                    ref.read(horarioItemsNotifierProvider(user.uid).notifier);
                await notifier.actualizar(item.copyWith(completado: value));
              },
              onEliminar: (item) async {
                final notifier =
                    ref.read(horarioItemsNotifierProvider(user.uid).notifier);
                await notifier.eliminar(item.id!);
              },
              onDiaSeleccionado: (d) =>
                  setState(() => _selectedDayForCreate = d),
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
            builder: (_) =>
                HorarioItemFormScreen(initialDate: _selectedDayForCreate),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Evento'),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );
  }
}
