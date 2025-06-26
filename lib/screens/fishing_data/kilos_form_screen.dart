import 'package:appkilosremitidos/models/fishing_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appkilosremitidos/core/providers/fishing_data_provider.dart';

class KilosFormScreen extends StatelessWidget {
  final FishingData data;

  const KilosFormScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FishingDataProvider>(context, listen: false);
    final kilosController = TextEditingController(
      text: data.totalKilosRemitidos?.toString() ?? '',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Kilos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Guía: ${data.nroGuia}', style: TextStyle(fontSize: 18)),
            Text('Camaronera: ${data.camaronera}'),
            Text('Piscina: ${data.piscina}'),
            const SizedBox(height: 20),
            TextFormField(
              controller: kilosController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Kilos Remitidos',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await provider.saveKilos(
                  data.nroGuia,
                  int.parse(kilosController.text),
                );
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
}
