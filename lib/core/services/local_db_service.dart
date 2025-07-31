import 'package:appkilosremitidos/models/fishing_data.dart';
import 'package:appkilosremitidos/models/material_pesca.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbService {
  static const String _dbName = 'db_kilosRemitidos.db';
  static const String _tableName = 'fishing_data';
  static const int _dbVersion = 4;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            nroGuia TEXT PRIMARY KEY,
            tipoPesca TEXT NOT NULL,
            nroPesca TEXT NOT NULL,
            fechaGuia TEXT NOT NULL,
            camaronera TEXT NOT NULL,
            piscina TEXT NOT NULL,
            inicioPesca TEXT,
            finPesca TEXT,
            fechaCamaroneraPlanta TEXT,
            fechaLlegadaCamaronera TEXT,
            totalKilosRemitidos INTEGER,
            tieneInicioPesca INTEGER DEFAULT 0,
            tieneFinPesca INTEGER DEFAULT 0,
            tieneSalidaCamaronera INTEGER DEFAULT 0,
            tieneLlegadaCamaronera INTEGER DEFAULT 0,
            tieneKilosRemitidos INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS material_pesca (
            nroGuia TEXT NOT NULL,
            tipoPesca TEXT NOT NULL,
            nroPesca TEXT NOT NULL,
            fechaGuia TEXT NOT NULL,
            camaronera TEXT NOT NULL,
            codPiscina TEXT NOT NULL,
            piscina TEXT NOT NULL,
            ciclo TEXT,
            anioSiembra INTEGER,
            lote INTEGER NOT NULL,
            ingresoCompra TEXT,
            tipoMaterial TEXT,
            cantidadMaterial INTEGER,
            unidadMedida TEXT,
            cantidadRemitida REAL,
            gramaje REAL,
            proceso TEXT,
            tieneRegistro INTEGER DEFAULT 0,
            sincronizado INTEGER DEFAULT 0,
            fechaSincronizacion TEXT,
            tieneKilosRemitidos integer DEFAULT 0,
            PRIMARY KEY (nroGuia, lote)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE $_tableName ADD COLUMN tieneInicioPesca INTEGER DEFAULT 0
          ''');
          await db.execute('''
            ALTER TABLE $_tableName ADD COLUMN tieneFinPesca INTEGER DEFAULT 0
          ''');
          await db.execute('''
            ALTER TABLE $_tableName ADD COLUMN tieneSalidaCamaronera INTEGER DEFAULT 0
          ''');
          await db.execute('''
            ALTER TABLE $_tableName ADD COLUMN tieneLlegadaCamaronera INTEGER DEFAULT 0
          ''');
          await db.execute('''
            ALTER TABLE $_tableName ADD COLUMN tieneKilosRemitidos INTEGER DEFAULT 0
          ''');
        }
      },
    );
  }

  // Agregar estos métodos a la clase LocalDbService
  Future<void> insertMaterialPesca(MaterialPesca data) async {
    final db = await database;
    await db.insert(
      'material_pesca',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MaterialPesca>> getMaterialesNoSincronizados() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'material_pesca',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    return maps.map((map) => MaterialPesca.fromJson(map)).toList();
  }

  Future<void> marcarComoSincronizado(String nroGuia, int lote) async {
    final db = await database;
    await db.update(
      'material_pesca',
      {
        'sincronizado': 1,
        'fechaSincronizacion': DateTime.now().toIso8601String(),
      },
      where: 'nroGuia = ? AND lote = ?',
      whereArgs: [nroGuia, lote],
    );
  }

  /* Future<List<MaterialPesca>> getAllMaterialPesca() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'material_pesca',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    return maps.map((map) => MaterialPesca.fromJson(map)).toList();
  } */
  Future<void> corregirLotesCero() async {
    final db = await database;

    // Obtener todas las guías únicas con lotes cero
    final List<Map<String, dynamic>> guiasConLoteCero = await db.rawQuery('''
      SELECT DISTINCT nroGuia 
      FROM material_pesca 
      WHERE lote = 0
    ''');

    // Para cada guía con lotes cero
    for (final guia in guiasConLoteCero) {
      final nroGuia = guia['nroGuia'] as String;

      // Obtener el máximo lote para esta guía
      final maxLoteMap = await db.rawQuery(
        '''
        SELECT MAX(lote) as maxLote 
        FROM material_pesca 
        WHERE nroGuia = ? AND lote > 0
      ''',
        [nroGuia],
      );

      final maxLote = maxLoteMap.first['maxLote'] as int? ?? 0;
      final nuevoLote = maxLote + 1;

      // Actualizar todos los lotes cero de esta guía
      await db.update(
        'material_pesca',
        {'lote': nuevoLote},
        where: 'nroGuia = ? AND lote = 0',
        whereArgs: [nroGuia],
      );
    }
  }

  Future<List<MaterialPesca>> getAllMaterialPesca() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'material_pesca',
      where: 'sincronizado = ?',
      whereArgs: [0],
      orderBy: 'nroGuia, lote', // Ordenamos por guía y luego por lote
    );

    // Filtramos para mantener solo el primer registro de cada guía
    final Map<String, MaterialPesca> uniqueGuides = {};
    for (final map in maps) {
      final material = MaterialPesca.fromJson(map);
      if (!uniqueGuides.containsKey(material.nroGuia)) {
        uniqueGuides[material.nroGuia] = material;
      }
    }

    return uniqueGuides.values.toList();
  }

  Future<MaterialPesca?> getMaterialPescaByGuide(String nroGuia) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'material_pesca',
      where: 'nroGuia = ?',
      whereArgs: [nroGuia],
      limit: 1,
    );
    return maps.isNotEmpty ? MaterialPesca.fromJson(maps.first) : null;
  }

  Future<void> updateMaterialPesca(MaterialPesca data) async {
    final db = await database;
    await db.update(
      'material_pesca',
      data.toMap(),
      where: 'nroGuia = ?',
      whereArgs: [data.nroGuia],
    );
  }

  Future<void> clearMaterialPesca() async {
    final db = await database;
    await db.delete(
      'material_pesca',
      where: '''
        (lote IS NULL OR lote = 0) 
      ''',
    );
  }

  // Método para insertar datos de pesca (alias de saveFishingData)
  Future<void> insertKilos(FishingData data) async {
    await saveFishingData(data);
  }

  // Método principal para guardar datos
  Future<void> saveFishingData(FishingData data) async {
    final db = await database;
    await db.insert(
      _tableName,
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener todos los registros (alias de getAllFishingData)
  Future<List<FishingData>> getAllKilos() async {
    return await getAllFishingData();
  }

  // Método principal para obtener todos los datos
  Future<List<FishingData>> getAllFishingData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return maps.map((map) => FishingData.fromJson(map)).toList();
  }

  // Obtener datos por número de guía
  Future<FishingData?> getFishingDataByGuide(String nroGuia) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'nroGuia = ?',
      whereArgs: [nroGuia],
      limit: 1,
    );
    return maps.isNotEmpty ? FishingData.fromJson(maps.first) : null;
  }

  // Actualizar solo los kilos remitidos
  Future<void> updateKilos(String nroGuia, int kilos) async {
    final db = await database;
    await db.update(
      _tableName,
      {'totalKilosRemitidos': kilos},
      where: 'nroGuia = ?',
      whereArgs: [nroGuia],
    );
  }

  // Actualizar los datos de horas
  Future<void> updateHours(String nroGuia, Map<String, String> hours) async {
    final db = await database;
    await db.update(
      _tableName,
      hours,
      where: 'nroGuia = ?',
      whereArgs: [nroGuia],
    );
  }

  // Método adicional para limpiar la base de datos (útil para pruebas)
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(_tableName);
  }

  Future<void> deleteFishingData(String nroGuia) async {
    final db = await database;
    await db.delete(_tableName, where: 'nroGuia = ?', whereArgs: [nroGuia]);
  }

  Future<void> deleteMaterialPescaByGuide(String nroGuia) async {
    final db = await database;
    await db.delete(
      'material_pesca',
      where: 'nroGuia = ?',
      whereArgs: [nroGuia],
    );
  }

  Future<void> upsertMaterialPesca(MaterialPesca data) async {
    final db = await database;
    await db.insert(
      'material_pesca',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MaterialPesca>> getMaterialesByGuia(String nroGuia) async {
    final db = await database;

    // Primero obtener todos los materiales sin filtrar por lote
    final List<Map<String, dynamic>> maps = await db.query(
      'material_pesca',
      where: 'nroGuia = ?',
      whereArgs: [nroGuia],
      orderBy: 'lote ASC',
    );

    // Convertir a objetos MaterialPesca
    final materiales = maps.map((map) => MaterialPesca.fromJson(map)).toList();

    // Filtrar y corregir lotes cero solo para visualización
    return materiales.map((material) {
      return material.lote == 0
          ? material.copyWith(lote: 1) // Corregir solo para visualización
          : material;
    }).toList();
  }
}
