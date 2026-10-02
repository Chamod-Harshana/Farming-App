import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:path/path.dart' as p;
import '../../domain/models/crop_model.dart';
import '../../domain/models/fertilizer_log_model.dart';
import '../../domain/models/pesticide_log_model.dart';
import '../../domain/models/financial_record_model.dart';
import '../../domain/models/irrigation_log_model.dart';

/// Lightweight Offline Local Database Helper
/// Manages SQLite local storage for crops, irrigation logs, fertilizer logs, pesticide logs, and financial records.
class CropDatabaseHelper {
  static final CropDatabaseHelper instance = CropDatabaseHelper._internal();
  CropDatabaseHelper._internal();

  static const String _tableName = 'crops';
  static const String _irrigationTable = 'irrigation_logs';
  static const String _fertilizerTable = 'fertilizer_logs';
  static const String _pesticideTable = 'pesticide_logs';
  static const String _financialTable = 'financial_records';

  static const String _prefsKey = 'offline_user_crops_v1';
  static const String _irrigPrefsKey = 'offline_irrigation_logs_v1';
  static const String _fertPrefsKey = 'offline_fertilizer_logs_v1';
  static const String _pestPrefsKey = 'offline_pesticide_logs_v1';
  static const String _finPrefsKey = 'offline_financial_records_v1';

  sqlite.Database? _db;

