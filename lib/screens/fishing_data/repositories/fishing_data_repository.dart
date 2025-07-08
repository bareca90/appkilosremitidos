import 'package:appkilosremitidos/core/services/api_service.dart';
import 'package:appkilosremitidos/core/services/local_db_service.dart';
import 'package:appkilosremitidos/models/fishing_data.dart';

class FishingDataRepository {
  final ApiService _apiService;
  final LocalDbService _localDbService;

  FishingDataRepository({
    required ApiService apiService,
    required LocalDbService localDbService,
  }) : _apiService = apiService,
       _localDbService = localDbService;

  Future<List<FishingData>> fetchFishingData(
    String token,
    String option,
  ) async {
    try {
      final response = await _apiService.getWaybillData(token, option);

      // Verifica si la respuesta es una lista o un mapa
      final dynamic responseData = response['data'];
      List<FishingData> dataList = [];

      if (responseData is List) {
        dataList = responseData
            .map((item) => FishingData.fromJson(item))
            .toList();
      } else if (responseData is Map) {
        dataList = [
          FishingData.fromJson(Map<String, dynamic>.from(responseData)),
        ];
      } else {
        throw Exception('Formato de datos no reconocido');
      }

      // Guarda todos los datos en local
      for (final data in dataList) {
        await _localDbService.insertKilos(data);
      }
      final dataFromDb = await _localDbService.getAllKilos();
      return dataFromDb;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching remote data: $e');
      final localData = await _localDbService.getAllKilos();
      if (localData.isEmpty) throw Exception('No hay datos disponibles');
      return localData;
    }
  }

  Future<FishingData?> getFishingDataByGuide(String nroGuia) async {
    return await _localDbService.getFishingDataByGuide(nroGuia);
  }

  Future<List<FishingData>> getLocalFishingData() async {
    return await _localDbService.getAllKilos();
  }

  Future<void> updateKilos(String nroGuia, int kilos) async {
    await _localDbService.updateKilos(nroGuia, kilos);
  }

  Future<void> updateHours(
    String nroGuia,
    Map<String, dynamic> hours,
    String token,
    List<String> selectedFields,
  ) async {
    try {
      final apiData = {
        'inicioPesca': selectedFields.contains('inicioPesca')
            ? hours['inicioPesca']
            : null,
        'finPesca': selectedFields.contains('finPesca')
            ? hours['finPesca']
            : null,
        'fechaCamaroneraPlanta':
            selectedFields.contains('fechaCamaroneraPlanta')
            ? hours['fechaCamaroneraPlanta']
            : null,
        'fechaLlegadaCamaronera':
            selectedFields.contains('fechaLlegadaCamaronera')
            ? hours['fechaLlegadaCamaronera']
            : null,
      };
      print('Actualizando horas para $nroGuia: $apiData');
      // Actualizar en la API
      await _apiService.updateDateTimeWaybill(
        token: token,
        nroGuia: nroGuia,
        inicioPesca: apiData['inicioPesca'],
        finPesca: apiData['finPesca'],
        fechaCamaroneraPlanta: apiData['fechaCamaroneraPlanta'],
        fechaLlegadaCamaronera: apiData['fechaLlegadaCamaronera'],
      );

      // Luego actualizar localmente
      await _localDbService.updateHours(nroGuia, {
        'inicioPesca': selectedFields.contains('inicioPesca')
            ? hours['inicioPesca']?.toString() ?? ''
            : '',
        'finPesca': selectedFields.contains('finPesca')
            ? hours['finPesca']?.toString() ?? ''
            : '',
        'fechaCamaroneraPlanta':
            selectedFields.contains('fechaCamaroneraPlanta')
            ? hours['fechaCamaroneraPlanta']?.toString() ?? ''
            : '',
        'fechaLlegadaCamaronera':
            selectedFields.contains('fechaLlegadaCamaronera')
            ? hours['fechaLlegadaCamaronera']?.toString() ?? ''
            : '',
      });
    } catch (e) {
      // Si falla la API, intenta guardar solo localmente
      await _localDbService.updateHours(nroGuia, {
        'inicioPesca': hours['inicioPesca'],
        'finPesca': hours['finPesca'],
        'fechaCamaroneraPlanta': hours['fechaCamaroneraPlanta'],
        'fechaLlegadaCamaronera': hours['fechaLlegadaCamaronera'],
      });
    }
  }
}
