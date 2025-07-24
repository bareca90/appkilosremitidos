import 'package:appkilosremitidos/models/material_pesca.dart';
import 'package:appkilosremitidos/screens/material_pesca/repositories/material_pesca_repository.dart';
import 'package:flutter/foundation.dart';

class MaterialPescaProvider with ChangeNotifier {
  final MaterialPescaRepository _repository;

  MaterialPescaProvider(this._repository);

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
        _dataList = await _repository.getLocalMaterialPesca();
        _filteredDataList = _dataList;
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
      // Guardar localmente primero
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
    } catch (e) {
      _errorMessage = 'Error al guardar: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadMaterialesPorGuia(String nroGuia) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('Cargando materiales para guía: $nroGuia');
      _dataList = await _repository.getMaterialesByGuia(nroGuia);
      _filteredDataList = _dataList;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error al cargar materiales: ${e.toString()}';
      _dataList = [];
      _filteredDataList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getNextLote(String nroGuia) {
    final materiales = _dataList.where((m) => m.nroGuia == nroGuia).toList();
    if (materiales.isEmpty) return 1;
    return (materiales.last.lote) + 1;
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
