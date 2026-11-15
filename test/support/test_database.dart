import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:piligrim/core/db/database.dart';

AppDatabase openTestDatabase() => AppDatabase(
  DatabaseConnection(
    NativeDatabase.memory(),
    // Lets widget tests finish without drift's stream-cleanup timer pending.
    closeStreamsSynchronously: true,
  ),
);
