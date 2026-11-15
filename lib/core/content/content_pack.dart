import '../vow_engine/vow_engine.dart';

/// A versioned bundle of everything an observance needs: the template, the
/// prayers and the wording in each language.
///
/// Schema: see docs/CONTENT_PACKS.md.
class ContentPack {
  const ContentPack({
    required this.id,
    required this.version,
    required this.isVetted,
    required this.languages,
    required this.template,
    required this.prayers,
  });

  static const supportedSchemaVersion = 1;

  factory ContentPack.fromJson(Map<String, dynamic> json) {
    final schema = json['schemaVersion'];
    if (schema != supportedSchemaVersion) {
      throw FormatException(
        'Content pack schema $schema is not supported '
        '(this build reads $supportedSchemaVersion)',
      );
    }
    final id = json['id'] as String;
    final version = json['version'] as String;
    return ContentPack(
      id: id,
      version: version,
      isVetted: json['reviewStatus'] == 'approved',
      languages: (json['languages'] as List<dynamic>).cast<String>(),
      template: ObservanceTemplate.fromJson(
        id: id,
        version: version,
        json: json['template'] as Map<String, dynamic>,
      ),
      prayers: [
        for (final prayer in json['prayers'] as List<dynamic>)
          PrayerDefinition(
            id: (prayer as Map<String, dynamic>)['id'] as String,
          ),
      ],
    );
  }

  final String id;
  final String version;

  /// False until the Guruswami advisory group has approved the pack. The UI
  /// shows a draft notice while this is false.
  final bool isVetted;
  final List<String> languages;
  final ObservanceTemplate template;
  final List<PrayerDefinition> prayers;

  /// Every string key the base language must define.
  List<String> get requiredTextKeys => [
    'template.title',
    for (final vow in template.vows) vow.titleKey,
    for (final milestone in template.milestones) milestone.titleKey,
    for (final prayer in prayers) prayer.titleKey,
  ];
}

class PrayerDefinition {
  const PrayerDefinition({required this.id});

  final String id;

  String get titleKey => 'prayer.$id.title';
  String get linesKey => 'prayer.$id.lines';
}

/// A pack's wording in one language, falling back to the pack's base
/// language for any key a translation has not covered yet.
class PackStrings {
  const PackStrings({required this.primary, required this.fallback});

  final Map<String, dynamic> primary;
  final Map<String, dynamic> fallback;

  /// The text for [key]. A missing key returns the key itself so that gaps
  /// are visible in testing rather than blank on screen.
  String text(String key) {
    final value = primary[key] ?? fallback[key];
    return value is String ? value : key;
  }

  List<String> lines(String key) {
    final value = primary[key] ?? fallback[key];
    return value is List ? value.cast<String>() : const [];
  }
}
