import 'package:appkilosremitidos/screens/fishing_data/widgets/fishing_data_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appkilosremitidos/core/providers/auth_provider.dart';
import 'package:appkilosremitidos/core/providers/fishing_data_provider.dart';
import 'package:appkilosremitidos/screens/fishing_data/hours_form_screen.dart';
import 'package:appkilosremitidos/screens/fishing_data/kilos_form_screen.dart';
import 'package:appkilosremitidos/screens/fishing_data/widgets/fishing_data_card.dart';

class FishingDataListScreen extends StatelessWidget {
  final String option;
  final bool isKilosScreen;

  const FishingDataListScreen({
    super.key,
    required this.option,
    required this.isKilosScreen,
  });

  static Route<dynamic> route(Map<String, dynamic> args) {
    return MaterialPageRoute(
      builder: (_) => FishingDataListScreen(
        option: args['option'],
        isKilosScreen: args['isKilosScreen'],
      ),
    );
  }

  Future<void> _loadData(BuildContext context) async {
    final provider = Provider.of<FishingDataProvider>(context, listen: false);
    final authToken = Provider.of<AuthProvider>(context, listen: false).token;
    await provider.fetchData(authToken!, option);
  }

  Future<void> _refreshData(BuildContext context) async {
    await _loadData(context);
  }

  @override
  Widget build(BuildContext context) {
    // Cargar datos iniciales al construir el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FishingDataProvider>(context, listen: false);
      if (provider.dataList.isEmpty && !provider.isLoading) {
        _loadData(context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isKilosScreen ? 'Kilos Remitidos' : 'Registro de Horas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final provider = Provider.of<FishingDataProvider>(
                context,
                listen: false,
              );
              showSearch(
                context: context,
                delegate: FishingDataSearchDelegate(
                  dataList: provider.dataList,
                  isKilosScreen: isKilosScreen,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<FishingDataProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.dataList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.dataList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _refreshData(context),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          /* final displayList = provider.filteredDataList;
          if (displayList.isEmpty && provider.filterText.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No se encontraron guías con ese número'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<FishingDataProvider>(
                        context,
                        listen: false,
                      ).filterData('');
                    },
                    child: const Text('Limpiar búsqueda'),
                  ),
                ],
              ),
            );
          } */

          return RefreshIndicator(
            onRefresh: () => _refreshData(context),
            child: ListView.builder(
              itemCount: provider.dataList.length,
              itemBuilder: (context, index) {
                final data = provider.dataList[index];
                return FishingDataCard(
                  data: data,
                  onTap: () async {
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
            ),
          );
        },
      ),
    );
  }
}
