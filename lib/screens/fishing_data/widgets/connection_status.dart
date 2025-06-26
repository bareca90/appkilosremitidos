import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:appkilosremitidos/core/providers/connectivity_provider.dart';

class ConnectionStatus extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? onlineColor;
  final Color? offlineColor;

  const ConnectionStatus({
    super.key,
    this.size = 24,
    this.showText = true,
    this.onlineColor,
    this.offlineColor,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return Consumer<ConnectivityProvider>(
        builder: (context, provider, _) {
          final isConnected =
              provider.connectivityStatus != ConnectivityResult.none;
          final icon = isConnected ? Icons.wifi : Icons.wifi_off;
          final color = isConnected
              ? onlineColor ?? Colors.green
              : offlineColor ?? Colors.red;
          final text = isConnected ? 'En línea' : 'Sin conexión';

          return Tooltip(
            message: _getConnectionType(provider.connectivityStatus),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: size, color: color),
                if (showText) ...[
                  const SizedBox(width: 4),
                  Text(
                    text,
                    style: TextStyle(color: color, fontSize: size * 0.6),
                  ),
                ],
              ],
            ),
          );
        },
      );
    } catch (e) {
      // Fallback en caso de error
      return Icon(Icons.warning, size: size, color: Colors.orange);
    }
  }

  String _getConnectionType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'Conectado por WiFi';
      case ConnectivityResult.mobile:
        return 'Conectado por datos móviles';
      case ConnectivityResult.ethernet:
        return 'Conectado por Ethernet';
      case ConnectivityResult.vpn:
        return 'Conectado por VPN';
      case ConnectivityResult.bluetooth:
        return 'Conectado por Bluetooth';
      case ConnectivityResult.other:
        return 'Conectado por otro medio';
      default:
        return 'Sin conexión a internet';
    }
  }
}
