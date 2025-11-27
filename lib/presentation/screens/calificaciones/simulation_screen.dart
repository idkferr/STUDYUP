// filepath: lib/presentation/screens/calificaciones/simulation_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final _notaCtrl = TextEditingController();
  final _porcentajeCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  List<double> _notas = [];
  List<double> _porcentajes = [];
  List<String> _descripciones = [];

  double get porcentajeAcumulado => _porcentajes.fold(0, (a, b) => a + b);
  double get promedioPonderado {
    double sumaPonderada = 0;
    for (int i = 0; i < _notas.length; i++) {
      sumaPonderada += _notas[i] * _porcentajes[i];
    }
    return porcentajeAcumulado > 0 ? sumaPonderada / porcentajeAcumulado : 0;
  }

  String get estado {
    if (porcentajeAcumulado < 39.5) {
      return 'Falta progreso para aprobar';
    }
    if (promedioPonderado >= 4.0) {
      return 'APRUEBA';
    }
    if (promedioPonderado >= 3.7) {
      return 'En riesgo';
    }
    return 'NO APRUEBA';
  }

  void _agregarNota() {
    final nota = double.tryParse(_notaCtrl.text.trim());
    final porcentaje = double.tryParse(_porcentajeCtrl.text.trim());
    final descripcion = _descripcionCtrl.text.trim();
    if (nota == null || porcentaje == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa valores válidos')),
      );
      return;
    }
    if (nota < 1.0 || nota > 7.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota debe estar entre 1.0 y 7.0')),
      );
      return;
    }
    if (porcentaje <= 0 || porcentaje > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Porcentaje debe estar entre 1 y 100')),
      );
      return;
    }
    if (porcentajeAcumulado + porcentaje > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'El porcentaje total no puede exceder 100%. Acumulado: ${porcentajeAcumulado.toStringAsFixed(1)}%')),
      );
      return;
    }
    setState(() {
      _notas.add(nota);
      _porcentajes.add(porcentaje);
      _descripciones.add(descripcion.isEmpty ? 'Simulación' : descripcion);
      _notaCtrl.clear();
      _porcentajeCtrl.clear();
      _descripcionCtrl.clear();
    });
  }

  void _eliminarNota(int index) {
    setState(() {
      _notas.removeAt(index);
      _porcentajes.removeAt(index);
      _descripciones.removeAt(index);
    });
  }

  @override
  void dispose() {
    _notaCtrl.dispose();
    _porcentajeCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador de Calificaciones'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: AppTheme.primaryBlue),
                        const SizedBox(width: 8),
                        const Text('Simulador de Notas',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        'Agrega calificaciones hipotéticas para ver cómo afectarían tu promedio. Las notas simuladas NO se guardan.',
                        style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('• Pasas con promedio ≥ 4.0 y progreso ≥ 39.5%',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _porcentajeCtrl,
              decoration: InputDecoration(
                labelText: 'Porcentaje (%)',
                hintText: 'Ej: 30',
                prefixIcon: const Icon(Icons.percent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Cuánto vale esta evaluación (1-100)',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
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
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _agregarNota,
              icon: const Icon(Icons.add),
              label: const Text('Agregar Nota'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            if (_notas.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notas simuladas:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...List.generate(
                      _notas.length,
                      (i) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Container(
                                width: 54,
                                height: 54,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  _notas[i].toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              title: Text(_descripciones[i]),
                              subtitle: Text('Porcentaje: ${_porcentajes[i]}%'),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _eliminarNota(i),
                                tooltip: 'Eliminar',
                              ),
                              onTap: () {
                                // Edición rápida de nota
                                _notaCtrl.text = _notas[i].toString();
                                _porcentajeCtrl.text =
                                    _porcentajes[i].toString();
                                _descripcionCtrl.text = _descripciones[i];
                                _eliminarNota(i);
                              },
                            ),
                          )),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _notas.clear();
                          _porcentajes.clear();
                          _descripciones.clear();
                        });
                      },
                      icon: const Icon(Icons.cleaning_services,
                          color: AppTheme.primaryPurple),
                      label: const Text('Limpiar todo'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            // Barra de progreso visual
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Progreso acumulado:',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (porcentajeAcumulado.clamp(0, 100)) / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(AppTheme.primaryPurple),
                  ),
                  const SizedBox(height: 4),
                  Text('${porcentajeAcumulado.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Card(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Promedio ponderado: ${promedioPonderado.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (porcentajeAcumulado < 100)
                      Text(
                        'Falta ${(100 - porcentajeAcumulado).toStringAsFixed(1)}% para completar el 100%.',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 16,
                        ),
                      )
                    else
                      Row(
                        children: [
                          if (estado == 'APRUEBA')
                            const Icon(Icons.verified,
                                color: Colors.green, size: 32)
                          else if (estado == 'En riesgo')
                            const Icon(Icons.warning_amber_rounded,
                                color: Colors.orange, size: 32)
                          else if (estado == 'NO APRUEBA')
                            const Icon(Icons.cancel,
                                color: Colors.red, size: 32)
                          else
                            const Icon(Icons.info_outline,
                                color: Colors.grey, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Estado: $estado',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: estado == 'APRUEBA'
                                      ? Colors.green
                                      : (estado == 'En riesgo'
                                          ? Colors.orange
                                          : (estado == 'NO APRUEBA'
                                              ? Colors.red
                                              : Colors.grey)),
                                )),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
