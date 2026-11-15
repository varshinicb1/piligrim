import 'dart:convert';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piligrim/core/companion/companion_controller.dart';
import 'package:piligrim/core/companion/still_companion_controller.dart';

void main() {
  late StillCompanionController controller;
  late CompanionDirector director;

  setUp(() {
    controller = StillCompanionController();
    director = CompanionDirector(controller);
  });

  tearDown(() => controller.dispose());

  test('input names match the published contract', () {
    final contract = File('assets/companion/companion-contract.json');
    final raw = contract.readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final names = (json['inputs'] as Map<String, dynamic>).keys;
    expect(names.toSet(), CompanionInputs.all.toSet());
  });

  test('every pose has still art', () {
    for (final pose in CompanionPose.values) {
      expect(File(pose.asset).existsSync(), isTrue, reason: pose.asset);
    }
  });

  test('rests idle, and tired when the mood is tired', () {
    expect(controller.pose, CompanionPose.idle);
    controller.mood = CompanionMood.tired;
    expect(controller.pose, CompanionPose.tired);
  });

  test('body states follow the spec priority', () {
    controller.thinking = true;
    expect(controller.pose, CompanionPose.thinking);
    controller.listening = true;
    expect(controller.pose, CompanionPose.listening);
    controller.quiet = true;
    expect(controller.pose, CompanionPose.quiet);
    controller.sleeping = true;
    expect(controller.pose, CompanionPose.sleeping);
  });

  test('vow progress is a percentage of today', () {
    director.onVowsChanged(done: 3, total: 6);
    expect(controller.currentDayProgress, 50);
    director.onVowsChanged(done: 0, total: 0);
    expect(controller.currentDayProgress, 0);
  });

  test('greets on a normal open', () {
    director.onAppOpened(missedDays: 0, firstOpenToday: true);
    expect(controller.pose, CompanionPose.greet);
  });

  test('comforts instead of greeting after missed days', () {
    director.onAppOpened(missedDays: 2, firstOpenToday: true);
    expect(controller.pose, CompanionPose.comfort);
    expect(controller.currentMood, CompanionMood.tender);
  });

  test('a one-shot pose ends and reports that it is done', () {
    fakeAsync((async) {
      final events = <CompanionEvent>[];
      controller.events.listen(events.add);
      director.onDayCompleted();
      async.flushMicrotasks();
      expect(controller.pose, CompanionPose.celebrate);
      expect(events, [CompanionEvent.celebratePeak]);

      async.elapse(const Duration(seconds: 2));
      expect(controller.pose, CompanionPose.idle);
      expect(events.last, CompanionEvent.celebrateDone);
    });
  });

  test('a celebration waits until devotional audio ends', () {
    director.onDevotionalAudio(playing: true);
    director.onMilestone();
    expect(controller.pose, CompanionPose.quiet);
    director.onDevotionalAudio(playing: false);
    expect(controller.pose, CompanionPose.celebrate);
  });

  test('comfort cancels a running celebration', () {
    director.onDayCompleted();
    controller.comfort();
    expect(controller.pose, CompanionPose.comfort);
  });

  test('finishing the journey ends in the proud pose', () {
    director.onJourneyCompleted();
    expect(controller.pose, CompanionPose.proud);
  });

  test('time of day bands', () {
    expect(timeOfDayBandFor(DateTime(2027, 1, 1, 5)), TimeOfDayBand.dawn);
    expect(timeOfDayBandFor(DateTime(2027, 1, 1, 12)), TimeOfDayBand.day);
    expect(timeOfDayBandFor(DateTime(2027, 1, 1, 18)), TimeOfDayBand.dusk);
    expect(timeOfDayBandFor(DateTime(2027, 1, 1, 23)), TimeOfDayBand.night);
    expect(timeOfDayBandFor(DateTime(2027, 1, 1, 2)), TimeOfDayBand.night);
  });
}
