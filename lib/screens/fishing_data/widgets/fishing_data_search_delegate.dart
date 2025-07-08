import 'package:appkilosremitidos/core/providers/fishing_data_provider.dart';
import 'package:appkilosremitidos/models/fishing_data.dart';
import 'package:appkilosremitidos/screens/fishing_data/hours_form_screen.dart';
import 'package:appkilosremitidos/screens/fishing_data/kilos_form_screen.dart';
import 'package:appkilosremitidos/screens/fishing_data/widgets/fishing_data_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FishingDataSearchDelegate extends SearchDelegate<String> {
  final List<FishingData> dataList;
  final bool isKilosScreen;

  FishingDataSearchDelegate({
    required this.dataList,
    required this.isKilosScreen,
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
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredList = query.isEmpty
        ? dataList
        : dataList.where((data) {
            return data.nroGuia.toLowerCase().contains(query.toLowerCase());
          }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No se encontraron guías con ese número'),
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
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final data = filteredList[index];
        return FishingDataCard(
          data: data,
          onTap: () async {
            final provider = Provider.of<FishingDataProvider>(
              context,
              listen: false,
            );
            await provider.selectData(data.nroGuia);
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => isKilosScreen
                    ? KilosFormScreen(data: provider.selectedData!)
                    : HoursFormScreen(data: provider.selectedData!),
              ),
            );
          },
          isKilosScreen: isKilosScreen,
        );
      },
    );
  }
}
