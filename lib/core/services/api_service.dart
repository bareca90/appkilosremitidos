import 'dart:convert';
import 'package:appkilosremitidos/core/constants/api_constants.dart';
import 'package:appkilosremitidos/models/api_request.dart';
import 'package:appkilosremitidos/models/auth_response.dart';
import 'package:appkilosremitidos/models/base_response.dart';
import 'package:appkilosremitidos/models/fishing_data.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client _client;
  static const String baseUrl =
      'http://10.100.123.11:8800/api-kilosremitidosapp-v1';
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<AuthResponse> validateUser(String username, String password) async {
    final response = await http.post(
      //10.20.4.173:8077 Servidor Desarrollo
      Uri.parse(
        'http://10.100.123.11:8800/api-kilosremitidosapp-v1/auth/validateuser',
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to validate user');
    }
  }

  Future<Map<String, dynamic>> getWaybillData(
    String token,
    String option,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/data/getwaybill'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'option': option}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load waybill data');
    }
  }

  Future<BaseResponse<FishingData>> getFishingData(
    String token,
    ApiRequest request,
  ) async {
    final response = await _client
        .post(
          Uri.parse(ApiConstants.buildUrl(ApiConstants.getWaybill)),
          headers: {
            'Content-Type': ApiConstants.contentType,
            ApiConstants.authorizationHeader: 'Bearer $token',
          },
          body: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(milliseconds: ApiConstants.receiveTimeout));

    if (response.statusCode == 200) {
      return BaseResponse.fromJson(
        jsonDecode(response.body),
        (data) => FishingData.fromJson(data),
      );
    } else {
      throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> updateDateTimeWaybill({
    required String token,
    required String nroGuia,
    required String? inicioPesca,
    required String? finPesca,
    required String? fechaCamaroneraPlanta,
    required String? fechaLlegadaCamaronera,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.buildUrl(ApiConstants.updatedatetimewaybill)),
      headers: {
        'Content-Type': ApiConstants.contentType,
        ApiConstants.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode({
        'nroGuia': nroGuia,
        'inicioPesca': (inicioPesca != null && inicioPesca.isNotEmpty)
            ? inicioPesca
            : '1753-01-01 00:00',
        'finPesca': (finPesca != null && finPesca.isNotEmpty)
            ? finPesca
            : '1753-01-01 00:00',
        'fechaCamaroneraPlanta':
            (fechaCamaroneraPlanta != null && fechaCamaroneraPlanta.isNotEmpty)
            ? fechaCamaroneraPlanta
            : '1753-01-01 00:00',
        'fechaLlegadaCamaronera':
            (fechaLlegadaCamaronera != null &&
                fechaLlegadaCamaronera.isNotEmpty)
            ? fechaLlegadaCamaronera
            : '1753-01-01 00:00',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar horas: ${response.statusCode}');
    }
  }

  Future<bool> insertKgsent({
    required String token,
    required String nroGuia,
    required String ciclo,
    required int anioSiembra,
    required int lote,
    required String ingresoCompra,
    required String tipoMaterial,
    required int cantidadMaterial,
    required String unidadMedida,
    required double cantidadRemitida,
    required double gramaje,
    required String proceso,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/data/insertkgsent'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "nroGuia": nroGuia,
        "ciclo": ciclo,
        "anioSiembra": anioSiembra,
        "lote": lote,
        "ingresoCompra": ingresoCompra,
        "tipoMaterial": tipoMaterial,
        "cantidadMaterial": cantidadMaterial,
        "unidadMedida": unidadMedida,
        "cantidadRemitida": cantidadRemitida,
        "gramaje": gramaje,
        "proceso": proceso,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al sincronizar: ${response.statusCode}');
    }
  }
}
