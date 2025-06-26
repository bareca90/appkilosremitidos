import 'package:appkilosremitidos/core/services/api_service.dart';
import 'package:appkilosremitidos/core/services/shared_prefs_service.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.validateUser(username, password);

      if (response.code == 200) {
        _token = response.data['token'];
        await SharedPrefsService.saveToken(_token!);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    await SharedPrefsService.clearToken();
    notifyListeners();
  }

  // Método para cargar el token al iniciar la app
  Future<void> loadToken() async {
    _token = await SharedPrefsService.getToken();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
