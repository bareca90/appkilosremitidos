import 'package:appkilosremitidos/core/services/api_service.dart';
import 'package:appkilosremitidos/core/services/local_db_service.dart';
import 'package:appkilosremitidos/models/material_pesca.dart';

class MaterialPescaRepository {
  final ApiService _apiService;
  final LocalDbService _localDbService;

  MaterialPescaRepository({
    required ApiService apiService,
    required LocalDbService localDbService,
  }) : _apiService = apiService,
       _localDbService = localDbService;

  Future<List<MaterialPesca>> fetchMaterialPesca(String token) async {
    try {
      final response = await _apiService.getWaybillData(token, 'GSK');

      final dynamic responseData = response['data'];
      List<MaterialPesca> dataList = [];

      if (responseData is List) {
        dataList = responseData
            .map((item) => MaterialPesca.fromJson(item))
            .toList();
      } else if (responseData is Map) {
        dataList = [
          MaterialPesca.fromJson(Map<String, dynamic>.from(responseData)),
        ];
      } else {
        throw Exception('Formato de datos no reconocido');
      }

      await _localDbService.clearMaterialPesca();

      for (final data in dataList) {
        await _localDbService.insertMaterialPesca(data);
      }

      return await _localDbService.getAllMaterialPesca();
    } catch (e) {
      print('Error fetching remote data: $e');
      final localData = await _localDbService.getAllMaterialPesca();
      if (localData.isEmpty) throw Exception('No hay datos disponibles');
      return localData;
    }
  }

  Future<List<MaterialPesca>> getMaterialesByGuia(String nroGuia) async {
    try {
      // Primero intenta obtener datos locales
      final localData = await _localDbService.getMaterialesByGuia(nroGuia);

      if (localData.isNotEmpty) {
        return localData;
      }

      // Si no hay datos locales, puedes implementar aquí una llamada a la API si es necesario
      // Ejemplo:
      // final response = await _apiService.getMaterialesByGuia(nroGuia);
      // ... procesar respuesta API ...

      return []; // Retorna los datos locales (puede estar vacío)
    } catch (e) {
      print('Error getting materiales by guia: $e');
      throw Exception('Error al obtener materiales por guía');
    }
  }

  Future<MaterialPesca?> getMaterialPescaByGuide(String nroGuia) async {
    try {
      final data = await _localDbService.getMaterialPescaByGuide(nroGuia);
      if (data != null) return data;

      // Si no está en la base de datos local, busca en la lista en memoria
      final allData = await getLocalMaterialPesca();
      return allData.firstWhere(
        (item) => item.nroGuia == nroGuia,
        orElse: () => throw Exception('Guía no encontrada'),
      );
    } catch (e) {
      print('Error getting material by guide: $e');
      rethrow;
    }
  }

  Future<List<MaterialPesca>> getLocalMaterialPesca() async {
    return await _localDbService.getAllMaterialPesca();
  }

  Future<void> updateMaterialPesca(MaterialPesca data) async {
    await _localDbService.updateMaterialPesca(data);
  }
}
