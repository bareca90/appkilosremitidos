/* import 'package:appkilosremitidos/core/constants/app_routes.dart'; */
/* import 'package:appkilosremitidos/models/material_pesca.dart'; */
import 'package:appkilosremitidos/screens/material_pesca/material_pesca_detail_screen.dart';
import 'package:appkilosremitidos/screens/material_pesca/widgets/material_pesca_card.dart';
import 'package:appkilosremitidos/screens/material_pesca/widgets/material_pesca_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appkilosremitidos/core/providers/auth_provider.dart';
import 'package:appkilosremitidos/core/providers/material_pesca_provider.dart';

class MaterialPescaListScreen extends StatelessWidget {
  const MaterialPescaListScreen({super.key});

  static const routeName = '/material-pesca-list';

  Future<void> _loadData(BuildContext context) async {
    final provider = Provider.of<MaterialPescaProvider>(context, listen: false);
    final authToken = Provider.of<AuthProvider>(context, listen: false).token;
    await provider.fetchData(authToken!);
  }

  Future<void> _refreshData(BuildContext context) async {
    await _loadData(context);
  }

  Future<void> _navigateToDetail(BuildContext context, String nroGuia) async {
    try {
      final provider = Provider.of<MaterialPescaProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Obtener el material seleccionado
      final selected = await provider.selectData(nroGuia);

      if (selected == null) {
        throw Exception('No se encontró la guía $nroGuia');
      }

      if (context.mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MaterialPescaDetailScreen(material: selected),
          ),
        );

        if (result == true && context.mounted) {
          await provider.fetchData(authProvider.token!);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MaterialPescaProvider>(
        context,
        listen: false,
      );
      if (provider.dataList.isEmpty && !provider.isLoading) {
        _loadData(context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Kilos Remitidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final provider = Provider.of<MaterialPescaProvider>(
                context,
                listen: false,
              );
              showSearch(
                context: context,
                delegate: MaterialPescaSearchDelegate(
                  dataList: provider.dataList,
                  onGuiaSelected: (nroGuia) =>
                      _navigateToDetail(context, nroGuia),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MaterialPescaProvider>(
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

          return RefreshIndicator(
            onRefresh: () => _refreshData(context),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.filteredDataList.length,
              itemBuilder: (context, index) {
                final data = provider.filteredDataList[index];
                return MaterialPescaCard(
                  data: data,
                  onTap: () => _navigateToDetail(context, data.nroGuia),
                  /* data: data,
                  onTap: () async {
                    try {
                      final provider = Provider.of<MaterialPescaProvider>(
                        context,
                        listen: false,
                      );
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );

                      // 1. Obtener el material seleccionado
                      final selected = await provider.selectData(data.nroGuia);

                      // 2. Verificar que el material existe
                      if (selected == null) {
                        throw Exception(
                          'No se encontró la guía ${data.nroGuia}',
                        );
                      }

                      // 3. Navegar usando MaterialPageRoute directamente
                      if (context.mounted) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MaterialPescaDetailScreen(material: selected),
                          ),
                        );

                        // 4. Si regresamos de la pantalla de detalle, recargar datos
                        if (result == true && context.mounted) {
                          await provider.fetchData(authProvider.token!);
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  }, */
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/* class _MaterialPescaSearchDelegate extends SearchDelegate<String> {
  final List<MaterialPesca> dataList;

  _MaterialPescaSearchDelegate({required this.dataList});

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
            close(context, data.nroGuia);
          },
        );
      },
    );
  }
} */
