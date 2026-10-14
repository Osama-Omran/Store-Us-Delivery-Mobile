import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';

/// A successfully fetched JSON snapshot, never a pending POST/PUT mutation.
class OfflineCachedResponse {
  const OfflineCachedResponse({
    required this.body,
    required this.savedAt,
    required this.statusCode,
  });

  final dynamic body;
  final DateTime savedAt;
  final int statusCode;
}

/// Authenticated per-session encrypted GET snapshots, stored persistently.
/// The encryption key is in secure storage, NEVER in SQLite or a request URL.
class OfflineCacheStore {
  OfflineCacheStore._();
  static final OfflineCacheStore instance = OfflineCacheStore._();

  static const _dbName = 'storeus_offline_read_cache.db';
  static const _maxRows = 220;
  static const _maxResponseBytes = 2 * 1024 * 1024; // 2 MB / response.
  static const _maxDatabaseBytes = 40 * 1024 * 1024; // 40 MB snapshots.

  final _algorithm = AesGcm.with256bits();
  final _secureStorage = const FlutterSecureStorage();
  final Map<String, Future<SecretKey>> _sessionKeys = {};
  Future<Database>? _opening;

  Future<Database> get _db => _opening ??= _open();

  Future<Database> _open() async {
    final root = await getDatabasesPath();
    return openDatabase(
      '$root/$_dbName',
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE read_cache (
            cache_key TEXT PRIMARY KEY,
            session_id TEXT NOT NULL,
            encrypted_json TEXT NOT NULL,
            saved_at INTEGER NOT NULL,
            status_code INTEGER NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_read_cache_session ON read_cache(session_id)',
        );
        await db.execute(
          'CREATE INDEX idx_read_cache_date ON read_cache(saved_at)',
        );
      },
    );
  }

  Future<String> fingerprint(String value) async {
    final hash = await Sha256().hash(utf8.encode(value));
    return base64Url.encode(hash.bytes);
  }

  Future<SecretKey> _keyFor(String sessionId) => _sessionKeys.putIfAbsent(
        sessionId,
        () async {
          final storageKey = 'storeus_read_cache_aes_$sessionId';
          final stored = await _secureStorage.read(key: storageKey);
          if (stored != null) return SecretKey(base64Decode(stored));
          final newKey = await _algorithm.newSecretKey();
          await _secureStorage.write(
            key: storageKey,
            value: base64Encode(await newKey.extractBytes()),
          );
          return newKey;
        },
      );

  Future<void> save({
    required String sessionId,
    required String cacheKey,
    required dynamic body,
    required int statusCode,
  }) async {
    final raw = utf8.encode(jsonEncode(body));
    if (raw.length > _maxResponseBytes) return;
    final secretBox = await _algorithm.encrypt(
      raw,
      secretKey: await _keyFor(sessionId),
    );
    final encrypted = jsonEncode({
      'nonce': base64Encode(secretBox.nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    });

    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert(
        'read_cache',
        {
          'cache_key': cacheKey,
          'session_id': sessionId,
          'encrypted_json': encrypted,
          'saved_at': DateTime.now().millisecondsSinceEpoch,
          'status_code': statusCode,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // Keep the cache bounded without deleting the newest snapshot per URL.
      await txn.rawDelete('''
        DELETE FROM read_cache
        WHERE cache_key IN (
          SELECT cache_key FROM read_cache
          ORDER BY saved_at DESC LIMIT -1 OFFSET $_maxRows
        )
      ''');
      final sizeRows = await txn.rawQuery(
        'SELECT cache_key, length(encrypted_json) AS bytes '
        'FROM read_cache ORDER BY saved_at ASC',
      );
      var totalBytes = sizeRows.fold<int>(
        0,
        (sum, row) => sum + (row['bytes'] as int),
      );
      for (final row in sizeRows) {
        if (totalBytes <= _maxDatabaseBytes) break;
        await txn.delete(
          'read_cache',
          where: 'cache_key = ?',
          whereArgs: [row['cache_key']],
        );
        totalBytes -= row['bytes'] as int;
      }
    });
  }

  Future<OfflineCachedResponse?> read({
    required String sessionId,
    required String cacheKey,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'read_cache',
      columns: ['encrypted_json', 'saved_at', 'status_code'],
      where: 'cache_key = ? AND session_id = ?',
      whereArgs: [cacheKey, sessionId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    try {
      final json = jsonDecode(rows.first['encrypted_json'] as String)
          as Map<String, dynamic>;
      final box = SecretBox(
        base64Decode(json['ciphertext'] as String),
        nonce: base64Decode(json['nonce'] as String),
        mac: Mac(base64Decode(json['mac'] as String)),
      );
      final decrypted = await _algorithm.decrypt(
        box,
        secretKey: await _keyFor(sessionId),
      );
      return OfflineCachedResponse(
        body: jsonDecode(utf8.decode(decrypted)),
        savedAt: DateTime.fromMillisecondsSinceEpoch(rows.first['saved_at'] as int),
        statusCode: rows.first['status_code'] as int,
      );
    } catch (_) {
      // If key/material is lost or snapshot is damaged, never present it.
      return null;
    }
  }

  /// Invoke on explicit logout (before clearing secure storage), if policy
  /// requires deletion of all account snapshots from the device.
  Future<void> clearSession(String sessionId) async {
    final db = await _db;
    await db.delete(
      'read_cache',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    await _secureStorage.delete(key: 'storeus_read_cache_aes_$sessionId');
    _sessionKeys.remove(sessionId);
  }
}
