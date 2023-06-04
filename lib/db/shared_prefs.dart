import 'package:shared_preferences/shared_preferences.dart';

abstract class SharedPrefs {
  static late final SharedPreferences _prefs;

  static const String _totalKey = "TOTAL";

  static Future<void> loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await getTotal();
  }

  static Future<bool> setDouble(String key, double value) async {
    return _prefs.setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    return _prefs.getDouble(key);
  }

  static Future<double> getTotal() async {
    double loadedTotal = await getDouble(_totalKey) ?? 0.0;
    total = loadedTotal;
    return loadedTotal;
  }

  static Future<bool> setTotal(double value) async {
    total = value;
    return await setDouble(_totalKey, value);
  } 

  static late double total;
}
