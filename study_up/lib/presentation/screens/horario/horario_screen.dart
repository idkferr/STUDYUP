// filepath: lib/presentation/screens/horario/horario_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
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

          // Mapear eventos por día
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
            child: TableCalendar<HorarioItemEntity>(
              locale: 'es_ES',
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: DateTime.now(),
              eventLoader: (day) =>
                  eventosPorDia[DateTime(day.year, day.month, day.day)] ?? [],
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Column(
                      children: events
                          .take(2)
                          .map((e) => Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: e.color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  e.titulo,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ))
                          .toList(),
                    );
                  }
                  return null;
                },
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle:
                    const TextStyle(color: AppTheme.primaryPurple),
                defaultTextStyle: const TextStyle(color: AppTheme.textPrimary),
                outsideTextStyle:
                    const TextStyle(color: AppTheme.textSecondary),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.primaryBlue,
                ),
                leftChevronIcon:
                    const Icon(Icons.chevron_left, color: AppTheme.primaryBlue),
                rightChevronIcon: const Icon(Icons.chevron_right,
                    color: AppTheme.primaryBlue),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                    color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                weekendStyle: TextStyle(
                    color: AppTheme.primaryPurple, fontWeight: FontWeight.w600),
              ),
              onDaySelected: (selectedDay, focusedDay) async {
                final eventos = eventosPorDia[DateTime(selectedDay.year,
                        selectedDay.month, selectedDay.day)] ??
                    [];
                // CORRECCIÓN: Ordenar eventos antes de mapear
                final eventosOrdenados = [...eventos];
                eventosOrdenados.sort((a, b) => a.inicio.compareTo(b.inicio));
                await showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) => Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Eventos del ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(height: 12),
                        ...eventosOrdenados.map((e) => Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: ListTile(
                                leading: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: e.color,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.event, color: Colors.white),
                                ),
                                title: Text(e.titulo,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${e.tipo} • ${e.inicio.hour.toString().padLeft(2, '0')}:${e.inicio.minute.toString().padLeft(2, '0')} - ' +
                                        (e.fin != null
                                            ? '${e.fin?.hour.toString().padLeft(2, '0')}:${e.fin?.minute.toString().padLeft(2, '0')}'
                                            : '')),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: AppTheme.primaryPurple),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                HorarioItemFormScreen(item: e),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await ref
                                            .read(horarioItemsNotifierProvider(
                                                    user.uid)
                                                .notifier)
                                            .eliminar(e.id!);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content:
                                                    Text('Evento eliminado'),
                                                backgroundColor: Colors.red));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HorarioItemFormScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar evento/tarea'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
