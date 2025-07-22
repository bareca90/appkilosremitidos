import 'package:flutter/material.dart';
import 'package:appkilosremitidos/models/material_pesca.dart';
import 'package:appkilosremitidos/screens/material_pesca/material_pesca_form_screen.dart';
import 'package:provider/provider.dart';
import 'package:appkilosremitidos/core/providers/material_pesca_provider.dart';

class MaterialPescaDetailScreen extends StatelessWidget {
  /* static const routeName = '/material-pesca-detail'; */
  final MaterialPesca material;
  const MaterialPescaDetailScreen({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle Guía ${material.nroGuia}'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer<MaterialPescaProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _HeaderCard(material: material),
              const SizedBox(height: 8),
              Expanded(child: _DetailList(nroGuia: material.nroGuia)),
            ],
          );
        },
      ),

      /* body: Column(
        children: [
          // Cabecera
          _HeaderCard(material: material),
          const SizedBox(height: 8),
          // Lista de detalles
          Expanded(child: _DetailList(nroGuia: material.nroGuia)),
        ],
      ), */
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        /* onPressed: () async {
          final provider = Provider.of<MaterialPescaProvider>(
            context,
            listen: false,
          );
          await provider.selectData(material.nroGuia);

          if (!context.mounted) return;

          // Navegar y esperar el resultado
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MaterialPescaFormScreen(data: provider.selectedData!),
            ),
          );

          // Si se guardó un nuevo registro, actualizar
          if (result == true && context.mounted) {
            await provider.loadMaterialesPorGuia(material.nroGuia);
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white), */
      ),
    );
  }

  Future<void> _navigateToForm(BuildContext context) async {
    final provider = Provider.of<MaterialPescaProvider>(context, listen: false);

    try {
      // Obtener el próximo número de lote
      final nextLote = provider.getNextLote(material.nroGuia);
      // Crear nuevo material con lote asignado
      final newMaterial = material.copyWith(
        lote: nextLote,
        tieneRegistro: 0,
        // Resetear otros campos según sea necesario
        tipoMaterial: null,
        cantidadMaterial: null,
        unidadMedida: null,
        cantidadRemitida: null,
      );
      // 2. Navegar al formulario y esperar resultado
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MaterialPescaFormScreen(data: newMaterial),
        ),
      );
      // Si se guardó exitosamente, recargar datos
      if (result == true && context.mounted) {
        await provider.loadMaterialesPorGuia(material.nroGuia);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}

class _HeaderCard extends StatelessWidget {
  final MaterialPesca material;

  const _HeaderCard({required this.material});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Guía: ${material.nroGuia}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Chip(
                  backgroundColor: Colors.blue.shade100,
                  label: Text(
                    material.tipoPesca,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Pesca:', material.nroPesca),
            _buildInfoRow(
              'Fecha:',
              '${material.fechaGuia.day}/${material.fechaGuia.month}/${material.fechaGuia.year}',
            ),
            _buildInfoRow('Camaronera:', material.camaronera.trim()),
            _buildInfoRow(
              'Piscina:',
              '${material.codPiscina.trim()} - ${material.piscina.trim()}',
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailList extends StatelessWidget {
  final String nroGuia;

  const _DetailList({required this.nroGuia});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MaterialPescaProvider>(context);
    final detalles =
        provider.materialesList.where((m) => m.nroGuia == nroGuia).toList()
          ..sort(
            (a, b) => (a.lote ?? 0).compareTo(b.lote ?? 0),
          ); // Ordenar por lote

    if (detalles.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadMaterialesPorGuia(nroGuia);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: detalles.length,
        itemBuilder: (context, index) {
          final detalle = detalles[index];
          return _DetailCard(detalle: detalle);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list_alt, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No hay detalles registrados',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para agregar',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final MaterialPesca detalle;

  const _DetailCard({required this.detalle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lote: ${detalle.lote ?? "N/A"}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (detalle.tieneRegistro == 1)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const SizedBox(height: 8),
            if (detalle.tipoMaterial != null)
              _buildDetailRow('Material:', detalle.tipoMaterial!),
            if (detalle.cantidadMaterial != null)
              _buildDetailRow('Cantidad:', '${detalle.cantidadMaterial}'),
            if (detalle.unidadMedida != null)
              _buildDetailRow('Unidad:', detalle.unidadMedida!),
            if (detalle.cantidadRemitida != null)
              _buildDetailRow('Remitido:', '${detalle.cantidadRemitida} kg'),
            if (detalle.gramaje != null)
              _buildDetailRow('Gramaje:', '${detalle.gramaje} g'),
            if (detalle.proceso != null)
              _buildDetailRow('Proceso:', detalle.proceso!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
