/// An observance described as data, so that a new mala, vratham or fast is a
/// content pack and not a code change.
///
/// Templates carry ids only. All wording lives in the content pack's string
/// tables, keyed as `vow.<id>.title` and `milestone.<id>.title`.
class ObservanceTemplate {
  const ObservanceTemplate({
    required this.id,
    required this.version,
    required this.tradition,
    required this.minDays,
    required this.defaultDays,
    required this.maxDays,
    required this.vows,
    required this.milestones,
    required this.mascotTheme,
  });

  factory ObservanceTemplate.fromJson({
    required String id,
    required String version,
    required Map<String, dynamic> json,
  }) {
    final length = json['lengthDays'] as Map<String, dynamic>;
    final template = ObservanceTemplate(
      id: id,
      version: version,
      tradition: json['tradition'] as String,
      minDays: length['min'] as int,
      defaultDays: length['default'] as int,
      maxDays: length['max'] as int,
      vows: [
        for (final vow in json['vows'] as List<dynamic>)
          VowDefinition(id: (vow as Map<String, dynamic>)['id'] as String),
      ],
      milestones: [
        for (final milestone in json['milestones'] as List<dynamic>)
          MilestoneDefinition.fromJson(milestone as Map<String, dynamic>),
      ],
      mascotTheme: json['mascotTheme'] as String,
    );
    template._validate();
    return template;
  }

  final String id;
  final String version;
  final String tradition;
  final int minDays;
  final int defaultDays;
  final int maxDays;
  final List<VowDefinition> vows;
  final List<MilestoneDefinition> milestones;
  final String mascotTheme;

  bool isValidLength(int days) => days >= minDays && days <= maxDays;

  /// Milestones that fall on [dayNumber] of a journey of [plannedDays].
  List<MilestoneDefinition> milestonesOnDay(int dayNumber, int plannedDays) => [
    for (final milestone in milestones)
      if (milestone.dayNumberFor(plannedDays) == dayNumber) milestone,
  ];

  void _validate() {
    if (minDays < 1 || minDays > defaultDays || defaultDays > maxDays) {
      throw FormatException(
        'Template $id needs 1 <= min <= default <= max days',
      );
    }
    final vowIds = vows.map((vow) => vow.id).toSet();
    if (vowIds.length != vows.length) {
      throw FormatException('Template $id has duplicate vow ids');
    }
  }
}

class VowDefinition {
  const VowDefinition({required this.id});

  final String id;

  String get titleKey => 'vow.$id.title';
}

enum MilestoneAnchor { start, end }

class MilestoneDefinition {
  const MilestoneDefinition({
    required this.id,
    required this.anchor,
    required this.offsetDays,
  });

  factory MilestoneDefinition.fromJson(Map<String, dynamic> json) =>
      MilestoneDefinition(
        id: json['id'] as String,
        anchor: MilestoneAnchor.values.byName(json['anchor'] as String),
        offsetDays: (json['offsetDays'] as int?) ?? 0,
      );

  final String id;

  /// Whether [offsetDays] counts from the first day or from the last day.
  final MilestoneAnchor anchor;
  final int offsetDays;

  String get titleKey => 'milestone.$id.title';

  /// The 1-based day this milestone falls on. May be outside the journey if
  /// the template is misconfigured; callers compare it to real day numbers.
  int dayNumberFor(int plannedDays) => switch (anchor) {
    MilestoneAnchor.start => 1 + offsetDays,
    MilestoneAnchor.end => plannedDays + offsetDays,
  };
}
