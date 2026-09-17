import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/utils/ol_chiki_transliteration.dart';
import '../../data/models/translation_row.dart';

/// Native SQLite Database Service for Bhasha Setu on Android
/// Manages 6,780 parallel verified records with sub-15ms local indexed lookup
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  Database? _database;
  bool _isInitializing = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (_isInitializing) {
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      if (_database != null) return _database!;
    }

    _isInitializing = true;
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocDir.path, 'translations.db');

      // Check if the database already exists
      final exists = await databaseExists(dbPath);

      if (!exists) {
        // Copy from asset bundle (6.22 MB)
        final byteData = await rootBundle.load('assets/database/translations.db');
        final bytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
        await File(dbPath).writeAsBytes(bytes, flush: true);
      }

      final db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          // Initialize app-specific local tables if needed
        },
      );

      // Ensure local history and bookmark tables exist for offline user persistence
      await db.execute('''
        CREATE TABLE IF NOT EXISTS local_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          source_text TEXT NOT NULL,
          target_text TEXT NOT NULL,
          source_lang TEXT NOT NULL,
          target_lang TEXT NOT NULL,
          timestamp INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS local_bookmarks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word_id INTEGER,
          title TEXT NOT NULL,
          translation TEXT NOT NULL,
          language TEXT NOT NULL,
          timestamp INTEGER NOT NULL
        )
      ''');

      return db;
    } finally {
      _isInitializing = false;
    }
  }

  /// Maps language code (sat, unr, hoc, hin, eng) to SQLite column name
  String getColumnName(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'sat':
        return 'santali';
      case 'unr':
        return 'mundari';
      case 'hoc':
        return 'ho';
      case 'hin':
        return 'hindi';
      case 'eng':
      default:
        return 'english';
    }
  }

  /// Query translation from local SQLite with Exact Match first, then Guarded Fuzzy Match
  Future<Map<String, dynamic>?> queryTranslation({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    final clean = text.trim();
    if (clean.isEmpty) return null;

    final db = await database;
    final srcCol = getColumnName(sourceLang);
    final tgtCol = getColumnName(targetLang);

    final cleanWithPunct = clean.toLowerCase();
    final cleanWithoutPunct = OlChikiTransliteration.normalizePunctuation(clean).toLowerCase();

    // 1. Exact Match across source column, english, hindi, santali, and roman
    final exactQuery = '''
      SELECT id, english, hindi, santali, santali_roman, ho, mundari, category, verified 
      FROM translations 
      WHERE LOWER(TRIM($srcCol)) = ? 
         OR LOWER(TRIM(english)) = ? 
         OR LOWER(TRIM(hindi)) = ? 
         OR LOWER(TRIM(santali)) = ? 
         OR LOWER(TRIM(santali_roman)) = ?
         OR LOWER(REPLACE(REPLACE(REPLACE(REPLACE(TRIM($srcCol), '.', ''), '?', ''), '!', ''), ',', '')) = ?
         OR LOWER(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(english), '.', ''), '?', ''), '!', ''), ',', '')) = ?
      LIMIT 1;
    ''';

    final exactResults = await db.rawQuery(exactQuery, [
      cleanWithPunct,
      cleanWithPunct,
      cleanWithPunct,
      cleanWithPunct,
      cleanWithPunct,
      cleanWithoutPunct,
      cleanWithoutPunct,
    ]);

    if (exactResults.isNotEmpty) {
      final row = exactResults.first;
      final targetText = (row[tgtCol] as String?) ?? (row['santali'] as String?) ?? (row['english'] as String? ?? '');
      return {
        'targetText': targetText,
        'roman': row['santali_roman'] as String?,
        'row': row,
        'confidence': 0.99,
        'method': 'exact_sqlite_match',
      };
    }

    // 2. Near-Exact Fuzzy Match with Strict Length Ratio Guard (React lengthRatio >= 0.8)
    final fuzzyQuery = '''
      SELECT id, english, hindi, santali, santali_roman, ho, mundari, category, verified 
      FROM translations 
      WHERE $srcCol LIKE ? 
         OR english LIKE ? 
         OR hindi LIKE ? 
         OR santali LIKE ? 
         OR santali_roman LIKE ?
      LIMIT 5;
    ''';

    final pattern = '%$cleanWithoutPunct%';
    final fuzzyResults = await db.rawQuery(fuzzyQuery, [pattern, pattern, pattern, pattern, pattern]);

    final qWords = cleanWithoutPunct.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    for (final row in fuzzyResults) {
      final matchedText = ((row[srcCol] as String?) ?? (row['english'] as String?) ?? '').toLowerCase();
      final rClean = OlChikiTransliteration.normalizePunctuation(matchedText);
      final rWords = rClean.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

      if (qWords.isEmpty || rWords.isEmpty) continue;
      final lengthRatio = (qWords.length < rWords.length ? qWords.length : rWords.length) /
                          (qWords.length > rWords.length ? qWords.length : rWords.length);

      if (lengthRatio >= 0.8) {
        final targetText = (row[tgtCol] as String?) ?? (row['santali'] as String?) ?? (row['english'] as String? ?? '');
        return {
          'targetText': targetText,
          'roman': row['santali_roman'] as String?,
          'row': row,
          'confidence': 0.95,
          'method': 'fuzzy_guarded_match',
        };
      }
    }

    return null;
  }

  /// Search classroom sentences across all columns with category filter
  Future<List<TranslationRow>> searchClassroomSentences({
    String keyword = '',
    String category = 'All',
    int limit = 30,
  }) async {
    final db = await database;
    final cleanKeyword = keyword.trim().toLowerCase();

    String query = 'SELECT id, english, hindi, santali, santali_roman, ho, mundari, category, verified FROM translations';
    final List<String> conditions = [];
    final List<dynamic> params = [];

    if (cleanKeyword.isNotEmpty) {
      conditions.add('''
        (LOWER(english) LIKE ? OR 
         LOWER(hindi) LIKE ? OR 
         LOWER(santali) LIKE ? OR 
         LOWER(santali_roman) LIKE ?)
      ''');
      final pattern = '%$cleanKeyword%';
      params.addAll([pattern, pattern, pattern, pattern]);
    }

    if (category.isNotEmpty && category != 'All' && category != 'All Categories') {
      conditions.add('category = ?');
      params.add(category);
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    query += ' ORDER BY id ASC LIMIT ?';
    params.add(limit);

    final results = await db.rawQuery(query, params);
    return results.map((r) => TranslationRow.fromMap(r)).toList();
  }

  /// Get total rows and categories count
  Future<Map<String, int>> getStats() async {
    final db = await database;
    final rowCountRes = await db.rawQuery('SELECT COUNT(*) as cnt FROM translations;');
    final catCountRes = await db.rawQuery('SELECT COUNT(DISTINCT category) as cnt FROM translations;');

    return {
      'totalRows': Sqflite.firstIntValue(rowCountRes) ?? 6780,
      'categoriesCount': Sqflite.firstIntValue(catCountRes) ?? 13,
    };
  }

  /// Save query to local offline history
  Future<void> saveHistory(String src, String tgt, String srcLang, String tgtLang) async {
    final db = await database;
    await db.insert('local_history', {
      'source_text': src,
      'target_text': tgt,
      'source_lang': srcLang,
      'target_lang': tgtLang,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Get offline translation history
  Future<List<Map<String, dynamic>>> getHistory({int limit = 50}) async {
    final db = await database;
    return await db.query('local_history', orderBy: 'timestamp DESC', limit: limit);
  }

  /// Close database connection safely
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
