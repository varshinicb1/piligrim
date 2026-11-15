import 'dart:convert';

import 'package:flutter/services.dart';

import 'content_pack.dart';

/// Where pack files come from. The app ships with [AssetContentSource]; a
/// downloaded-pack source can replace it without touching any screen.
abstract interface class ContentSource {
  /// Reads a UTF-8 file from pack [packId], for example `pack.json` or
  /// `strings/te.json`.
  Future<String> readText(String packId, String relativePath);
}

/// Reads packs bundled in the app under `assets/content/<packId>/`.
class AssetContentSource implements ContentSource {
  AssetContentSource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  @override
  Future<String> readText(String packId, String relativePath) =>
      _bundle.loadString('assets/content/$packId/$relativePath');
}

class ContentRepository {
  ContentRepository(this._source);

  static const baseLanguage = 'en';

  final ContentSource _source;

  Future<ContentPack> loadPack(String packId) async {
    final raw = await _source.readText(packId, 'pack.json');
    return ContentPack.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Loads the wording for [languageCode].
  ///
  /// Throws a [FormatException] if the base language is missing any wording
  /// the pack's template or prayers refer to, so a broken pack is rejected
  /// rather than showing a blank or a key on screen.
  Future<PackStrings> loadStrings(ContentPack pack, String languageCode) async {
    final fallback = await _readStrings(pack.id, baseLanguage);
    final missing = [
      for (final key in pack.requiredTextKeys)
        if (fallback[key] is! String) key,
      for (final prayer in pack.prayers)
        if (fallback[prayer.linesKey] is! List) prayer.linesKey,
    ];
    if (missing.isNotEmpty) {
      throw FormatException(
        'Content pack ${pack.id} has no $baseLanguage wording for '
        '${missing.join(', ')}',
      );
    }
    final primary =
        languageCode != baseLanguage && pack.languages.contains(languageCode)
        ? await _readStrings(pack.id, languageCode)
        : fallback;
    return PackStrings(primary: primary, fallback: fallback);
  }

  Future<Map<String, dynamic>> _readStrings(String packId, String code) async {
    final raw = await _source.readText(packId, 'strings/$code.json');
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
