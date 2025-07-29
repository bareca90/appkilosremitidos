import 'package:appkilosremitidos/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appkilosremitidos/core/providers/auth_provider.dart';
import 'package:appkilosremitidos/core/providers/material_pesca_provider.dart';
import 'package:appkilosremitidos/models/material_pesca.dart';
import 'package:appkilosremitidos/screens/material_pesca/material_pesca_form_screen.dart';

class MaterialPescaDetailScreen extends StatelessWidget {
  final MaterialPesca material;

  const MaterialPescaDetailScreen({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: Text(
          'Detalle Guía ${material.nroGuia}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.primaryBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: () async {
              final provider = Provider.of<MaterialPescaProvider>(
                context,
                listen: false,
              );
              await provider.loadMaterialesPorGuia(material.nroGuia);
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          _HeaderInfo(material: material),
          const SizedBox(height: 8),
          Expanded(child: _MaterialList(nroGuia: material.nroGuia)),
        ],
      ),
      floatingActionButton: _buildAddButton(context),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final isBlocked = material.tieneKilosRemitidos == 1;

    return FloatingActionButton(
      onPressed: isBlocked
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'No se pueden agregar lotes con kilos remitidos',
                  ),
                  backgroundColor: AppColors.primaryRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          : () => _navigateToForm(context),
      backgroundColor: isBlocked ? AppColors.darkGray : AppColors.primaryBlue,
      tooltip: isBlocked ? 'Kilos ya remitidos' : 'Agregar lote',
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Icon(isBlocked ? Icons.block : Icons.add, color: AppColors.white),
    );
  }

  Future<void> _navigateToForm(BuildContext context) async {
    final provider = Provider.of<MaterialPescaProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      );

      final nextLote = provider.getNextLote(material.nroGuia);

      final newMaterial = material.copyWith(
        lote: nextLote,
        tieneRegistro: 0,
        sincronizado: 0,
        tipoMaterial: null,
        cantidadMaterial: null,
        unidadMedida: null,
        cantidadRemitida: null,
        gramaje: null,
        proceso: null,
      );

      if (context.mounted) Navigator.of(context).pop();

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MaterialPescaFormScreen(data: newMaterial),
        ),
      );

      if (result == true && context.mounted) {
        await provider.loadMaterialesPorGuia(material.nroGuia);
        await provider.fetchData(authProvider.token!);
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.primaryRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _HeaderInfo extends StatelessWidget {
  final MaterialPesca material;

  const _HeaderInfo({required this.material});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Guía ${material.nroGuia}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    avatar: Icon(
                      Icons.phishing,
                      size: 18,
                      color: AppColors.primaryBlue,
                    ),
                    label: Text(
                      material.tipoPesca,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.numbers,
                label: 'Programa:',
                value: material.nroPesca,
              ),
              _InfoRow(
                icon: Icons.calendar_today,
                label: 'Fecha:',
                value:
                    '${material.fechaGuia.day}/${material.fechaGuia.month}/${material.fechaGuia.year}',
              ),
              _InfoRow(
                icon: Icons.business,
                label: 'Camaronera:',
                value: material.camaronera.trim(),
              ),
              _InfoRow(
                icon: Icons.water_drop,
                label: 'Piscina:',
                value:
                    '${material.codPiscina.trim()} - ${material.piscina.trim()}',
              ),
              if (material.tieneKilosRemitidos == 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: AppColors.primaryRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kilos ya remitidos',
                        style: TextStyle(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue.withOpacity(0.7)),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialList extends StatelessWidget {
  final String nroGuia;

  const _MaterialList({required this.nroGuia});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MaterialPescaProvider>(context);
    final materiales =
        provider.materialesList.where((m) => m.nroGuia == nroGuia).toList()
          ..sort((a, b) => a.lote.compareTo(b.lote));

    if (materiales.isEmpty) {
      return _EmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: () => provider.loadMaterialesPorGuia(nroGuia),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: materiales.length,
        itemBuilder: (context, index) =>
            _MaterialCard(material: materiales[index]),
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final MaterialPesca material;

  const _MaterialCard({required this.material});

  @override
  Widget build(BuildContext context) {
    final isComplete = material.tieneRegistro == 1;
    final isSynced = material.sincronizado == 1;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isComplete
                  ? isSynced
                        ? AppColors.primaryBlue.withOpacity(0.3)
                        : AppColors.primaryRed.withOpacity(0.3)
                  : AppColors.darkGray.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 20,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Lote ${material.lote}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (isComplete)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primaryBlue,
                            size: 22,
                          ),
                        if (isSynced)
                          Icon(
                            Icons.cloud_done,
                            color: AppColors.primaryBlue,
                            size: 22,
                          ),
                        if (!isSynced && isComplete)
                          Icon(
                            Icons.cloud_off,
                            color: AppColors.primaryRed,
                            size: 22,
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (material.tipoMaterial != null)
                  _DetailRow(
                    icon: Icons.category,
                    label: 'Material:',
                    value: material.tipoMaterial!,
                  ),
                if (material.cantidadMaterial != null)
                  _DetailRow(
                    icon: Icons.format_list_numbered,
                    label: 'Cantidad:',
                    value: '${material.cantidadMaterial}',
                  ),
                if (material.unidadMedida != null)
                  _DetailRow(
                    icon: Icons.straighten,
                    label: 'Unidad:',
                    value: material.unidadMedida!,
                  ),
                if (material.cantidadRemitida != null)
                  _DetailRow(
                    icon: Icons.scale,
                    label: 'Remitido:',
                    value: '${material.cantidadRemitida} kg',
                  ),
                if (material.gramaje != null)
                  _DetailRow(
                    icon: Icons.monitor_weight,
                    label: 'Gramaje:',
                    value: '${material.gramaje} g',
                  ),
                if (material.proceso != null)
                  _DetailRow(
                    icon: Icons.engineering,
                    label: 'Proceso:',
                    value: material.proceso!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryBlue.withOpacity(0.6)),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.darkGray, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2,
            size: 72,
            color: AppColors.primaryBlue.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay lotes registrados',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.darkGray,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Presiona el botón + para agregar',
            style: TextStyle(fontSize: 14, color: AppColors.darkGray),
          ),
        ],
      ),
    );
  }
}
