
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String _keyIsAppOpenFirstTime = 'is_first_time';

  static bool _isFirstTime = true;

  static Future<void> initialLoad() async {
    getAppOpensFirstTimeStatus();
  }

  /// Save value to SharedPreferences
  static Future<void> setAppOpensFirstTimeStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstTime = value;
    await prefs.setBool(_keyIsAppOpenFirstTime, value);
  }

  /// Get value from SharedPreferences
  static Future<bool> getAppOpensFirstTimeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true if the key doesn't exist
    _isFirstTime = prefs.getBool(_keyIsAppOpenFirstTime) ?? true;
    return _isFirstTime;
  }

  static bool get getIsAppOpensFirstTime => _isFirstTime;
}
