/* import 'package:appkilosremitidos/core/services/api_service.dart';
import 'package:appkilosremitidos/core/services/local_db_service.dart';
import 'package:appkilosremitidos/models/kilos_model.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class KilosProvider with ChangeNotifier {
  final ApiService _apiService;
  final LocalDbService _localDbService;
  final Connectivity _connectivity;

  KilosProvider({
    ApiService? apiService,
    LocalDbService? localDbService,
    Connectivity? connectivity,
  }) : _apiService = apiService ?? ApiService(),
       _localDbService = localDbService ?? LocalDbService(),
       _connectivity = connectivity ?? Connectivity();

  bool _isLoading = false;
  String? _errorMessage;
  List<KilosRemitidos> _kilosList = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<KilosRemitidos> get kilosList => _kilosList;

  Future<bool> get _hasInternetConnection async {
    final result = await _connectivity.checkConnectivity();
    // ignore: unrelated_type_equality_checks
    return result != ConnectivityResult.none;
  }

  Future<void> fetchKilosRemitidos(String token, String option) async {
    try {
      _startLoading();
      if (await _hasInternetConnection) {
        await _fetchFromApiAndSave(token, option);
      } else {
        await _loadFromLocalDb();
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _stopLoading();
    }
  }

  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    _notifySafely();
  }

  void _stopLoading() {
    _isLoading = false;
    _notifySafely();
  }

  Future<void> _fetchFromApiAndSave(String token, String option) async {
    final response = await _apiService.getWaybillData(token, option);
    final kilos = KilosRemitidos.fromApiJson(response['data']);
    await _localDbService.insertKilos(kilos);
    _kilosList = await _localDbService.getAllKilos();
  }

  Future<void> _loadFromLocalDb() async {
    _kilosList = await _localDbService.getAllKilos();
    _errorMessage = _kilosList.isEmpty
        ? 'No hay conexión y no existen datos locales'
        : 'Mostrando datos almacenados localmente';
  }

  void _handleError(dynamic error) {
    _errorMessage = 'Error al obtener los kilos remitidos: ${error.toString()}';
    _kilosList = [];
  }

  Future<void> updateKilos(KilosRemitidos kilos) async {
    try {
      _startLoading();
      await _localDbService.updateKilos(kilos);
      _kilosList = await _localDbService.getAllKilos();
    } catch (e) {
      _errorMessage = 'Error al actualizar los kilos: ${e.toString()}';
    } finally {
      _stopLoading();
    }
  }

  void clearError() {
    _errorMessage = null;
    _notifySafely();
  }

  void _notifySafely() {
    if (!_isLoading) {
      notifyListeners();
    }
  }
}
 */
