import 'package:appkilosremitidos/models/fishing_data.dart';
import 'package:flutter/material.dart';
import 'package:appkilosremitidos/screens/fishing_data/repositories/fishing_data_repository.dart';

class FishingDataProvider with ChangeNotifier {
  final FishingDataRepository _repository;

  FishingDataProvider(this._repository);

  bool _isLoading = false;
  String? _errorMessage;
  List<FishingData> _dataList = [];
  FishingData? _selectedData;
  List<FishingData> _filteredDataList = [];
  String _filterText = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<FishingData> get dataList => _dataList;
  FishingData? get selectedData => _selectedData;

  List<FishingData> get filteredDataList =>
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

  Future<void> fetchData(String token, String option) async {
    if (!_isLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      final newData = await _repository.fetchFishingData(token, option);
      /* for (final data in newData) {
        // Verifica si el nroGuia ya existe en la lista
        print('Verificando Data : $data');
      } */
      _dataList = newData;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      // Intenta obtener datos locales solo si hay un error
      try {
        _dataList = await _repository.getLocalFishingData();
      } catch (localError) {
        _errorMessage = "Error al cargar datos: ${e.toString()}";
        _dataList = []; // Asegúrate de limpiar la lista en caso de error
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectData(String nroGuia) async {
    _selectedData = await _repository.getFishingDataByGuide(nroGuia);
    notifyListeners();
  }

  Future<void> saveKilos(String nroGuia, int kilos) async {
    await _repository.updateKilos(nroGuia, kilos);
    notifyListeners();
  }

  Future<void> saveHours(
    String nroGuia,
    Map<String, dynamic> hours,
    String token,
    List<String> selectedFields,
  ) async {
    try {
      await _repository.updateHours(
        nroGuia,
        hours, // Usamos la versión con nulls para la API
        token,
        selectedFields,
      );

      // Actualizar la lista local
      final index = _dataList.indexWhere((data) => data.nroGuia == nroGuia);
      if (index != -1) {
        _dataList[index] = _dataList[index].copyWith(
          inicioPesca: selectedFields.contains('inicioPesca')
              ? hours['inicioPesca'].toString().isNotEmpty
                    ? hours['inicioPesca']
                    : null
              : null,
          finPesca: selectedFields.contains('finPesca')
              ? hours['finPesca'].toString().isNotEmpty
                    ? hours['finPesca']
                    : null
              : null,
          fechaCamaroneraPlanta:
              selectedFields.contains('fechaCamaroneraPlanta')
              ? hours['fechaCamaroneraPlanta'].toString().isNotEmpty
                    ? hours['fechaCamaroneraPlanta']
                    : null
              : null,
          fechaLlegadaCamaronera:
              selectedFields.contains('fechaLlegadaCamaronera')
              ? hours['fechaLlegadaCamaronera'].toString().isNotEmpty
                    ? hours['fechaLlegadaCamaronera']
                    : null
              : null,
          tieneInicioPesca: hours['tieneInicioPesca'],
          tieneFinPesca: hours['tieneFinPesca'],
          tieneSalidaCamaronera: hours['tieneSalidaCamaronera'],
          tieneLlegadaCamaronera: hours['tieneLlegadaCamaronera'],
        );
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Error al guardar horas: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
