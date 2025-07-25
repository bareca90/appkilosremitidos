import 'package:appkilosremitidos/models/material_pesca.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MaterialPescaCard extends StatelessWidget {
  final MaterialPesca data;
  final VoidCallback onTap;

  const MaterialPescaCard({super.key, required this.data, required this.onTap});

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

              // Información de material
              _buildMaterialInfo(),

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

  Widget _buildMaterialInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          'MATERIAL DE PESCA:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        if (data.tipoMaterial != null || data.cantidadMaterial != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (data.tipoMaterial != null)
                _buildMaterialDetail('Tipo:', data.tipoMaterial!),
              if (data.cantidadMaterial != null)
                _buildMaterialDetail('Cantidad:', '${data.cantidadMaterial}'),
              if (data.unidadMedida != null)
                _buildMaterialDetail('Unidad:', data.unidadMedida!),
              if (data.cantidadRemitida != null)
                _buildMaterialDetail('Remitido:', '${data.cantidadRemitida}'),
              if (data.gramaje != null)
                _buildMaterialDetail('Gramaje:', '${data.gramaje} g'),
              if (data.proceso != null)
                _buildMaterialDetail('Proceso:', data.proceso!),
            ],
          )
        else
          const Text(
            'No se registró material',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
      ],
    );
  }

  Widget _buildMaterialDetail(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final isComplete = data.tieneRegistro == 1;

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
