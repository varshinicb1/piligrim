import 'dart:convert';

import '../db/database.dart';

/// Records local changes that should later reach the backend.
///
/// Repositories call [record] inside the same transaction as the change
/// itself. The backend thread supplies the uploader that drains the queue;
/// until sync exists the app uses [DisabledOutbox] and nothing is queued, so
/// a free user's journey never leaves the phone.
abstract interface class Outbox {
  Future<void> record({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, Object?> payload,
  });
}

class DisabledOutbox implements Outbox {
  const DisabledOutbox();

  @override
  Future<void> record({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, Object?> payload,
  }) async {}
}

class DatabaseOutbox implements Outbox {
  DatabaseOutbox(this._db, {required this._now});

  final AppDatabase _db;
  final DateTime Function() _now;

  @override
  Future<void> record({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, Object?> payload,
  }) {
    return _db
        .into(_db.outboxItems)
        .insert(
          OutboxItemsCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: jsonEncode(payload),
            createdAt: _now(),
          ),
        );
  }
}
