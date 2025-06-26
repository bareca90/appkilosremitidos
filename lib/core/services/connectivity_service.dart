import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final String _testUrl = 'http://www.google.com';

  /// Verifica el estado actual de conexión
  Future<List<ConnectivityResult>> checkConnection() async {
    return await _connectivity.checkConnectivity();
  }

  /// Stream de cambios en la conectividad
  Stream<List<ConnectivityResult>> get connectionStream {
    return _connectivity.onConnectivityChanged;
  }

  /// Verifica si hay conexión a internet (no solo red disponible)
  Future<bool> hasInternetAccess() async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result as ConnectivityResult);
  }

  /// Método helper para determinar conexión real
  bool _isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  Future<bool> get hasRealInternetAccess async {
    try {
      // Verificar primero si hay red disponible
      final connectivityResult = await _connectivity.checkConnectivity();
      if (!_isConnected(connectivityResult as ConnectivityResult)) return false;

      // Verificar acceso real a internet
      final response = await http
          .get(Uri.parse(_testUrl))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
