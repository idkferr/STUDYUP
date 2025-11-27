import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/horario_item_entity.dart';
import '../screens/horario/horario_item_detail_screen.dart';
import '../screens/horario/horario_item_form_screen.dart';

/// Widget de calendario con vistas de mes, semana y día (tipo Google Calendar).
/// Siempre muestra la grilla, aunque no haya eventos. Localizado en español.

typedef OnToggleCompletado = Future<void> Function(HorarioItemEntity, bool);
typedef OnEliminar = Future<void> Function(HorarioItemEntity);
typedef OnDiaSeleccionado = void Function(DateTime);

class CalendarioHorario extends StatefulWidget {
  final Map<DateTime, List<HorarioItemEntity>> eventos;
  final Color primaryColor;
  final Color accentColor;
  final OnToggleCompletado? onToggleCompletado;
  final OnEliminar? onEliminar;
  final OnDiaSeleccionado? onDiaSeleccionado;

  const CalendarioHorario({
    super.key,
    required this.eventos,
    this.primaryColor = const Color(0xFF1565C0),
    this.accentColor = const Color(0xFF7E57C2),
    this.onToggleCompletado,
    this.onEliminar,
    this.onDiaSeleccionado,
  });

  @override
  State<CalendarioHorario> createState() => _CalendarioHorarioState();
}

