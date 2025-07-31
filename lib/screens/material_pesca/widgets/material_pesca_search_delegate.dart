import 'package:flutter/material.dart';
import 'package:appkilosremitidos/models/material_pesca.dart';
import 'package:appkilosremitidos/screens/material_pesca/widgets/material_pesca_card.dart';

class MaterialPescaSearchDelegate extends SearchDelegate<String> {
  final List<MaterialPesca> dataList;
  final Function(String) onGuiaSelected;

  MaterialPescaSearchDelegate({
    required this.dataList,
    required this.onGuiaSelected,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final filteredList = query.isEmpty
        ? dataList
        : dataList.where((data) {
            return data.nroGuia.toLowerCase().contains(query.toLowerCase()) ||
                data.piscina.toLowerCase().contains(query.toLowerCase()) ||
                data.camaronera.toLowerCase().contains(query.toLowerCase());
          }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No se encontraron registros'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                query = '';
              },
              child: const Text('Limpiar búsqueda'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final data = filteredList[index];
        return MaterialPescaCard(
          data: data,
          onTap: () {
            // Cerrar el search y navegar al detalle
            close(context, '');
            onGuiaSelected(data.nroGuia);
          },
        );
      },
    );
  }
}
