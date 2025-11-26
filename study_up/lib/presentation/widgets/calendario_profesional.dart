import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// Widget de calendario profesional con vistas de mes, semana y día.
/// Los eventos/tareas se muestran debajo del número del día en modo mes.
class CalendarioProfesional extends StatefulWidget {
  final Map<DateTime, List<String>> eventos; // Puedes cambiar String por tu modelo de evento
  final Color primaryColor;
  final Color accentColor;

  const CalendarioProfesional({
    super.key,
    required this.eventos,
    this.primaryColor = const Color(0xFF1565C0),
    this.accentColor = const Color(0xFF7E57C2),
  });

  @override
  State<CalendarioProfesional> createState() => _CalendarioProfesionalState();
}

class _CalendarioProfesionalState extends State<CalendarioProfesional> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selector de vista
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ToggleButtons(
              isSelected: [
                _calendarFormat == CalendarFormat.month,
                _calendarFormat == CalendarFormat.week,
                _calendarFormat == CalendarFormat.twoWeeks,
              ],
              onPressed: (index) {
                setState(() {
                  if (index == 0) _calendarFormat = CalendarFormat.month;
                  if (index == 1) _calendarFormat = CalendarFormat.week;
                  if (index == 2) _calendarFormat = CalendarFormat.twoWeeks;
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: widget.primaryColor,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Mes'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Semana'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('2 Semanas'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        TableCalendar<String>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: (day) => widget.eventos[DateTime(day.year, day.month, day.day)] ?? [],
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: widget.primaryColor,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: widget.accentColor,
              shape: BoxShape.circle,
            ),
            markersAlignment: Alignment.bottomCenter,
            markerSize: 6,
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final events = widget.eventos[DateTime(day.year, day.month, day.day)] ?? [];
              return _buildDayCell(day, events, false);
            },
            todayBuilder: (context, day, focusedDay) {
              final events = widget.eventos[DateTime(day.year, day.month, day.day)] ?? [];
              return _buildDayCell(day, events, true);
            },
            selectedBuilder: (context, day, focusedDay) {
              final events = widget.eventos[DateTime(day.year, day.month, day.day)] ?? [];
              return _buildDayCell(day, events, true, selected: true);
            },
          ),
        ),
        const SizedBox(height: 16),
        if (_calendarFormat == CalendarFormat.week || _calendarFormat == CalendarFormat.twoWeeks)
          _buildWeekView(),
        if (_calendarFormat == CalendarFormat.month && _selectedDay != null)
          _buildDayEvents(_selectedDay!),
      ],
    );
  }

  Widget _buildDayCell(DateTime day, List<String> events, bool isToday, {bool selected = false}) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected
                ? widget.primaryColor
                : isToday
                    ? widget.accentColor.withOpacity(0.2)
                    : null,
          ),
          padding: const EdgeInsets.all(8),
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : isToday
                      ? widget.primaryColor
                      : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Eventos debajo del número
        ...events.take(3).map((e) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  e,
                  style: const TextStyle(fontSize: 10, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            )),
        if (events.length > 3)
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text('...', style: TextStyle(fontSize: 10)),
          ),
      ],
    );
  }

  Widget _buildDayEvents(DateTime day) {
    final events = widget.eventos[DateTime(day.year, day.month, day.day)] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Eventos para ${day.day}/${day.month}/${day.year}:',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        ...events.map((e) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.event),
                title: Text(e),
              ),
            )),
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No hay eventos para este día.'),
          ),
      ],
    );
  }

  Widget _buildWeekView() {
    // Aquí puedes implementar una vista semanal profesional (grilla de horas/días)
    // Por simplicidad, mostramos los eventos de la semana seleccionada
    final startOfWeek = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Eventos de la semana:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...days.map((d) {
          final events = widget.eventos[DateTime(d.year, d.month, d.day)] ?? [];
          return events.isNotEmpty
              ? Card(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    leading: const Icon(Icons.event_note),
                    title: Text('${d.day}/${d.month}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: events.map((e) => Text(e)).toList(),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }),
      ],
    );
  }
}