class _CalendarioHorarioState extends State<CalendarioHorario> {
  void _showTareaActionsDialog(
      BuildContext context, HorarioItemEntity tarea) async {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(tarea.titulo),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => HorarioItemDetailScreen(item: tarea),
              ));
            },
            child: const Row(
              children: [
                Icon(Icons.visibility, color: Colors.black87),
                SizedBox(width: 8),
                Text('Ver'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(ctx);
              if (widget.onToggleCompletado != null) {
                await widget.onToggleCompletado!(tarea, !tarea.completado);
              }
            },
            child: Row(
              children: [
                Icon(
                  tarea.completado
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(tarea.completado
                    ? 'Marcar como pendiente'
                    : 'Marcar como hecha'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.of(context).pushNamed(
                '/editar_tarea',
                arguments: tarea,
              );
            },
            child: const Row(
              children: [
                Icon(Icons.edit, color: Colors.blue),
                SizedBox(width: 8),
                Text('Editar'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(ctx);
              if (widget.onEliminar != null) {
                await widget.onEliminar!(tarea);
              }
            },
            child: const Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Eliminar'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Listas para forzar localización manual en TableCalendar 3.x
  static const List<String> _diasSemana = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom'
  ];
  static const List<String> _meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  // Removed unused day view flag
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  // Centralized text styles for consistent alignment and sizing
  TextStyle get _headerTextStyle => TextStyle(
      fontSize: 18, fontWeight: FontWeight.w700, color: widget.primaryColor);
  TextStyle get _dowTextStyle => const TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87);
  TextStyle get _dayNumberStyle => const TextStyle(fontWeight: FontWeight.w600);
  TextStyle get _eventTitleStyle =>
      const TextStyle(fontSize: 11, fontWeight: FontWeight.w600);
  @override
  Widget build(BuildContext context) {
    // Usar LayoutBuilder para obtener el espacio disponible y ajustar alturas dinámicamente
    return LayoutBuilder(
      builder: (context, constraints) {
        final availHeight = (constraints.maxHeight.isFinite &&
                constraints.maxHeight > 0)
            ? constraints.maxHeight
            : MediaQuery.of(context)
                .size
                .height; // Calcular altura del calendario según la vista (mes/semana) y el espacio disponible
        // Para pantallas pequeñas, usar porcentajes más conservadores
        final calendarHeight = (_calendarFormat == CalendarFormat.month)
            ? (availHeight * 0.45).clamp(200.0, 480.0)
            : (availHeight * 0.24).clamp(110.0, 280.0);

        // Calcular rowHeight considerando TODOS los elementos internos de TableCalendar:
        // - Header (título del mes): ~32px (reducido para pantallas pequeñas)
        // - Days of week (Lun, Mar, etc): 28px (reducido)
        // - Padding interno del calendario: ~12px
        // - Filas de días: el espacio restante dividido entre 6 filas (mes) o 1 fila (semana)
        final headerHeight = 32.0;
        final dowHeight = 28.0;
        final internalPadding = 12.0;
        final containerPadding = 12.0; // padding del Container
        final availableForRows = (calendarHeight -
                headerHeight -
                dowHeight -
                internalPadding -
                containerPadding)
            .clamp(80.0, 1000.0);

        final rowHeight = (_calendarFormat == CalendarFormat.month)
            ? (availableForRows / 6.0).clamp(28.0, 90.0)
            : (availableForRows * 0.8).clamp(32.0, 160.0);

        return SizedBox(
          height: availHeight,
          child: Column(
            children: [
              // Selector de vista
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ToggleButtons(
                    isSelected: [
                      _calendarFormat == CalendarFormat.month,
                      _calendarFormat == CalendarFormat.week,
                    ],
                    onPressed: (index) {
                      setState(() {
                        if (index == 0) {
                          _calendarFormat = CalendarFormat.month;
                        } else if (index == 1) {
                          _calendarFormat = CalendarFormat.week;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    selectedColor: Colors.white,
                    fillColor: widget.primaryColor,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    constraints:
                        const BoxConstraints(minHeight: 40, minWidth: 80),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Mes'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Semana'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Card-like container for the calendar con altura dinámica
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: SizedBox(
                  height: // ensure calendar never requests more than available space
                      // reserve vertical space for selector + paddings + event list
                      () {
                    // estimated reserved space: selector (40) + paddings + spacing
                    final reserved = 40 +
                        12 +
                        14 +
                        20; // selector + gaps + footer padding (reducido)
                    final calc = (_calendarFormat == CalendarFormat.month)
                        ? (availHeight * 0.45).clamp(200.0, 480.0)
                        : (availHeight * 0.24).clamp(110.0, 280.0);
                    final maxAllowed =
                        (availHeight - reserved).clamp(110.0, availHeight);
                    return calc <= maxAllowed ? calc : maxAllowed;
                  }(),
                  width: double.infinity,
                  child: TableCalendar<HorarioItemEntity>(
                    locale: 'es_ES',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    // rowHeight dinámico para evitar overflows y mejorar responsividad
                    rowHeight: rowHeight,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: (day) =>
                        widget
                            .eventos[DateTime(day.year, day.month, day.day)] ??
                        [],
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: widget.accentColor.withOpacity(0.25),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: widget.accentColor.withOpacity(0.12),
                              blurRadius: 6)
                        ],
                      ),
                      selectedDecoration: BoxDecoration(
                        color: widget.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: widget.primaryColor.withOpacity(0.22),
                              blurRadius: 8)
                        ],
                      ),
                      markerDecoration: BoxDecoration(
                        color: widget.accentColor,
                        shape: BoxShape.circle,
                      ),
                      markersAlignment: Alignment.bottomCenter,
                      markerSize: 8,
                      defaultTextStyle: const TextStyle(fontSize: 15),
                      cellPadding: EdgeInsets.zero,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: _headerTextStyle,
                      headerPadding: const EdgeInsets.symmetric(vertical: 4),
                      titleTextFormatter: (date, locale) {
                        return '${_meses[date.month - 1]} ${date.year}';
                      },
                    ),
                    daysOfWeekHeight: 28,
                    daysOfWeekStyle: DaysOfWeekStyle(
                      dowTextFormatter: (date, locale) {
                        return _diasSemana[date.weekday - 1];
                      },
                      weekendStyle:
                          _dowTextStyle.copyWith(color: Colors.redAccent),
                      weekdayStyle: _dowTextStyle,
                      decoration: BoxDecoration(color: Colors.transparent),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        if (widget.onDiaSeleccionado != null)
                          widget.onDiaSeleccionado!(selectedDay);
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final events = widget.eventos[
                                DateTime(day.year, day.month, day.day)] ??
                            [];
                        return _buildDayCell(day, events, false);
                      },
                      todayBuilder: (context, day, focusedDay) {
                        final events = widget.eventos[
                                DateTime(day.year, day.month, day.day)] ??
                            [];
                        return _buildDayCell(day, events, true);
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        final events = widget.eventos[
                                DateTime(day.year, day.month, day.day)] ??
                            [];
                        return _buildDayCell(day, events, true, selected: true);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // La lista de eventos ocupa el resto del espacio con scroll si es necesario
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_calendarFormat == CalendarFormat.month &&
                          _selectedDay != null)
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxHeight: availHeight * 0.32),
                          child: _buildDayEvents(_selectedDay!),
                        ),
                      if (_calendarFormat == CalendarFormat.week)
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxHeight: availHeight * 0.36),
                          child: _buildWeekEvents(_focusedDay),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Lista agrupada de eventos para la semana que contiene [focusedDay].
  Widget _buildWeekEvents(DateTime focusedDay) {
    final startOfWeek =
        focusedDay.subtract(Duration(days: focusedDay.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    // Recolectar todos los eventos de la semana en orden por día
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Eventos de la semana ${startOfWeek.day}/${startOfWeek.month} - ${startOfWeek.add(Duration(days: 6)).day}/${startOfWeek.add(Duration(days: 6)).month}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...days.map((d) {
              final events =
                  widget.eventos[DateTime(d.year, d.month, d.day)] ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Text(
                        '${_diasSemana[d.weekday - 1]} ${d.day}/${d.month}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  if (events.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 6.0),
                      child: Text('No hay eventos',
                          style: TextStyle(color: Colors.grey[600])),
                    ),
                  ...events.map((e) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: e.color,
                                  borderRadius: BorderRadius.circular(3))),
                          title: Text(e.titulo,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${e.tipo} • ${e.inicio.hour.toString().padLeft(2, '0')}:${e.inicio.minute.toString().padLeft(2, '0')}' +
                                  (e.fin != null
                                      ? ' - ${e.fin!.hour.toString().padLeft(2, '0')}:${e.fin!.minute.toString().padLeft(2, '0')}'
                                      : '')),
                          trailing:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            if (e.completado)
                              const Icon(Icons.check, color: Colors.green),
                            if (widget.onEliminar != null)
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final ok = await _confirmDelete(context, e);
                                  if (ok && widget.onEliminar != null) {
                                    await widget.onEliminar!(e);
                                  }
                                },
                              ),
                          ]),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      HorarioItemDetailScreen(item: e))),
                          onLongPress: () =>
                              _showTareaActionsDialog(context, e),
                        ),
                      ))
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Reconstructed day cell builder (LayoutBuilder-based) to avoid overflow and keep styling
  Widget _buildDayCell(
      DateTime day, List<HorarioItemEntity> events, bool isToday,
      {bool selected = false}) {
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // If constraints are unbounded, fallback to small defaults
          final maxH =
              (constraints.maxHeight.isFinite && constraints.maxHeight > 0)
                  ? constraints.maxHeight
                  : 60.0;
          final maxW =
              (constraints.maxWidth.isFinite && constraints.maxWidth > 0)
                  ? constraints.maxWidth
                  : 60.0;

          // Allocate space: circle ~40% of height, rest for optional event info
          // Lower the minimum sizes to better fit very small cells on narrow screens
          final circleSize = (maxH * 0.4).clamp(12.0, 26.0);
          final titleMaxWidth = (maxW * 0.85).clamp(32.0, 140.0);

          // Only show event details if we have enough vertical space
          // Minimum space needed: circle + tiny margin + event container (min 14px) + dots (10px)
          final showEventTitle = events.isNotEmpty && maxH >= (circleSize + 18);
          final showMoreIndicator =
              events.length > 1 && maxH >= (circleSize + 28);

          return InkWell(
            onTap: () {
              // Seleccionar el día para mostrar sus eventos abajo (no diálogo)
              setState(() {
                _selectedDay = day;
                _focusedDay = day;
                if (widget.onDiaSeleccionado != null)
                  widget.onDiaSeleccionado!(day);
              });
            },
            borderRadius: BorderRadius.circular(8),
            onLongPress: () {
              // Mantener el diálogo de resumen en long press para acciones rápidas
              _showDaySummaryDialog(context, day, events);
            },
            child: SizedBox(
              height: maxH,
              width: maxW,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? widget.primaryColor
                            : isToday
                                ? widget.accentColor.withOpacity(0.18)
                                : Colors.grey[100],
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                    color:
                                        widget.primaryColor.withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: Offset(0, 2))
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: _dayNumberStyle.copyWith(
                          color: selected
                              ? Colors.white
                              : (isToday
                                  ? widget.primaryColor
                                  : Colors.black87),
                          fontSize: (circleSize * 0.5).clamp(9.0, 15.0),
                        ),
                      ),
                    ),
                    if (showEventTitle)
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth: titleMaxWidth,
                              minHeight: 0,
                              maxHeight: 20),
                          decoration: BoxDecoration(
                            color: selected
                                ? widget.primaryColor.withOpacity(0.9)
                                : widget.accentColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          margin: const EdgeInsets.only(top: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      color: events.first.color,
                                      borderRadius: BorderRadius.circular(3))),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  events.first.titulo,
                                  style: _eventTitleStyle.copyWith(
                                    fontSize: 11,
                                    color: events.first.completado
                                        ? Colors.green[700]
                                        : (selected
                                            ? Colors.white
                                            : Colors.black87),
                                    decoration: events.first.completado
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (showMoreIndicator)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Text('...',
                              style: TextStyle(
                                  fontSize: 10,
                                  height: 1.0,
                                  color: widget.accentColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDaySummaryDialog(
      BuildContext context, DateTime day, List<HorarioItemEntity> events) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eventos ${day.day}/${day.month}/${day.year}'),
        content: SizedBox(
          width: double.maxFinite,
          child: events.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('No hay eventos para este día.'),
                  ],
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const Divider(height: 8),
                  itemBuilder: (context, index) {
                    final e = events[index];
                    return ListTile(
                      leading:
                          CircleAvatar(backgroundColor: e.color, radius: 12),
                      title: Text(e.titulo,
                          style: TextStyle(
                              decoration: e.completado
                                  ? TextDecoration.lineThrough
                                  : null)),
                      subtitle: Text(
                        '${e.tipo} • ${e.inicio.hour.toString().padLeft(2, '0')}:${e.inicio.minute.toString().padLeft(2, '0')}' +
                            (e.fin != null
                                ? ' - ${e.fin!.hour.toString().padLeft(2, '0')}:${e.fin!.minute.toString().padLeft(2, '0')}'
                                : ''),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (e.completado)
                            const Icon(Icons.check, color: Colors.green),
                          if (widget.onEliminar != null)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final ok = await _confirmDelete(ctx, e);
                                if (ok && widget.onEliminar != null) {
                                  await widget.onEliminar!(e);
                                }
                                // close the summary dialog after deletion
                                if (ok) Navigator.of(ctx).pop();
                              },
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => HorarioItemDetailScreen(item: e)));
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => HorarioItemFormScreen(initialDate: day)));
            },
            child: const Text('Crear evento'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(
      BuildContext context, HorarioItemEntity item) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Deseas eliminar "${item.titulo}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    return res ?? false;
  }

  Widget _buildDayEvents(DateTime day) {
    final events = widget.eventos[DateTime(day.year, day.month, day.day)] ?? [];
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Eventos para ${day.day}/${day.month}/${day.year}:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (events.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No hay eventos para este día.'),
              ),
            ...events.map((e) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Checkbox(
                      value: e.completado,
                      onChanged: widget.onToggleCompletado == null
                          ? null
                          : (val) =>
                              widget.onToggleCompletado!(e, val ?? false),
                    ),
                    title: Text(
                      e.titulo,
                      style: TextStyle(
                        decoration:
                            e.completado ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      '${e.tipo} • ${e.inicio.hour.toString().padLeft(2, '0')}:${e.inicio.minute.toString().padLeft(2, '0')}' +
                          (e.fin != null
                              ? ' - ${e.fin!.hour.toString().padLeft(2, '0')}:${e.fin!.minute.toString().padLeft(2, '0')}'
                              : ''),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => HorarioItemDetailScreen(item: e),
                      ));
                    },
                    onLongPress: () => _showTareaActionsDialog(context, e),
                    trailing: widget.onEliminar == null
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => widget.onEliminar!(e),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
