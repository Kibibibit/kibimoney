import 'package:shared_preferences/shared_preferences.dart';

/// Stores methods and values related to the shared preferences cache.
/// Abstract as all members are static.
/// 
/// Make sure to call `loadPrefs()` before use.
abstract class SharedPrefs {
  /// The actual shared preferences client
  static late final SharedPreferences _prefs;

  static const String _totalKey = "TOTAL";

  /// Initialises the shared preferences cache, and works out the total.
  static Future<void> loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await getTotal();
  }

  /// Set/Add a an item with key `key` to value `value` in the shared preferences cache.
  static Future<bool> setDouble(String key, double value) async {
    return _prefs.setDouble(key, value);
  }

  /// Get a double with key `key` from the shared preferences cache.
  static Future<double?> getDouble(String key) async {
    return _prefs.getDouble(key);
  }

  /// Get the total amount of money from the cache
  static Future<double> getTotal() async {
    double loadedTotal = await getDouble(_totalKey) ?? 0.0;
    total = loadedTotal;
    return loadedTotal;
  }

  /// Set the total amount of money in the cache
  static Future<bool> setTotal(double value) async {
    total = value;
    return await setDouble(_totalKey, value);
  } 

  /// Money is stored here once loaded so we don't need to use async everywhere
  static late double total;
}
