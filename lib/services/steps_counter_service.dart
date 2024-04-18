import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:pedometer_app/services/shared_preferences_service.dart';

class StepCounterService {
  late int _steps;
  late bool _paused;
  late Duration _duration;

  Future<bool> needReset(DateTime timeStamp) async {
    var preferences = await SharedPreferencesService.getInstance();
    return !DateUtils.isSameDay(preferences.timeStamp, timeStamp);
  }

  Future<void> reset(DateTime timeStamp) async {
    var preferences = await SharedPreferencesService.getInstance();

    _steps = 0;
    _duration = Duration.zero;
    preferences.steps = 0;
    preferences.duration = Duration.zero;
  }

  Stream<(int, Duration)> get stepsStream async* {
    var source = Pedometer.stepCountStream;
    var preferences = await SharedPreferencesService.getInstance();

    _steps = preferences.steps;
    _duration = preferences.duration;

    await for (final stepCountEvent in source) {
      _paused = preferences.paused;

      bool isNeedReset = await needReset(stepCountEvent.timeStamp);
      if (isNeedReset) {
        reset(stepCountEvent.timeStamp);
      }

      if (isNeedReset || _paused || preferences.pedometerValue == 0) {
        preferences.pedometerValue = stepCountEvent.steps;
      }

      if (preferences.pedometerValue < stepCountEvent.steps) {
        _steps += (stepCountEvent.steps - preferences.pedometerValue);
        _duration += stepCountEvent.timeStamp.difference(preferences.timeStamp);

        preferences.steps = _steps;
        preferences.duration = _duration;
      }

      preferences.pedometerValue = stepCountEvent.steps;
      preferences.timeStamp = stepCountEvent.timeStamp;

      yield (_steps, _duration);
    }
  }
}
