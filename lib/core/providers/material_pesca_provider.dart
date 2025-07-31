import 'package:appkilosremitidos/core/services/local_db_service.dart';
import 'package:appkilosremitidos/models/material_pesca.dart';
import 'package:appkilosremitidos/screens/material_pesca/repositories/material_pesca_repository.dart';
import 'package:flutter/foundation.dart';

class MaterialPescaProvider with ChangeNotifier {
  final MaterialPescaRepository _repository;

  final LocalDbService _localDbService;
  MaterialPescaProvider(this._repository, this._localDbService);

  bool _isLoading = false;
  String? _errorMessage;
  List<MaterialPesca> _dataList = [];
  MaterialPesca? _selectedData;
  List<MaterialPesca> _filteredDataList = [];
  String _filterText = '';

  MaterialPesca? _selectedMaterial;
  MaterialPesca? get selectedMaterial => _selectedMaterial;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MaterialPesca> get dataList => _dataList;
  MaterialPesca? get selectedData => _selectedData;
  List<MaterialPesca> get filteredDataList =>
      _filterText.isEmpty ? _dataList : _filteredDataList;
  String get filterText => _filterText;

  void filterData(String query) {
    _filterText = query;
    if (query.isEmpty) {
      _filteredDataList = _dataList;
    } else {
      _filteredDataList = _dataList.where((data) {
        return data.nroGuia.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void selectMaterial(MaterialPesca material) {
    _selectedMaterial = material;
    notifyListeners();
  }

  Future<void> fetchData(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dataList = await _repository.fetchMaterialPesca(token);
      _filteredDataList = _dataList;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      try {
        // Intentar cargar solo datos locales como respaldo
        _dataList = await _repository.getLocalMaterialPesca();
        _filteredDataList = _dataList;
        _errorMessage = "Advertencia: Datos no actualizados. ${e.toString()}";
      } catch (localError) {
        _errorMessage = "Error al cargar datos: ${e.toString()}";
        _dataList = [];
        _filteredDataList = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MaterialPesca?> selectData(String nroGuia) async {
    try {
      // 1. Buscar en datos locales
      _selectedData = _dataList.firstWhere(
        (item) => item.nroGuia == nroGuia,
        orElse: () => throw Exception('Guía no encontrada localmente'),
      );

      // 2. Si no está local, buscar en BD
      _selectedData ??= await _repository.getMaterialPescaByGuide(nroGuia);

      notifyListeners();
      return _selectedData;
    } catch (e) {
      _errorMessage = 'Error al cargar la guía: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /* Future<bool> saveMaterialPesca(MaterialPesca data) async {
    try {
      await _repository.updateMaterialPesca(data);

      final index = _dataList.indexWhere((d) => d.nroGuia == data.nroGuia);
      if (index != -1) {
        _dataList[index] = data;
      } else {
        _dataList.add(data);
      }
      // Ordenar por lote
      _dataList.sort((a, b) => (a.lote).compareTo(b.lote));

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar: ${e.toString()}';
      notifyListeners();
      return false;
    }
  } */
  Future<bool> saveMaterialPesca(MaterialPesca data) async {
    try {
      _isLoading = true;
      notifyListeners();
      // Validar que el lote no sea cero
      if (data.lote <= 0) {
        throw Exception('El número de lote debe ser mayor que cero');
      }
      // 1. Verificar si el lote ya existe
      final existe = _dataList.any(
        (d) => d.nroGuia == data.nroGuia && d.lote == data.lote,
      );
      // 2. Guardar en la base de datos local
      if (existe) {
        await _repository.updateMaterialPesca(data.copyWith(sincronizado: 0));
      } else {
        await _localDbService.insertMaterialPesca(
          data.copyWith(sincronizado: 0),
        );
      }
      // 3. Actualizar la lista en memoria
      final index = _dataList.indexWhere(
        (d) => d.nroGuia == data.nroGuia && d.lote == data.lote,
      );
      final newData = data.copyWith(sincronizado: 0, fechaSincronizacion: null);

      if (index != -1) {
        _dataList[index] = newData;
      } else {
        _dataList.add(newData);
      }

      // 4. Ordenar por guía y luego por lote
      _dataList.sort((a, b) {
        final guiaCompare = a.nroGuia.compareTo(b.nroGuia);
        if (guiaCompare != 0) return guiaCompare;
        return a.lote.compareTo(b.lote);
      });

      // 5. Actualizar lista filtrada
      _filteredDataList = _filterText.isEmpty
          ? List.from(_dataList)
          : _dataList
                .where(
                  (d) =>
                      d.nroGuia.toLowerCase().contains(
                        _filterText.toLowerCase(),
                      ) ||
                      d.piscina.toLowerCase().contains(
                        _filterText.toLowerCase(),
                      ),
                )
                .toList();

      _errorMessage = null;
      return true;

      /* // Guardar localmente primero
      await _repository.updateMaterialPesca(data.copyWith(sincronizado: 0));

      // Actualizar la lista en memoria
      final index = _dataList.indexWhere(
        (d) => d.nroGuia == data.nroGuia && d.lote == data.lote,
      );

      if (index != -1) {
        _dataList[index] = data.copyWith(sincronizado: 0);
      } else {
        _dataList.add(data.copyWith(sincronizado: 0));
      }

      _dataList.sort((a, b) => (a.lote).compareTo(b.lote));
      notifyListeners(); 
      return true;
      */
    } catch (e, stackTrace) {
      _errorMessage = 'Error al guardar lote ${data.lote}: ${e.toString()}';
      debugPrint('Error en saveMaterialPesca: $e\n$stackTrace');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sincronizarMaterialPescaIndividual(
    String token,
    MaterialPesca data,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Intentar sincronizar con el API
      final success = await _repository.sincronizarMaterial(data, token);

      if (success) {
        // 2. Actualizar el estado local si la sincronización fue exitosa
        final updatedData = data.copyWith(
          sincronizado: 1,
          fechaSincronizacion: DateTime.now(),
          tieneKilosRemitidos: 1,
          tieneRegistro: 1,
        );

        // 3. Actualizar en la base de datos local
        await _repository.updateMaterialPesca(updatedData);

        // 4. Actualizar en la lista en memoria
        final index = _dataList.indexWhere(
          (d) => d.nroGuia == data.nroGuia && d.lote == data.lote,
        );
        if (index != -1) {
          _dataList[index] = updatedData;
        }

        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Error al sincronizar: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMaterialesPorGuia(String nroGuia) async {
    try {
      _isLoading = true;
      // Cargar datos sin notificar aún
      final nuevosDatos = await _repository.getMaterialesByGuia(nroGuia);
      // Actualizar listas
      _dataList = nuevosDatos;
      _filteredDataList = nuevosDatos;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error al cargar materiales: ${e.toString()}';
      _dataList = [];
      _filteredDataList = [];
    } finally {
      _isLoading = false;
      // Notificar solo cuando todo esté listo
      notifyListeners();
    }
  }

  int getNextLote(String nroGuia) {
    try {
      final materiales = _dataList.where((m) => m.nroGuia == nroGuia).toList();

      // Filtrar lotes válidos (mayores que 0)
      final lotesValidos = materiales.where((m) => m.lote > 0).toList();

      if (lotesValidos.isEmpty) return 1; // Primer lote válido

      // Encontrar el máximo lote existente
      final maxLote = lotesValidos.fold(
        0,
        (prev, element) => element.lote > prev ? element.lote : prev,
      );

      return maxLote + 1;
    } catch (e) {
      debugPrint('Error en getNextLote: $e');
      return 1; // Valor por defecto seguro
    }
  }

  List<MaterialPesca> get materialesList => _filteredDataList;
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> sincronizarMateriales(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.sincronizarMaterialesPendientes(token);

      // Actualizar los datos locales después de la sincronización
      _dataList = await _repository.getLocalMaterialPesca();
      _filteredDataList = _dataList;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al sincronizar: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
