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
      // 1. Obtener datos del API
      final response = await _apiService.getWaybillData(token, 'GSK');
      final dynamic responseData = response['data'];

      List<MaterialPesca> apiDataList = [];

      if (responseData is List) {
        apiDataList = responseData
            .map((item) => MaterialPesca.fromJson(item))
            .toList();
      } else if (responseData is Map) {
        apiDataList = [
          MaterialPesca.fromJson(Map<String, dynamic>.from(responseData)),
        ];
      } else {
        throw Exception('Formato de datos no reconocido');
      }

      // 2. Obtener datos locales actuales
      final localData = await _localDbService.getAllMaterialPesca();

      // 3. Procesar la sincronización
      for (final apiData in apiDataList) {
        // Buscar si ya existe localmente
        final localItem = localData.firstWhere(
          (local) => local.nroGuia == apiData.nroGuia,
          orElse: () => MaterialPesca(
            tipoPesca: '',
            nroPesca: '',
            nroGuia: '',
            fechaGuia: DateTime.now(),
            camaronera: '',
            codPiscina: '',
            piscina: '',
            lote: 0,
          ),
        );

        // Caso 1: Guía con tieneKilosRemitidos = 1 (actualizar siempre)
        if (apiData.tieneKilosRemitidos == 1) {
          await _localDbService.insertMaterialPesca(apiData);
        }
        // Caso 2: Guía con tieneKilosRemitidos = 0
        else {
          // Si existe localmente y tiene cantidadRemitida > 0 y lote > 0, no hacer nada
          if (localItem.nroGuia.isNotEmpty &&
              (localItem.cantidadRemitida ?? 0) > 0 &&
              localItem.lote > 0) {
            continue;
          }
          // Si no cumple las condiciones, eliminar y crear nueva
          else {
            // Eliminar todas las versiones locales de esta guía
            await _localDbService.deleteMaterialPescaByGuide(apiData.nroGuia);
            // Insertar la versión del API
            await _localDbService.insertMaterialPesca(apiData);
          }
        }
      }

      // 4. Retornar los datos actualizados
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

  Future<bool> sincronizarMaterial(MaterialPesca material, String token) async {
    try {
      final success = await _apiService.insertKgsent(
        token: token,
        nroGuia: material.nroGuia,
        ciclo: material.ciclo ?? 'A',
        anioSiembra: material.anioSiembra ?? DateTime.now().year,
        lote: material.lote,
        ingresoCompra: material.ingresoCompra ?? 'N',
        tipoMaterial: material.tipoMaterial ?? '',
        cantidadMaterial: material.cantidadMaterial ?? 0,
        unidadMedida: material.unidadMedida ?? 'KG',
        cantidadRemitida: material.cantidadRemitida ?? 0,
        gramaje: material.gramaje ?? 0,
        proceso: material.proceso ?? 'CC',
      );

      if (success) {
        await _localDbService.marcarComoSincronizado(
          material.nroGuia,
          material.lote,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error al sincronizar material: $e');
      return false;
    }
  }

  Future<void> sincronizarMaterialesPendientes(String token) async {
    final materiales = await _localDbService.getMaterialesNoSincronizados();
    for (final material in materiales) {
      await sincronizarMaterial(material, token);
    }
  }
}
