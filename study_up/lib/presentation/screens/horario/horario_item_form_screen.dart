// filepath: lib/presentation/screens/horario/horario_item_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../../../application/user_provider.dart';
import '../../../application/materias_provider.dart';
import '../../../application/horario_items_provider.dart';
import '../../../domain/entities/horario_item_entity.dart';
import '../../theme/app_theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HorarioItemFormScreen extends ConsumerStatefulWidget {
  final HorarioItemEntity? item;
  const HorarioItemFormScreen({super.key, this.item});

  @override
  ConsumerState<HorarioItemFormScreen> createState() =>
      _HorarioItemFormScreenState();
}

class _HorarioItemFormScreenState extends ConsumerState<HorarioItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  String? _selectedMateriaId;
  String _selectedTipo = 'tarea';
  DateTime _inicio = DateTime.now();
  DateTime? _fin;
  int? _recordatorio; // minutos antes
  Color _selectedColor = AppTheme.primaryPurple;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    // Inicializar notificaciones locales
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    if (widget.item != null) {
      _tituloCtrl.text = widget.item!.titulo;
      _descripcionCtrl.text = widget.item!.descripcion ?? '';
      _selectedMateriaId = widget.item!.materiaId;
      _selectedTipo = widget.item!.tipo;
      _inicio = widget.item!.inicio;
      _fin = widget.item!.fin;
      _recordatorio = widget.item!.recordatorioMinutosAntes;
      _selectedColor = widget.item!.color;
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esInicio) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: esInicio ? _inicio : (_fin ?? _inicio),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (fecha == null) return;
    if (!mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(esInicio ? _inicio : (_fin ?? _inicio)),
    );
    if (hora == null) return;

    final dateTime = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora.hour,
      hora.minute,
    );

    setState(() {
      if (esInicio) {
        _inicio = dateTime;
      } else {
        _fin = dateTime;
      }
    });
  }

  Future<bool> _solicitarPermisoNotificacion() async {
    bool granted = true;
    // Android: usar permission_handler
    if (Theme.of(context).platform == TargetPlatform.android) {
      final status = await Permission.notification.request();
      granted = status.isGranted;
    }
    // iOS: usar plugin nativo
    final iosPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final result = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = granted && (result ?? false);
    }
    return granted;
  }

  Future<void> _programarNotificacion(HorarioItemEntity item) async {
    if (item.recordatorioMinutosAntes != null &&
        item.inicio.isAfter(DateTime.now())) {
      final permiso = await _solicitarPermisoNotificacion();
      if (!permiso) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se concedieron permisos de notificación'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      final scheduledTime = item.inicio
          .subtract(Duration(minutes: item.recordatorioMinutosAntes!));
      await flutterLocalNotificationsPlugin.zonedSchedule(
        item.hashCode,
        'Recordatorio: ${item.titulo}',
        item.descripcion ?? '',
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails('horario_channel', 'Horario',
              channelDescription: 'Recordatorios de eventos/tareas'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(userProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final item = HorarioItemEntity(
        id: widget.item?.id,
        userId: user.uid,
        materiaId: _selectedMateriaId,
        titulo: _tituloCtrl.text.trim(),
        tipo: _selectedTipo,
        inicio: _inicio,
        fin: _fin,
        recordatorioMinutosAntes: _recordatorio,
        descripcion: _descripcionCtrl.text.trim().isEmpty
            ? null
            : _descripcionCtrl.text.trim(),
        color: _selectedColor,
      );

      final notifier =
          ref.read(horarioItemsNotifierProvider(user.uid).notifier);
      if (widget.item == null) {
        await notifier.crear(item);
      } else {
        await notifier.actualizar(item);
      }
      await _programarNotificacion(item);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                widget.item == null ? 'Evento creado' : 'Evento actualizado'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión')),
      );
    }

    final materiasAsync = ref.watch(materiasStreamProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Nuevo Evento' : 'Editar Evento'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloCtrl,
                decoration: InputDecoration(
                  labelText: 'Título',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Tipo
              DropdownButtonFormField<String>(
                value: _selectedTipo,
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'tarea', child: Text('Tarea')),
                  DropdownMenuItem(value: 'prueba', child: Text('Prueba')),
                  DropdownMenuItem(value: 'examen', child: Text('Examen')),
                  DropdownMenuItem(value: 'clase', child: Text('Clase')),
                  DropdownMenuItem(value: 'otro', child: Text('Otro')),
                ],
                onChanged: (v) => setState(() => _selectedTipo = v!),
              ),
              const SizedBox(height: 16),

              // Materia (opcional)
              materiasAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (materias) {
                  return DropdownButtonFormField<String>(
                    value: _selectedMateriaId,
                    decoration: InputDecoration(
                      labelText: 'Materia (Opcional)',
                      prefixIcon: const Icon(Icons.school),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Sin materia')),
                      ...materias.map((m) =>
                          DropdownMenuItem(value: m.id, child: Text(m.nombre))),
                    ],
                    onChanged: (v) => setState(() => _selectedMateriaId = v),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Fecha inicio
              ListTile(
                title: const Text('Inicio'),
                subtitle: Text(
                    '${_inicio.day}/${_inicio.month}/${_inicio.year} ${_inicio.hour.toString().padLeft(2, '0')}:${_inicio.minute.toString().padLeft(2, '0')}'),
                leading: const Icon(Icons.access_time),
                onTap: () => _seleccionarFecha(context, true),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              const SizedBox(height: 12),

              // Fecha fin (opcional)
              ListTile(
                title: const Text('Fin (Opcional)'),
                subtitle: Text(_fin == null
                    ? 'Sin fin'
                    : '${_fin!.day}/${_fin!.month}/${_fin!.year} ${_fin!.hour.toString().padLeft(2, '0')}:${_fin!.minute.toString().padLeft(2, '0')}'),
                leading: const Icon(Icons.event),
                trailing: _fin != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _fin = null),
                      )
                    : null,
                onTap: () => _seleccionarFecha(context, false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              const SizedBox(height: 16),

              // Recordatorio
              DropdownButtonFormField<int?>(
                value: _recordatorio,
                decoration: InputDecoration(
                  labelText: 'Recordatorio',
                  prefixIcon: const Icon(Icons.notifications),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(
                      value: null, child: Text('Sin recordatorio')),
                  DropdownMenuItem(value: 10, child: Text('10 minutos antes')),
                  DropdownMenuItem(value: 30, child: Text('30 minutos antes')),
                  DropdownMenuItem(value: 60, child: Text('1 hora antes')),
                  DropdownMenuItem(value: 1440, child: Text('1 día antes')),
                ],
                onChanged: (v) => setState(() => _recordatorio = v),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descripcionCtrl,
                decoration: InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.item == null ? 'Crear Evento' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