  /// Initialize Local Database & Create Tables
  Future<void> initDatabase() async {
    if (_db != null) return;
    try {
      if (!kIsWeb) {
        final dbPath = await sqlite.getDatabasesPath();
        final path = p.join(dbPath, 'farming_app_v3.db');
        _db = await sqlite.openDatabase(
          path,
          version: 3,
          onCreate: (db, version) async {
            await _createTables(db);
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 3) {
              await _createTables(db);
            }
          },
        );
      }
    } catch (e) {
      debugPrint('SQLite init notice (using shared_preferences fallback): $e');
    }
  }

  Future<void> _createTables(sqlite.Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT,
        nameSi TEXT,
        category TEXT,
        categorySi TEXT,
        iconName TEXT,
        imagePath TEXT,
        description TEXT,
        descriptionSi TEXT,
        soilType TEXT,
        soilTypeSi TEXT,
        harvestDays INTEGER,
        waterFrequency TEXT,
        waterFrequencySi TEXT,
        idealTemp TEXT,
        isPinned INTEGER,
        isDeleted INTEGER,
        createdAt TEXT,
        plantDate TEXT,
        landSize TEXT,
        plantCount INTEGER,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_irrigationTable (
        id TEXT PRIMARY KEY,
        crop_id TEXT,
        date TEXT,
        time TEXT,
        amount TEXT,
        method TEXT,
        next_date TEXT,
        notify INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_fertilizerTable (
        id TEXT PRIMARY KEY,
        crop_id TEXT,
        date TEXT,
        name TEXT,
        quantity TEXT,
        next_date TEXT,
        notify INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_pesticideTable (
        id TEXT PRIMARY KEY,
        crop_id TEXT,
        date TEXT,
        name TEXT,
        quantity TEXT,
        next_date TEXT,
        notify INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_financialTable (
        id TEXT PRIMARY KEY,
        crop_id TEXT,
        type TEXT,
        date TEXT,
        amount REAL,
        description TEXT,
        yield_quantity TEXT,
        notes TEXT
      )
    ''');
  }

  // ==========================================
  // 1. CROPS CRUD
  // ==========================================
  Future<List<CropModel>> getAllCropsRaw() async {
    List<CropModel> list = [];
    if (_db != null) {
      try {
        final List<Map<String, dynamic>> maps = await _db!.query(_tableName);
        list = maps.map((map) => CropModel.fromMap(map)).toList();
      } catch (e) {
        debugPrint('SQLite query error: $e');
      }
    }

    if (list.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_prefsKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final List<dynamic> rawList = json.decode(jsonString);
          list = rawList.map((item) => CropModel.fromMap(item as Map<String, dynamic>)).toList();
        } catch (e) {
          debugPrint('Prefs parse error: $e');
        }
      }
    }

    final validCrops = list.where((c) {
      final n = c.name.trim();
      final nSi = c.nameSi.trim();
      return (n.isNotEmpty && n != '()') || (nSi.isNotEmpty && nSi != '()');
    }).toList();

    return validCrops;
  }

  Future<void> _saveCropsToPrefs(List<CropModel> crops) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(crops.map((c) => c.toMap()).toList());
      await prefs.setString(_prefsKey, jsonString);
    } catch (e) {
      debugPrint('Error saving crops to prefs: $e');
    }
  }

  Future<List<CropModel>> getActiveCrops() async {
    final all = await getAllCropsRaw();
    final active = all.where((c) => !c.isDeleted).toList();

    active.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return active;
  }

  Future<List<CropModel>> getBinCrops() async {
    final all = await getAllCropsRaw();
    final bin = all.where((c) => c.isDeleted).toList();
    bin.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bin;
  }

  Future<void> insertCrop(CropModel crop) async {
    if (_db != null) {
      try {
        await _db!.insert(
          _tableName,
          crop.toMap(),
          conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
        );
      } catch (e) {
        debugPrint('SQLite insert error: $e');
      }
    }

    final crops = await getAllCropsRaw();
    crops.removeWhere((c) => c.id == crop.id);
    crops.add(crop);
    await _saveCropsToPrefs(crops);
  }

  Future<void> updateCrop(CropModel crop) async {
    if (_db != null) {
      try {
        await _db!.update(
          _tableName,
          crop.toMap(),
          where: 'id = ?',
          whereArgs: [crop.id],
        );
      } catch (e) {
        debugPrint('SQLite update error: $e');
      }
    }

    final crops = await getAllCropsRaw();
    final index = crops.indexWhere((c) => c.id == crop.id);
    if (index != -1) {
      crops[index] = crop;
    } else {
      crops.add(crop);
    }
    await _saveCropsToPrefs(crops);
  }

  Future<void> togglePin(String id, bool isPinned) async {
    final crops = await getAllCropsRaw();
    final index = crops.indexWhere((c) => c.id == id);
    if (index != -1) {
      final updated = crops[index].copyWith(isPinned: isPinned);
      await updateCrop(updated);
    }
  }

  Future<void> moveToBin(String id) async {
    final crops = await getAllCropsRaw();
    final index = crops.indexWhere((c) => c.id == id);
    if (index != -1) {
      final updated = crops[index].copyWith(
        isDeleted: true,
        isPinned: false,
      );
      await updateCrop(updated);
    }
  }

  Future<void> restoreFromBin(String id) async {
    final crops = await getAllCropsRaw();
    final index = crops.indexWhere((c) => c.id == id);
    if (index != -1) {
      final updated = crops[index].copyWith(isDeleted: false);
      await updateCrop(updated);
    }
  }

  Future<void> deletePermanently(String id) async {
    if (_db != null) {
      try {
        await _db!.delete(
          _tableName,
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (e) {
        debugPrint('SQLite delete error: $e');
      }
    }

    final crops = await getAllCropsRaw();
    crops.removeWhere((c) => c.id == id);
    await _saveCropsToPrefs(crops);
  }

  // ==========================================
  // 2. IRRIGATION LOGS CRUD
  // ==========================================
  Future<List<IrrigationLogModel>> getIrrigationLogs(String cropId) async {
    List<IrrigationLogModel> list = [];
    if (_db != null) {
      try {
        final maps = await _db!.query(
          _irrigationTable,
          where: 'crop_id = ?',
          whereArgs: [cropId],
          orderBy: 'date DESC',
        );
        list = maps.map((m) => IrrigationLogModel.fromMap(m)).toList();
      } catch (e) {
        debugPrint('SQLite irrig query error: $e');
      }
    }

    if (list.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('${_irrigPrefsKey}_$cropId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> raw = json.decode(jsonStr);
        list = raw.map((e) => IrrigationLogModel.fromMap(e)).toList();
      }
    }
    return list;
  }

  Future<void> insertIrrigationLog(IrrigationLogModel log) async {
    if (_db != null) {
      try {
        await _db!.insert(
          _irrigationTable,
          log.toMap(),
          conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
        );
      } catch (e) {
        debugPrint('SQLite irrig insert error: $e');
      }
    }

    final list = await getIrrigationLogs(log.cropId);
    list.removeWhere((item) => item.id == log.id);
    list.add(log);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_irrigPrefsKey}_${log.cropId}',
      json.encode(list.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> deleteIrrigationLog(String cropId, String logId) async {
    if (_db != null) {
      try {
        await _db!.delete(
          _irrigationTable,
          where: 'id = ?',
          whereArgs: [logId],
        );
      } catch (e) {
        debugPrint('SQLite irrig delete error: $e');
      }
    }
    final list = await getIrrigationLogs(cropId);
    list.removeWhere((item) => item.id == logId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_irrigPrefsKey}_$cropId',
      json.encode(list.map((e) => e.toMap()).toList()),
    );
  }

  // ==========================================
  // 3. FERTILIZER LOGS CRUD
  // ==========================================
  Future<List<FertilizerLogModel>> getFertilizerLogs(String cropId) async {
    List<FertilizerLogModel> list = [];
    if (_db != null) {
      try {
        final maps = await _db!.query(
          _fertilizerTable,
          where: 'crop_id = ?',
          whereArgs: [cropId],
          orderBy: 'date DESC',
        );
        list = maps.map((m) => FertilizerLogModel.fromMap(m)).toList();
      } catch (e) {
        debugPrint('SQLite fert query error: $e');
      }
    }

    if (list.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('${_fertPrefsKey}_$cropId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> raw = json.decode(jsonStr);
        list = raw.map((e) => FertilizerLogModel.fromMap(e)).toList();
      }
    }
    return list;
  }

  Future<void> insertFertilizerLog(FertilizerLogModel log) async {
    if (_db != null) {
      try {
        await _db!.insert(
          _fertilizerTable,
          log.toMap(),
          conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
        );
      } catch (e) {
        debugPrint('SQLite fert insert error: $e');
      }
    }

    final list = await getFertilizerLogs(log.cropId);
    list.removeWhere((item) => item.id == log.id);
    list.add(log);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_fertPrefsKey}_${log.cropId}',
      json.encode(list.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> deleteFertilizerLog(String cropId, String logId) async {
    if (_db != null) {
      try {
        await _db!.delete(
          _fertilizerTable,
          where: 'id = ?',
          whereArgs: [logId],
        );
      } catch (e) {
        debugPrint('SQLite fert delete error: $e');
      }
    }
    final list = await getFertilizerLogs(cropId);
    list.removeWhere((item) => item.id == logId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_fertPrefsKey}_$cropId',
      json.encode(list.map((e) => e.toMap()).toList()),
    );
  }

  // ==========================================
  // 4. PESTICIDE LOGS CRUD
  // ==========================================
  Future<List<PesticideLogModel>> getPesticideLogs(String cropId) async {
    List<PesticideLogModel> list = [];
    if (_db != null) {
      try {
        final maps = await _db!.query(
          _pesticideTable,
          where: 'crop_id = ?',
          whereArgs: [cropId],
          orderBy: 'date DESC',
        );
        list = maps.map((m) => PesticideLogModel.fromMap(m)).toList();
      } catch (e) {
        debugPrint('SQLite pest query error: $e');
      }
    }

    if (list.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('${_pestPrefsKey}_$cropId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> raw = json.decode(jsonStr);
        list = raw.map((e) => PesticideLogModel.fromMap(e)).toList();
      }
    }
    return list;
  }

  Future<void> insertPesticideLog(PesticideLogModel log) async {
    if (_db != null) {
      try {
        await _db!.insert(
          _pesticideTable,
          log.toMap(),
          conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
        );
      } catch (e) {
        debugPrint('SQLite pest insert error: $e');
      }
    }

    final list = await getPesticideLogs(log.cropId);
    list.removeWhere((item) => item.id == log.id);
    list.add(log);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_pestPrefsKey}_${log.cropId}',
      json.encode(list.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> deletePesticideLog(String cropId, String logId) async {
    if (_db != null) {
      try {
        await _db!.delete(
          _pesticideTable,
          where: 'id = ?',
          whereArgs: [logId],
        );
      } catch (e) {
        debugPrint('SQLite pest delete error: $e');
      }
    }
    final list = await getPesticideLogs(cropId);
    list.removeWhere((item) => item.id == logId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_pestPrefsKey}_$cropId',
      json.encode(list.map((e) => e.toMap()).toList()),
    );
  }

  // ==========================================
  // 5. FINANCIAL RECORDS CRUD
  // ==========================================
  Future<List<FinancialRecordModel>> getFinancialRecords(String cropId) async {
    List<FinancialRecordModel> list = [];
    if (_db != null) {
      try {
        final maps = await _db!.query(
          _financialTable,
          where: 'crop_id = ?',
          whereArgs: [cropId],
          orderBy: 'date DESC',
        );
        list = maps.map((m) => FinancialRecordModel.fromMap(m)).toList();
      } catch (e) {
        debugPrint('SQLite fin query error: $e');
      }
    }

    if (list.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('${_finPrefsKey}_$cropId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> raw = json.decode(jsonStr);
        list = raw.map((e) => FinancialRecordModel.fromMap(e)).toList();
      }
    }
    return list;
  }

  Future<void> insertFinancialRecord(FinancialRecordModel record) async {
    if (_db != null) {
      try {
        await _db!.insert(
          _financialTable,
          record.toMap(),
          conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
        );
      } catch (e) {
        debugPrint('SQLite fin insert error: $e');
      }
    }

    final list = await getFinancialRecords(record.cropId);
    list.removeWhere((item) => item.id == record.id);
    list.add(record);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_finPrefsKey}_${record.cropId}',
      json.encode(list.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> deleteFinancialRecord(String cropId, String recordId) async {
    if (_db != null) {
      try {
        await _db!.delete(
          _financialTable,
          where: 'id = ?',
          whereArgs: [recordId],
        );
      } catch (e) {
        debugPrint('SQLite fin delete error: $e');
      }
    }
    final list = await getFinancialRecords(cropId);
    list.removeWhere((item) => item.id == recordId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_finPrefsKey}_$cropId',
      json.encode(list.map((e) => e.toMap()).toList()),
    );
  }
}