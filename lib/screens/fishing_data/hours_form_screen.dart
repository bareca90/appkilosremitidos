import 'package:appkilosremitidos/models/fishing_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:appkilosremitidos/core/providers/fishing_data_provider.dart';

class HoursFormScreen extends StatelessWidget {
  final FishingData data;
  final Map<String, TextEditingController> controllers;

  HoursFormScreen({super.key, required this.data})
    : controllers = {
        'inicioPesca': TextEditingController(text: data.inicioPesca ?? ''),
        'finPesca': TextEditingController(text: data.finPesca ?? ''),
        'fechaCamaroneraPlanta': TextEditingController(
          text: data.fechaCamaroneraPlanta ?? '',
        ),
        'fechaLlegadaCamaronera': TextEditingController(
          text: data.fechaLlegadaCamaronera ?? '',
        ),
      };

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FishingDataProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Horas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Guía: ${data.nroGuia}', style: TextStyle(fontSize: 18)),
            Text('Camaronera: ${data.camaronera}'),
            const SizedBox(height: 20),
            _buildTimeField(
              'Inicio Pesca',
              controllers['inicioPesca']!,
              context,
            ),
            _buildTimeField('Fin Pesca', controllers['finPesca']!, context),
            _buildTimeField(
              'Fecha Camaronera Planta',
              controllers['fechaCamaroneraPlanta']!,
              context,
            ),
            _buildTimeField(
              'Fecha Llegada Camaronera',
              controllers['fechaLlegadaCamaronera']!,
              context,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final hours = {
                  'inicioPesca': controllers['inicioPesca']!.text,
                  'finPesca': controllers['finPesca']!.text,
                  'fechaCamaroneraPlanta':
                      controllers['fechaCamaroneraPlanta']!.text,
                  'fechaLlegadaCamaronera':
                      controllers['fechaLlegadaCamaronera']!.text,
                };
                await provider.saveHours(data.nroGuia, hours);
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(
    String label,
    TextEditingController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                controller.text =
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              }
            },
          ),
        ),
      ),
    );
  }
}
