import 'package:flutter/foundation.dart';
import 'package:pedometer_app/services/shared_preferences_service.dart';

class AppModel extends ChangeNotifier {

  late int _dailyGoal;

  Future<void> loadFromPrefs() async {
    var preferences = await SharedPreferencesService.getInstance();
    _dailyGoal = preferences.dailyGoal;
    notifyListeners();
  }

  int get dailyGoal {
    return _dailyGoal;
  }

  set dailyGoal(int value) {
    _dailyGoal = value;
    SharedPreferencesService.getInstance().then((preferences) {
      preferences.dailyGoal = _dailyGoal;
    },);
    notifyListeners();
  }
}