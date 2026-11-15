import 'dart:async';

import 'package:flutter/foundation.dart';

import 'companion_controller.dart';

/// The still pose the companion is shown in. Names match the art files in
/// assets/companion/.
enum CompanionPose {
  idle,
  greet,
  listening,
  thinking,
  quiet,
  tired,
  sleeping,
  celebrate,
  proud,
  comfort;

  String get asset => 'assets/companion/chinnu-$name.svg';
}

/// A [CompanionController] with no animation: it picks one still pose from
/// the inputs, following the body-layer priority in the motion spec.
///
/// The Rive-backed controller replaces this class and nothing else changes,
/// because screens only use [CompanionController] and CompanionView.
class StillCompanionController extends ChangeNotifier
    implements CompanionController {
  static const _oneShotLength = Duration(milliseconds: 1800);

  final _events = StreamController<CompanionEvent>.broadcast();
  Timer? _oneShotTimer;
  CompanionPose? _oneShot;

  CompanionMood _mood = CompanionMood.calm;
  double _dayProgress = 0;
  TimeOfDayBand _timeOfDay = TimeOfDayBand.day;
  bool _listening = false;
  bool _thinking = false;
  bool _quiet = false;
  bool _sleeping = false;
  bool _reduceMotion = false;

  CompanionMood get currentMood => _mood;
  double get currentDayProgress => _dayProgress;
  TimeOfDayBand get currentTimeOfDay => _timeOfDay;
  bool get isReducingMotion => _reduceMotion;

  CompanionPose get pose {
    if (_sleeping) return CompanionPose.sleeping;
    if (_quiet) return CompanionPose.quiet;
    if (_oneShot != null) return _oneShot!;
    if (_listening) return CompanionPose.listening;
    if (_thinking) return CompanionPose.thinking;
    if (_mood == CompanionMood.tired) return CompanionPose.tired;
    return CompanionPose.idle;
  }

  @override
  set mood(CompanionMood value) => _set(() => _mood = value);

  @override
  set dayProgress(double percent) =>
      _set(() => _dayProgress = percent.clamp(0, 100).toDouble());

  @override
  set timeOfDay(TimeOfDayBand value) => _set(() => _timeOfDay = value);

  @override
  set listening(bool value) => _set(() => _listening = value);

  @override
  set thinking(bool value) => _set(() => _thinking = value);

  @override
  set quiet(bool value) => _set(() => _quiet = value);

  @override
  set sleeping(bool value) {
    final waking = _sleeping && !value;
    _set(() => _sleeping = value);
    if (waking) _events.add(CompanionEvent.wakeDone);
  }

  @override
  set reduceMotion(bool value) => _set(() => _reduceMotion = value);

  @override
  void look(double x, double y) {}

  @override
  void greet() {
    // The spec: no greeting while sleeping or quiet.
    if (_sleeping || _quiet) return;
    _play(CompanionPose.greet);
  }

  @override
  void celebrate(CelebrateLevel level) {
    if (_quiet) return;
    _sleeping = false;
    _play(
      level == CelebrateLevel.journeyComplete
          ? CompanionPose.proud
          : CompanionPose.celebrate,
      onDone: CompanionEvent.celebrateDone,
    );
    _events.add(CompanionEvent.celebratePeak);
  }

  @override
  void comfort() {
    // Comfort cancels a running celebration and rests in tender mood.
    _sleeping = false;
    _mood = CompanionMood.tender;
    _play(CompanionPose.comfort, onDone: CompanionEvent.comfortDone);
  }

  @override
  Stream<CompanionEvent> get events => _events.stream;

  void _play(CompanionPose pose, {CompanionEvent? onDone}) {
    _oneShotTimer?.cancel();
    _oneShot = pose;
    notifyListeners();
    _oneShotTimer = Timer(_oneShotLength, () {
      _oneShot = null;
      if (onDone != null) _events.add(onDone);
      notifyListeners();
    });
  }

  void _set(VoidCallback change) {
    change();
    notifyListeners();
  }

  @override
  void dispose() {
    _oneShotTimer?.cancel();
    unawaited(_events.close());
    super.dispose();
  }
}
