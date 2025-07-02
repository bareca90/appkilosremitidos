import 'package:appkilosremitidos/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:appkilosremitidos/models/fishing_data.dart';
import 'package:appkilosremitidos/core/providers/fishing_data_provider.dart';

class HoursFormScreen extends StatefulWidget {
  final FishingData data;

  const HoursFormScreen({super.key, required this.data});

  @override
  State<HoursFormScreen> createState() => _HoursFormScreenState();
}

class _HoursFormScreenState extends State<HoursFormScreen> {
  late Map<String, TextEditingController> controllers;
  late Map<String, int> tieneCampos;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Formatear fechas existentes al formato yyyy-MM-dd HH:mm
    controllers = {
      'inicioPesca': TextEditingController(
        text: _formatDateTime(widget.data.inicioPesca),
      ),
      'finPesca': TextEditingController(
        text: _formatDateTime(widget.data.finPesca),
      ),
      'fechaCamaroneraPlanta': TextEditingController(
        text: _formatDateTime(widget.data.fechaCamaroneraPlanta),
      ),
      'fechaLlegadaCamaronera': TextEditingController(
        text: _formatDateTime(widget.data.fechaLlegadaCamaronera),
      ),
    };

    tieneCampos = {
      'inicioPesca': widget.data.tieneInicioPesca,
      'finPesca': widget.data.tieneFinPesca,
      'fechaCamaroneraPlanta': widget.data.tieneSalidaCamaronera,
      'fechaLlegadaCamaronera': widget.data.tieneLlegadaCamaronera,
    };
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';

    try {
      // Primero intenta parsear el formato actual (dd/MM/yyyy HH:mm)
      DateTime? dateTime;
      try {
        dateTime = DateFormat('dd/MM/yyyy HH:mm').parse(dateTimeStr);
      } catch (e) {
        // Si falla, intenta con el formato yyyy-MM-dd HH:mm
        dateTime = DateFormat('yyyy-MM-dd HH:mm').parse(dateTimeStr);
      }
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr; // Si no se puede parsear, devuelve el original
    }
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Horas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveData,
            tooltip: 'Guardar cambios',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(theme),
              const SizedBox(height: 24),
              _buildDateTimeSection(
                context,
                'INICIO PESCA',
                'inicioPesca',
                widget.data.tieneInicioPesca == 1,
              ),
              _buildDateTimeSection(
                context,
                'FIN PESCA',
                'finPesca',
                widget.data.tieneFinPesca == 1,
              ),
              _buildDateTimeSection(
                context,
                'SALIDA CAMARONERA',
                'fechaCamaroneraPlanta',
                widget.data.tieneSalidaCamaronera == 1,
              ),
              _buildDateTimeSection(
                context,
                'LLEGADA CAMARONERA',
                'fechaLlegadaCamaronera',
                widget.data.tieneLlegadaCamaronera == 1,
              ),
              const SizedBox(height: 32),
              _buildSaveButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Guía: ${widget.data.nroGuia}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Programa:', widget.data.nroPesca),
            _buildInfoRow('Camaronera:', widget.data.camaronera.trim()),
            _buildInfoRow('Piscina:', widget.data.piscina.trim()),
            _buildInfoRow(
              'Fecha:',
              DateFormat('dd/MM/yyyy').format(widget.data.fechaGuia),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection(
    BuildContext context,
    String title,
    String fieldKey,
    bool isReadOnly,
  ) {
    final isActive = tieneCampos[fieldKey] == 1;
    final hasValue = controllers[fieldKey]!.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isActive ? Colors.blue.shade100 : Colors.grey.shade300,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isActive,
                      onChanged: isReadOnly
                          ? null
                          : (value) {
                              setState(() {
                                tieneCampos[fieldKey] = value! ? 1 : 0;
                                // No limpiamos el valor al desmarcar
                              });
                            },
                    ),
                    Expanded(
                      child: Text(
                        isReadOnly ? 'Registro completado' : 'Registrar $title',
                        style: TextStyle(
                          color: isReadOnly ? Colors.green : Colors.black87,
                          fontWeight: isReadOnly
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (hasValue && isReadOnly)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                  ],
                ),
                if (isActive) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controllers[fieldKey],
                    decoration: InputDecoration(
                      labelText: 'Fecha y hora (yyyy-MM-dd HH:mm)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: isReadOnly
                            ? null
                            : () => _selectDateTime(
                                context,
                                controllers[fieldKey]!,
                              ),
                      ),
                      filled: isReadOnly,
                      fillColor: Colors.grey[100],
                    ),
                    readOnly: true,
                    style: TextStyle(
                      color: isReadOnly ? Colors.grey[600] : Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _selectDateTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initialDate = DateTime.now();

    // Intentar parsear la fecha actual si existe
    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateFormat('yyyy-MM-dd HH:mm').parse(controller.text);
      } catch (e) {
        // Si falla, usar la fecha actual
        initialDate = DateTime.now();
      }
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              dialogTheme: DialogThemeData(backgroundColor: Colors.white),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        setState(() {
          controller.text = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
        });
      }
    }
  }

  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save, size: 24),
        label: const Text(
          'GUARDAR CAMBIOS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 3,
        ),
        onPressed: _saveData,
      ),
    );
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<FishingDataProvider>(context, listen: false);
    final authToken = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      // Convertir los valores de tieneCampos a int antes de enviar
      // Preparar datos para guardar
      final hours = {
        'inicioPesca': controllers['inicioPesca']!.text.isNotEmpty
            ? controllers['inicioPesca']!.text
            : null,
        'finPesca': controllers['finPesca']!.text.isNotEmpty
            ? controllers['finPesca']!.text
            : null,
        'fechaCamaroneraPlanta':
            controllers['fechaCamaroneraPlanta']!.text.isNotEmpty
            ? controllers['fechaCamaroneraPlanta']!.text
            : null,
        'fechaLlegadaCamaronera':
            controllers['fechaLlegadaCamaronera']!.text.isNotEmpty
            ? controllers['fechaLlegadaCamaronera']!.text
            : null,
      };

      await provider.saveHours(widget.data.nroGuia, hours, authToken!);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos guardados correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
