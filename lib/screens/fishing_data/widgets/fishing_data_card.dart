import 'package:appkilosremitidos/models/fishing_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FishingDataCard extends StatelessWidget {
  final FishingData data;
  final VoidCallback onTap;
  final bool isKilosScreen;

  const FishingDataCard({
    super.key,
    required this.data,
    required this.onTap,
    this.isKilosScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con información clave
              _buildHeader(theme),

              const SizedBox(height: 12),

              // Información principal
              _buildMainInfo(dateFormat),

              const SizedBox(height: 8),

              // Sección dinámica según el tipo de pantalla
              if (isKilosScreen) _buildKilosInfo(),
              if (!isKilosScreen) _buildHoursInfo(),

              const SizedBox(height: 8),

              // Indicador de estado
              Align(
                alignment: Alignment.centerRight,
                child: _buildStatusIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Programa: ${data.nroPesca}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Guía: ${data.nroGuia}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        Chip(
          label: Text(data.tipoPesca),
          // ignore: deprecated_member_use
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ],
    );
  }

  Widget _buildMainInfo(DateFormat dateFormat) {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.business,
          label: 'Camaronera:',
          value: data.camaronera.trim(),
        ),
        _buildInfoRow(
          icon: Icons.water_drop,
          label: 'Piscina:',
          value: data.piscina.trim(),
        ),
        _buildInfoRow(
          icon: Icons.date_range,
          label: 'Fecha:',
          value: dateFormat.format(data.fechaGuia),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final displayValue = value.trim().isEmpty
        ? 'No especificado'
        : value.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              displayValue,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: value.trim().isEmpty ? Colors.grey : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKilosInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          'KILOS REMITIDOS:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: data.totalKilosRemitidos != null
                ? Colors.blue[50]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: data.totalKilosRemitidos != null
                  ? Colors.blue[100]!
                  : Colors.grey[300]!,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                data.totalKilosRemitidos != null
                    ? '${data.totalKilosRemitidos} kg'
                    : 'No registrado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: data.totalKilosRemitidos != null
                      ? Colors.blue[800]
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHoursInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          'REGISTRO DE HORAS:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        if (data.inicioPesca != null || data.finPesca != null) ...[
          if (data.inicioPesca != null)
            _buildHourDetail('Inicio:', data.inicioPesca!),
          if (data.finPesca != null) _buildHourDetail('Fin:', data.finPesca!),
        ] else
          const Text(
            'No se registraron horas',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
      ],
    );
  }

  Widget _buildHourDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final isComplete = isKilosScreen
        ? data.totalKilosRemitidos != null
        : data.inicioPesca != null && data.finPesca != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isComplete ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.pending,
            size: 16,
            color: isComplete ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            isComplete ? 'COMPLETO' : 'PENDIENTE',
            style: TextStyle(
              color: isComplete ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
