import 'dart:convert';

import 'package:sqflite/sqflite.dart';

/// Durable outbox. Each Dart isolate opens its own SQLite connection.
/// SQLite transactions and a lease prevent foreground/background double sending.
class OfflineSyncStore {
  OfflineSyncStore._();
  static final OfflineSyncStore instance = OfflineSyncStore._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final root = await getDatabasesPath();
    _db = await openDatabase(
      '$root/storeus_offline_outbox.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE outbox (
            id TEXT PRIMARY KEY,
            session_id TEXT NOT NULL,
            method TEXT NOT NULL,
            endpoint TEXT NOT NULL,
            query_json TEXT NOT NULL,
            body_json TEXT,
            language TEXT,
            title TEXT NOT NULL,
            status TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            next_attempt_at INTEGER NOT NULL,
            lease_until INTEGER NOT NULL DEFAULT 0,
            attempts INTEGER NOT NULL DEFAULT 0,
            toast_pending INTEGER NOT NULL DEFAULT 0,
            last_error TEXT
          )
        ''');
        await db.execute('''
          CREATE INDEX idx_outbox_queue ON outbox
          (status, session_id, next_attempt_at, lease_until)
        ''');
      },
    );
    return _db!;
  }

  Future<void> stage({
    required String id,
    required String sessionId,
    required String method,
    required String endpoint,
    required Map<String, dynamic> query,
    required dynamic jsonBody,
    required String? language,
    required String title,
  }) async {
    final database = await db;
    final now = DateTime.now().millisecondsSinceEpoch;
    await database.insert('outbox', {
      'id': id,
      'session_id': sessionId,
      'method': method,
      'endpoint': endpoint,
      'query_json': jsonEncode(query),
      'body_json': jsonBody == null ? null : jsonEncode(jsonBody),
      'language': language,
      'title': title,
      'status': 'pending',
      'created_at': now,
      'next_attempt_at': now,
      // Initial request holds the lease. If the app dies before receiving a
      // response the worker can retry when this expires.
      'lease_until': now + const Duration(minutes: 2).inMilliseconds,
    });
  }

  Future<void> completed(String id, {bool needsToast = false}) async {
    final database = await db;
    await database.update('outbox', {
      'status': 'done',
      'lease_until': 0,
      'toast_pending': needsToast ? 1 : 0,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> pruneOldCompleted() async {
    final database = await db;
    final cutoff = DateTime.now().subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;
    await database.delete('outbox',
        where: "status = 'done' AND toast_pending = 0 AND created_at < ?",
        whereArgs: [cutoff]);
  }

  Future<void> remove(String id) async {
    final database = await db;
    await database.delete('outbox', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> releaseForRetry(String id, String reason) async {
    final database = await db;
    await database.update('outbox', {
      'status': 'pending',
      'lease_until': 0,
      'next_attempt_at': DateTime.now().millisecondsSinceEpoch,
      'last_error': reason,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, Object?>?> claimNext(String sessionId) async {
    final database = await db;
    final now = DateTime.now().millisecondsSinceEpoch;
    return database.transaction((txn) async {
      final rows = await txn.query('outbox',
          where: '''status = 'pending' AND session_id = ?
                    AND next_attempt_at <= ? AND lease_until <= ?''',
          whereArgs: [sessionId, now, now],
          orderBy: 'created_at ASC', limit: 1);
      if (rows.isEmpty) return null;
      final row = rows.first;
      await txn.update('outbox', {
        'lease_until': now + const Duration(minutes: 2).inMilliseconds,
        'attempts': (row['attempts'] as int) + 1,
      }, where: 'id = ?', whereArgs: [row['id']]);
      return row;
    });
  }

  Future<void> retryLater(String id, int attempts, String reason) async {
    final database = await db;
    // Exponential backoff, max 1h, with a cap of 12 executions.
    if (attempts >= 12) {
      await failed(id, reason);
      return;
    }
    final secs = (30 * (1 << (attempts < 7 ? attempts : 7))).clamp(60, 3600);
    final now = DateTime.now().millisecondsSinceEpoch;
    await database.update('outbox', {
      'status': 'pending',
      'lease_until': 0,
      'next_attempt_at': now + secs * 1000,
      'last_error': reason,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> failed(String id, String reason) async {
    final database = await db;
    await database.update('outbox', {
      'status': 'failed',
      'lease_until': 0,
      'last_error': reason,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> unsurfacedCompletions(
      String sessionId) async {
    final database = await db;
    return database.query('outbox',
        where: "status = 'done' AND session_id = ? AND toast_pending = 1",
        whereArgs: [sessionId], limit: 10);
  }

  Future<void> clearToastFlag(String id) async {
    final database = await db;
    await database.update('outbox', {'toast_pending': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> pendingCount(String sessionId) async {
    final database = await db;
    final result = await database.rawQuery(
        "SELECT COUNT(*) AS c FROM outbox WHERE session_id = ? AND status = 'pending'",
        [sessionId]);
    return (result.first['c'] as int?) ?? 0;
  }
}
