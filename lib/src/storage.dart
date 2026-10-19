import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalStore {
  Future<String?> getString(String key);
  Future<List<String>?> getStringList(String key);
  Future<bool?> getBool(String key);
  Future<void> setString(String key, String value);
  Future<void> setStringList(String key, List<String> value);
  Future<void> setBool(String key, bool value);
  Future<void> remove(String key);
}

class PreferencesStore implements LocalStore {
  final _prefs = SharedPreferencesAsync();
  @override
  Future<String?> getString(String key) => _prefs.getString(key);
  @override
  Future<List<String>?> getStringList(String key) => _prefs.getStringList(key);
  @override
  Future<bool?> getBool(String key) => _prefs.getBool(key);
  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
  @override
  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);
  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  @override
  Future<void> remove(String key) => _prefs.remove(key);
}
