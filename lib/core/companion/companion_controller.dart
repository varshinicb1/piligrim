// The companion contract, v0.1, as published by the character and motion
// work in `rive/companion_controller.dart`. Input names must match
// assets/companion/companion-contract.json exactly; that work owns them.
//
// Feature code talks only to [CompanionController], through
// [CompanionDirector]. Until a .riv file exists the app uses
// StillCompanionController, which shows the still poses.

enum CompanionMood { calm, glad, thoughtful, tired, tender }

enum TimeOfDayBand { dawn, day, dusk, night }

enum CelebrateLevel { dayComplete, milestone, journeyComplete }

enum CompanionEvent { celebratePeak, celebrateDone, comfortDone, wakeDone }

abstract final class CompanionInputs {
  static const stateMachine = 'CompanionSM';
  static const artboard = 'Companion';
  static const mood = 'mood';
  static const dayProgress = 'dayProgress';
  static const timeOfDay = 'timeOfDay';
  static const listening = 'listening';
  static const thinking = 'thinking';
  static const quiet = 'quiet';
  static const sleeping = 'sleeping';
  static const greet = 'greet';
  static const celebrate = 'celebrate';
  static const celebrateLevel = 'celebrateLevel';
  static const comfort = 'comfort';
  static const lookX = 'lookX';
  static const lookY = 'lookY';
  static const reduceMotion = 'reduceMotion';

  static const all = [
    mood,
    dayProgress,
    timeOfDay,
    listening,
    thinking,
    quiet,
    sleeping,
    greet,
    celebrate,
    celebrateLevel,
    comfort,
    lookX,
    lookY,
    reduceMotion,
  ];
}

/// What feature code may do to the companion.
abstract interface class CompanionController {
  set mood(CompanionMood value);

  /// Share of today's vows checked, 0 to 100.
  set dayProgress(double percent);
  set timeOfDay(TimeOfDayBand value);
  set listening(bool value);
  set thinking(bool value);
  set quiet(bool value);
  set sleeping(bool value);
  set reduceMotion(bool value);

  /// Eye and head follow, -100 to 100 on each axis.
  void look(double x, double y);
  void greet();
  void celebrate(CelebrateLevel level);
  void comfort();
  Stream<CompanionEvent> get events;
}

/// App-side rules from the motion spec, applied before inputs reach the
/// character. Every screen goes through this so they all behave the same.
class CompanionDirector {
  CompanionDirector(this._controller);

  final CompanionController _controller;
  bool _quiet = false;
  CelebrateLevel? _pendingCelebrate;

  /// Call once when the app comes to the foreground.
  void onAppOpened({required int missedDays, required bool firstOpenToday}) {
    if (missedDays > 0) {
      // Never greet after missed days, and never shame.
      _controller.comfort();
    } else if (firstOpenToday) {
      _controller.greet();
    }
  }

  void onVowsChanged({required int done, required int total}) {
    _controller.dayProgress = total == 0 ? 0 : 100 * done / total;
  }

  void onDayCompleted() => _celebrate(CelebrateLevel.dayComplete);
  void onMilestone() => _celebrate(CelebrateLevel.milestone);
  void onJourneyCompleted() => _celebrate(CelebrateLevel.journeyComplete);

  void onDevotionalAudio({required bool playing}) {
    _quiet = playing;
    _controller.quiet = playing;
    final pending = _pendingCelebrate;
    if (!playing && pending != null) {
      _pendingCelebrate = null;
      _controller.celebrate(pending);
    }
  }

  void _celebrate(CelebrateLevel level) {
    if (_quiet) {
      // Wait until the prayer or bhajan ends.
      _pendingCelebrate = level;
    } else {
      _controller.celebrate(level);
    }
  }
}

TimeOfDayBand timeOfDayBandFor(DateTime time) => switch (time.hour) {
  >= 4 && < 7 => TimeOfDayBand.dawn,
  >= 7 && < 17 => TimeOfDayBand.day,
  >= 17 && < 20 => TimeOfDayBand.dusk,
  _ => TimeOfDayBand.night,
};
