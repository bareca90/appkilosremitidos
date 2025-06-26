import 'package:flutter/material.dart';
import '../../../models/kilos_model.dart';

class KilosCard extends StatelessWidget {
  final KilosRemitidos kilos;

  const KilosCard({super.key, required this.kilos});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Guía: ${kilos.nroGuia}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(kilos.tipoPesca),
                  backgroundColor: Colors.blue[50],
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Pesca:', kilos.nroPesca),
            _buildInfoRow('Camaronera:', kilos.camaronera),
            _buildInfoRow('Piscina:', kilos.piscina),
            _buildInfoRow('Kilos:', '${kilos.totalKilosRemitidos} kg'),
            _buildInfoRow('Fecha:', _formatDate(kilos.fechaGuia)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
