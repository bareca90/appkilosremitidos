class ApiConstants {
  // Base URL
  static const String baseUrl =
      'http://10.100.123.11:8800/api-kilosremitidosapp-v1';

  // Endpoints
  static const String validateUser = '/auth/validateuser';
  static const String getWaybill = '/data/getwaybill';
  static const String updatedatetimewaybill = '/data/updatedatetimewaybill';

  // Timeouts
  static const int connectTimeout = 15000; // 15 segundos
  static const int receiveTimeout = 15000; // 15 segundos

  // Headers
  static const String contentType = 'application/json';
  static const String authorizationHeader = 'Authorization';

  // Opciones para el body
  static const String optionKilos = 'GSK'; // Para kilos remitidos
  static const String optionHours = 'GSG'; // Para registro de horas

  // Método helper para construir URLs completas
  static String buildUrl(String endpoint) => '$baseUrl$endpoint';
}
