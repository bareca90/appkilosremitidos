/* import 'package:appkilosremitidos/core/providers/kilos_provider.dart';
import 'package:appkilosremitidos/models/kilos_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditKilosScreen extends StatefulWidget {
  final KilosRemitidos kilos;

  const EditKilosScreen({super.key, required this.kilos});

  @override
  State<EditKilosScreen> createState() => _EditKilosScreenState();
}

class _EditKilosScreenState extends State<EditKilosScreen> {
  late TextEditingController _kilosController;

  @override
  void initState() {
    super.initState();
    _kilosController = TextEditingController(
      text: widget.kilos.totalKilosRemitidos.toString(),
    );
  }

  @override
  void dispose() {
    _kilosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kilosProvider = Provider.of<KilosProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Kilos Remitidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final updatedKilos = widget.kilos.copyWith(
                totalKilosRemitidos: int.parse(_kilosController.text),
              );
              await kilosProvider.updateKilos(updatedKilos);
              if (kilosProvider.errorMessage == null) {
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _kilosController,
              decoration: const InputDecoration(
                labelText: 'Total Kilos Remitidos',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            if (kilosProvider.errorMessage != null)
              Text(
                kilosProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
 */
