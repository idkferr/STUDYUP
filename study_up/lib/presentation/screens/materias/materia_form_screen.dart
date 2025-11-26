// filepath: lib/presentation/screens/materias/materia_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/materias_provider.dart';
import '../../../application/user_provider.dart';
import '../../../domain/entities/materia_entity.dart';
import '../../../domain/entities/horario_item_entity.dart';
import '../../../application/horario_items_provider.dart';
import '../../theme/app_theme.dart';

class MateriaFormScreen extends ConsumerStatefulWidget {
  const MateriaFormScreen({super.key});

  @override
  ConsumerState<MateriaFormScreen> createState() => _MateriaFormScreenState();
}

class _MateriaFormScreenState extends ConsumerState<MateriaFormScreen> {
    // Días de la semana en español
    final List<String> _diasSemana = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];

    // Estado de selección de días y horas
    late Map<String, bool> _diasSeleccionados;
    late Map<String, TimeOfDay?> _horaInicioPorDia;
    late Map<String, TimeOfDay?> _horaFinPorDia;

    @override
    void initState() {
      super.initState();
      _diasSeleccionados = {for (var d in _diasSemana) d: false};
      _horaInicioPorDia = {for (var d in _diasSemana) d: null};
      _horaFinPorDia = {for (var d in _diasSemana) d: null};
    }
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _creditosController = TextEditingController();
  final _semestreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _horarioController = TextEditingController();

  Color _selectedColor = AppTheme.primaryBlue;
  bool _isLoading = false;
  MateriaEntity? _materiaExistente;

  // Eliminados campos no usados: _fechaInicio, _horaInicio, _duracion, _usarSelectorVisual
  bool _agregarAlHorario = false;

  final List<Color> _coloresDisponibles = [
    AppTheme.primaryBlue,
    AppTheme.primaryPurple,
    AppTheme.accentGreen,
    AppTheme.accentOrange,
    Colors.red,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final materia =
        ModalRoute.of(context)?.settings.arguments as MateriaEntity?;
    if (materia != null && _materiaExistente == null) {
      _materiaExistente = materia;
      _codigoController.text = materia.codigo;
      _nombreController.text = materia.nombre;
      _creditosController.text = materia.creditos.toString();
      _semestreController.text = materia.semestre;
      _descripcionController.text = materia.descripcion ?? '';
      _horarioController.text = materia.horario ?? '';
      _selectedColor = materia.color;
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _creditosController.dispose();
    _semestreController.dispose();
    _descripcionController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  Future<void> _guardarMateria() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(userProvider);
    if (user == null) return;

    // Validar formato horario simple (Lun 09:00-10:30, Mie 11:00-12:30)
    final horarioText = _horarioController.text.trim();
    if (horarioText.isNotEmpty) {
      final horarioRegex = RegExp(
          r'^[A-Za-zÁÉÍÓÚáéíóú]{3}\s\d{2}:\d{2}-\d{2}:\d{2}(,\s*[A-Za-zÁÉÍÓÚáéíóú]{3}\s\d{2}:\d{2}-\d{2}:\d{2})*$');
      if (!horarioRegex.hasMatch(horarioText)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Formato de horario inválido. Ej: Lun 09:00-10:30, Mie 11:00-12:30'),
          backgroundColor: Colors.red,
        ));
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(materiasNotifierProvider(user.uid).notifier);
      // Verificar código único (excluyendo si se edita la misma materia)
      final codigo = _codigoController.text.trim().toUpperCase();
      final codigoExiste =
          await notifier.existeCodigo(codigo, excludeId: _materiaExistente?.id);
      if (codigoExiste) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('El código ya existe para otra materia'),
          backgroundColor: Colors.red,
        ));
        setState(() => _isLoading = false);
        return;
      }

      final materia = MateriaEntity(
        id: _materiaExistente?.id,
        userId: user.uid,
        codigo: codigo,
        nombre: _nombreController.text.trim(),
        creditos: int.parse(_creditosController.text.trim()),
        semestre: _semestreController.text.trim(),
        color: _selectedColor,
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        horario: horarioText.isEmpty ? null : horarioText,
      );

      // Save or update the materia and capture the saved entity (with ID)
      late final MateriaEntity savedMateria;
      if (_materiaExistente == null) {
        savedMateria = await notifier.crearMateria(materia);
      } else {
        await notifier.actualizarMateria(materia);
        savedMateria = materia;
      }

      // Si el usuario seleccionó agregar al calendario, crear eventos
      if (_agregarAlHorario) {
        // Crear eventos para cada día seleccionado con su hora de inicio y fin
        final now = DateTime.now();
        for (final dia in _diasSemana) {
          if (_diasSeleccionados[dia] == true &&
              _horaInicioPorDia[dia] != null &&
              _horaFinPorDia[dia] != null) {
            // Calcular el próximo día de la semana correspondiente
            final diaIndex = _diasSemana.indexOf(dia); // 0=Lunes ... 6=Domingo
            int daysToAdd = (diaIndex - (now.weekday - 1));
            if (daysToAdd < 0) daysToAdd += 7;
            final fecha = now.add(Duration(days: daysToAdd));
            final inicio = DateTime(
              fecha.year,
              fecha.month,
              fecha.day,
              _horaInicioPorDia[dia]!.hour,
              _horaInicioPorDia[dia]!.minute,
            );
            final fin = DateTime(
              fecha.year,
              fecha.month,
              fecha.day,
              _horaFinPorDia[dia]!.hour,
              _horaFinPorDia[dia]!.minute,
            );
            final materiaIdForEvent = savedMateria.id ?? materia.id;
            final evento = HorarioItemEntity(
              userId: user.uid,
              materiaId: materiaIdForEvent,
              titulo: savedMateria.nombre,
              tipo: 'clase',
              inicio: inicio,
              fin: fin,
              color: savedMateria.color,
            );
            try {
              // Debug log to help trace creation
              print('[Materias] Creando evento desde horario parser para materiaId=$materiaIdForEvent titulo=${evento.titulo} inicio=${evento.inicio}');
                await ref
                  .read(horarioItemsNotifierProvider(user.uid).notifier)
                  .crear(evento);
                print('[Materias] Evento creado (notifier.crear)');
            } catch (e) {
              print('[Materias][ERROR] al crear evento: $e');
            }
          }
        }
      }

      // Preguntar si desea agregar como evento al horario (solo si definió horario)
      if (mounted && materia.horario != null && materia.horario!.isNotEmpty) {
        final agregar = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Añadir al Horario'),
            content: Text(
                '¿Deseas crear eventos de horario para "${materia.nombre}" ahora?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('No')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Sí')),
            ],
          ),
        );
        if (agregar == true) {
          // Parsear `materia.horario` y crear eventos automáticos
          if (materia.horario != null && materia.horario!.trim().isNotEmpty) {
            final horarioText = materia.horario!.trim();
            // Ejemplo esperado: "Lun 09:00-10:30, Mie 11:00-12:30"
            final parts = horarioText.split(',');
            final Map<String, int> diaMap = {
              'LUN': 1,
              'MAR': 2,
              'MIE': 3,
              'MIÉ': 3,
              'JUE': 4,
              'VIE': 5,
              'SAB': 6,
              'DOM': 7,
            };
            final now = DateTime.now();
            for (final part in parts) {
              final p = part.trim();
              final m = RegExp(r'^([A-Za-zÁÉÍÓÚáéíóú]{3})\s+(\d{2}:\d{2})-(\d{2}:\d{2})$').firstMatch(p);
              if (m != null) {
                final dayAbbr = m.group(1)!.toUpperCase();
                final start = m.group(2)!;
                final end = m.group(3)!;
                final weekday = diaMap[dayAbbr.replaceAll('É', 'É')];
                if (weekday == null) continue;
                final startParts = start.split(':').map((s) => int.parse(s)).toList();
                final endParts = end.split(':').map((s) => int.parse(s)).toList();
                int daysToAdd = (weekday - now.weekday);
                if (daysToAdd < 0) daysToAdd += 7;
                final fecha = now.add(Duration(days: daysToAdd));
                final inicio = DateTime(fecha.year, fecha.month, fecha.day, startParts[0], startParts[1]);
                final fin = DateTime(fecha.year, fecha.month, fecha.day, endParts[0], endParts[1]);
                final evento = HorarioItemEntity(
                  userId: user.uid,
                  materiaId: savedMateria.id,
                  titulo: savedMateria.nombre,
                  tipo: 'clase',
                  inicio: inicio,
                  fin: fin,
                  color: savedMateria.color,
                );
                try {
                  await ref
                      .read(horarioItemsNotifierProvider(user.uid).notifier)
                      .crear(evento);
                } catch (_) {}
              }
            }
          }
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _materiaExistente == null
                  ? 'Materia creada exitosamente'
                  : 'Materia actualizada exitosamente',
            ),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _materiaExistente == null ? 'Nueva Materia' : 'Editar Materia'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Código
              TextFormField(
                controller: _codigoController,
                decoration: InputDecoration(
                  labelText: 'Código de la Materia',
                  hintText: 'Ej: CS101',
                  prefixIcon: const Icon(Icons.tag),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El código es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Materia',
                  hintText: 'Ej: Programación I',
                  prefixIcon: const Icon(Icons.book),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Créditos
              TextFormField(
                controller: _creditosController,
                decoration: InputDecoration(
                  labelText: 'Créditos',
                  hintText: 'Ej: 4',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Los créditos son obligatorios';
                  }
                  final creditos = int.tryParse(value.trim());
                  if (creditos == null || creditos <= 0) {
                    return 'Ingrese un número válido mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Semestre
              TextFormField(
                controller: _semestreController,
                decoration: InputDecoration(
                  labelText: 'Semestre',
                  hintText: 'Ej: 2024-1',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El semestre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  hintText: 'Detalles adicionales sobre la materia',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Selección de días y horas (diseño horizontal, redondo e interactivo)
              Text('Horario (opcional)', style: Theme.of(context).textTheme.titleMedium),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _diasSemana.map((dia) {
                    final seleccionado = _diasSeleccionados[dia]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _diasSeleccionados[dia] = !seleccionado;
                                if ((_diasSeleccionados[dia] ?? false) && _horaInicioPorDia[dia] == null) {
                                  _horaInicioPorDia[dia] = const TimeOfDay(hour: 8, minute: 0);
                                  _horaFinPorDia[dia] = const TimeOfDay(hour: 9, minute: 0);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: seleccionado ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                                shape: BoxShape.circle,
                                boxShadow: seleccionado
                                    ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), blurRadius: 8)]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  dia.substring(0, 3),
                                  style: TextStyle(
                                    color: seleccionado ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (seleccionado) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: _horaInicioPorDia[dia] ?? const TimeOfDay(hour: 8, minute: 0),
                                    );
                                    if (picked != null) {
                                      setState(() => _horaInicioPorDia[dia] = picked);
                                    }
                                  },
                                  child: Text('Inicio: ${_horaInicioPorDia[dia]?.format(context) ?? '--:--'}'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: _horaFinPorDia[dia] ?? const TimeOfDay(hour: 9, minute: 0),
                                    );
                                    if (picked != null) {
                                      setState(() => _horaFinPorDia[dia] = picked);
                                    }
                                  },
                                  child: Text('Fin: ${_horaFinPorDia[dia]?.format(context) ?? '--:--'}'),
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _agregarAlHorario,
                    onChanged: (val) => setState(() => _agregarAlHorario = val ?? false),
                  ),
                  const Text('Agregar al calendario'),
                ],
              ),
              const SizedBox(height: 16),

              // Selector de color
              const Text(
                'Color de identificación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _coloresDisponibles.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 28)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Botón guardar
              ElevatedButton(
                onPressed: _isLoading ? null : _guardarMateria,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _materiaExistente == null
                            ? 'Crear Materia'
                            : 'Guardar Cambios',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
