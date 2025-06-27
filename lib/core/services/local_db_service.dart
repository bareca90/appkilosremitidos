import 'package:appkilosremitidos/models/fishing_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbService {
  static const String _dbName = 'fishing_datos.db';
  static const String _tableName = 'fishing_data';
  static const int _dbVersion = 3;

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
}
