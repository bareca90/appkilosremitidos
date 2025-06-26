import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  ConnectivityResult _connectivityStatus = ConnectivityResult.none;

  ConnectivityProvider() {
    _init();
  }

  ConnectivityResult get connectivityStatus => _connectivityStatus;

  Future<void> _init() async {
    // Estado inicial
    _updateStatus(
      (await Connectivity().checkConnectivity()) as ConnectivityResult,
    );

    // Suscripción a cambios
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      // Toma el primer resultado disponible, o none si la lista está vacía
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      _updateStatus(result);
    });
  }

  void _updateStatus(ConnectivityResult result) {
    if (_connectivityStatus != result) {
      _connectivityStatus = result;
      notifyListeners();
    }
  }

  Future<bool> get isConnected async {
    final result = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    return result != ConnectivityResult.none;
  }
}
