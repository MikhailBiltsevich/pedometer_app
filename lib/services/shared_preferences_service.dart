import 'package:shared_preferences/shared_preferences.dart';

const _pedometerValueKey = 'pedometer_value';
const _stepsKey = 'steps';
const _dailyGoalKey = 'daily_goal';
const _timeStampKey = 'time_stamp';
const _pausedKey = 'paused';
const _durationKey = 'duration';

class SharedPreferencesService {
  SharedPreferencesService._();

  static SharedPreferencesService? _instance;
  static late SharedPreferences _preferences;

  static Future<SharedPreferencesService> getInstance() async {
    _instance ??= SharedPreferencesService._();
    _preferences = await SharedPreferences.getInstance();

    return _instance!;
  }

  dynamic _getData(String key) {
    return _preferences.get(key);
  }

  void _setData(String key, dynamic value) {
    if (value is int) {
      _preferences.setInt(key, value);
    } else if (value is bool) {
      _preferences.setBool(key, value);
    } else if (value is DateTime) {
      _preferences.setString(key, value.toIso8601String());
    } else if (value is Duration) {
      _preferences.setInt(_durationKey, value.inMilliseconds);
    }
  }

  int get pedometerValue => _getData(_pedometerValueKey) ?? 0;
  set pedometerValue(int value) => _setData(_pedometerValueKey, value);

  int get steps => _getData(_stepsKey) ?? 0;
  set steps(int value) => _setData(_stepsKey, value);

  int get dailyGoal => _getData(_dailyGoalKey) ?? 6000;
  set dailyGoal(int value) => _setData(_dailyGoalKey, value);

  bool get paused => _getData(_pausedKey) ?? false;
  set paused(bool value) => _setData(_pausedKey, value);

  DateTime get timeStamp {
    var stored = _getData(_timeStampKey);
    return stored is String ? DateTime.parse(stored) : DateTime.now();
  }

  set timeStamp(DateTime value) => _setData(_timeStampKey, value);

  Duration get duration => Duration(milliseconds: _getData(_durationKey) ?? 0);
  set duration(Duration value) => _setData(_durationKey, value);
}
