import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

/// Holds the database encryption key.
abstract interface class DatabaseKeyStore {
  /// Returns the key as 64 hex characters, creating it on first use.
  Future<String> readOrCreateKey();
}

/// Keeps the key in Android Keystore or iOS Keychain backed storage.
///
/// The key never leaves the device, so the database file is unreadable if it
/// is copied elsewhere. For the same reason Android auto-backup is turned
/// off in AndroidManifest.xml: a restored database without its key would be
/// lost data.
class SecureDatabaseKeyStore implements DatabaseKeyStore {
  SecureDatabaseKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _keyName = 'piligrim.db.key.v1';

  final FlutterSecureStorage _storage;

  @override
  Future<String> readOrCreateKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) return existing;
    final key = generateDatabaseKey();
    await _storage.write(key: _keyName, value: key);
    return key;
  }
}

String generateDatabaseKey() {
  final random = Random.secure();
  return [
    for (var i = 0; i < 32; i++)
      random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}

/// Unlocks [database] with [hexKey]. Must be the first thing run on a new
/// connection.
///
/// Throws if the bundled SQLite has no encryption support, so that a build
/// misconfiguration can never silently store journeys in plain text.
void applyEncryptionKey(Database database, String hexKey) {
  if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(hexKey)) {
    throw ArgumentError('Database key must be 64 lowercase hex characters');
  }
  if (database.select('PRAGMA cipher').isEmpty) {
    throw StateError(
      'This SQLite build has no encryption support. Check the sqlite3 '
      'hooks section in pubspec.yaml.',
    );
  }
  database.execute("PRAGMA key = \"x'$hexKey'\"");
  // Fails here, rather than on a later query, if the key is wrong.
  database.select('SELECT count(*) FROM sqlite_master');
}

/// Opens the encrypted on-device database on a background isolate.
QueryExecutor openEncryptedExecutor(DatabaseKeyStore keyStore) {
  return LazyDatabase(() async {
    final key = await keyStore.readOrCreateKey();
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'piligrim.db'));
    return NativeDatabase.createInBackground(
      file,
      setup: (database) => applyEncryptionKey(database, key),
    );
  });
}
