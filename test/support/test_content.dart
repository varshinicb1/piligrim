import 'dart:io';

import 'package:piligrim/core/content/content_repository.dart';

/// Serves packs straight from a folder on disk, read synchronously so it
/// also works inside widget tests. Defaults to the packs bundled in the app.
class DiskContentSource implements ContentSource {
  DiskContentSource({this.root = 'assets/content'});

  /// Packs used only by tests.
  DiskContentSource.fixtures() : root = 'test/fixtures/content';

  final String root;

  @override
  Future<String> readText(String packId, String relativePath) async =>
      File('$root/$packId/$relativePath').readAsStringSync();
}
