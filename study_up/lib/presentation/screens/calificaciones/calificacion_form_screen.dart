import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/calificaciones_provider.dart';
import '../../../application/materias_provider.dart';
import '../../../application/user_provider.dart';
import '../../../domain/entities/calificacion_entity.dart';
import '../../../domain/entities/materia_entity.dart';
import '../../../infrastructure/helpers/form_validators.dart';
import '../../../presentation/theme/app_theme.dart';

class CalificacionFormScreen extends ConsumerStatefulWidget {
  final CalificacionEntity? calificacion; // null = crear, no-null = editar

  const CalificacionFormScreen({super.key, this.calificacion});

  @override
  ConsumerState<CalificacionFormScreen> createState() =>
      _CalificacionFormScreenState();
}

class _CalificacionFormScreenState
    extends ConsumerState<CalificacionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notaCtrl = TextEditingController();
  final _porcentajeCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  String? _selectedMateriaId;
  bool _isLoading = false;

  bool get isEditing => widget.calificacion != null;

  @override
  void initState() {
    super.initState();
    if (widget.calificacion != null) {
      _selectedMateriaId = widget.calificacion!.materiaId;
      _notaCtrl.text = widget.calificacion!.nota.toString();
      _porcentajeCtrl.text = widget.calificacion!.porcentaje.toString();
      _descripcionCtrl.text = widget.calificacion!.descripcion;
    }
  }

  @override
  void dispose() {
    _notaCtrl.dispose();
    _porcentajeCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarCalificacion() async {
    print("Intentando guardar calificación...");
    if (!_formKey.currentState!.validate()) {
      print("Validación de formulario fallida");
      return;
    }

    if (_selectedMateriaId == null) {
      print("Materia no seleccionada");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar una materia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = ref.read(userProvider);
    if (user == null) {
      print("Usuario no autenticado");
      return;
    }

    // Validar porcentaje acumulado antes de crear/actualizar
    double acumulado = 0;
    try {
      final existentes = await ref.read(calificacionesPorMateriaStreamProvider(
          (user.uid, _selectedMateriaId!)).future);
      for (final c in existentes) {
        // Excluir la que se edita (para actualización) para recalcular sin duplicar
        if (isEditing && c.id == widget.calificacion?.id) continue;
        acumulado += c.porcentaje;
      }
    } catch (e) {
      // Si hay error, asumimos 0 acumulado
      acumulado = 0;
    }

    final nuevoPorcentaje = double.tryParse(_porcentajeCtrl.text.trim()) ?? 0;
    if (acumulado + nuevoPorcentaje > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'El porcentaje excede 100%. Acumulado existente: ${acumulado.toStringAsFixed(1)}%. Nuevo: ${nuevoPorcentaje.toStringAsFixed(1)}%'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final calificacion = CalificacionEntity(
        id: widget.calificacion?.id,
        userId: user.uid,
        materiaId: _selectedMateriaId!,
        nota: double.parse(_notaCtrl.text.trim()),
        porcentaje: double.parse(_porcentajeCtrl.text.trim()),
        descripcion: _descripcionCtrl.text.trim().isEmpty
            ? 'Sin descripción'
            : _descripcionCtrl.text.trim(),
        fecha: widget.calificacion?.fecha ?? DateTime.now(),
      );

      final notifier =
          ref.read(calificacionesNotifierProvider(user.uid).notifier);

      if (isEditing) {
        await notifier.actualizarCalificacion(calificacion);
      } else {
        await notifier.crearCalificacion(calificacion);
      }

      if (mounted) {
        Navigator.pop(context); // salir primero
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Calificación actualizada exitosamente'
                  : 'Calificación creada exitosamente',
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

  Future<void> _handleDelete() async {
    if (!isEditing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar calificación?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(userProvider);
      if (user == null) return;

      await ref
          .read(calificacionesNotifierProvider(user.uid).notifier)
          .eliminarCalificacion(widget.calificacion!.id!);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calificación eliminada'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
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
    final user = ref.watch(userProvider);
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Debes iniciar sesión'),
        ),
      );
    }

    // Capturar materiaId fijo si viene en argumentos (desde MateriaDetailScreen)
    final args = ModalRoute.of(context)?.settings.arguments;
    String? materiaBloqueadaId;
    if (args is String) {
      materiaBloqueadaId = args; // se pasa solo el id
      _selectedMateriaId ??= materiaBloqueadaId; // asignar si aún no está
    }

    final materiasAsync = ref.watch(materiasStreamProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Calificación' : 'Nueva Calificación'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
            ),
          ),
        ),
        actions: isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: _isLoading ? null : _handleDelete,
                  tooltip: 'Eliminar',
                ),
              ]
            : null,
      ),
      body: materiasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error al cargar materias: $error'),
        ),
        data: (materias) {
          if (materias.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes materias registradas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea primero una materia para agregar calificaciones',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/materias');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Materia'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),

                  // Si materia viene bloqueada mostrar info, sino dropdown
                  if (materiaBloqueadaId != null)
                    Card(
                      elevation: 0,
                      color: AppTheme.primaryPurple.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.school,
                                color: AppTheme.primaryPurple),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                materias
                                    .firstWhere(
                                      (m) => m.id == materiaBloqueadaId,
                                      orElse: () => materias.first,
                                    )
                                    .nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('(Materia fijada)',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                    )
                  else
                    _buildMateriaDropdown(materias),
                  const SizedBox(height: 16),

                  // Campo de nota
                  TextFormField(
                    controller: _notaCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nota (1.0 - 7.0)',
                      hintText: 'Ej: 6.5',
                      prefixIcon: const Icon(Icons.grade),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Nota mínima de aprobación: 4.0',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: FormValidators.validateNotaChilena,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Campo de porcentaje
                  TextFormField(
                    controller: _porcentajeCtrl,
                    decoration: InputDecoration(
                      labelText: 'Porcentaje (%)',
                      hintText: 'Ej: 30',
                      prefixIcon: const Icon(Icons.percent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Cuánto vale esta evaluación (0-100)',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: FormValidators.validatePorcentaje,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Campo de descripción
                  TextFormField(
                    controller: _descripcionCtrl,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Ej: Examen Final, Parcial 1, Tarea 3',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 32),

                  // Botón guardar
                  ElevatedButton(
                    onPressed: _isLoading ? null : _guardarCalificacion,
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
                            isEditing
                                ? 'Guardar Cambios'
                                : 'Crear Calificación',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
  }

  Widget _buildInfoCard() {
    return Card(
      color: AppTheme.primaryBlue.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryBlue,
                ),
                SizedBox(width: 8),
                Text(
                  'Sistema de Calificación Chileno',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Escala:', '1.0 - 7.0'),
            _buildInfoRow('Aprobación:', '4.0 o superior'),
            _buildInfoRow('Decimales:', 'Permitidos (ej: 5.5, 6.8)'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMateriaDropdown(List<MateriaEntity> materias) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedMateriaId,
      decoration: InputDecoration(
        labelText: 'Materia',
        prefixIcon: const Icon(Icons.school),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      hint: const Text('Selecciona una materia'),
      validator: (value) {
        if (value == null) {
          return 'Debes seleccionar una materia';
        }
        return null;
      },
      items: materias.map((materia) {
        return DropdownMenuItem<String>(
          value: materia.id,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: materia.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${materia.codigo} - ${materia.nombre}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: _isLoading
          ? null
          : (value) {
              setState(() {
                _selectedMateriaId = value;
              });
            },
    );
  }
}
