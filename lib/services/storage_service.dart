import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyImagePath = 'image_path';
  static const String _keySize = 'overlay_size';
  static const String _keyEnabled = 'overlay_enabled';
  static const String _keyPosX = 'overlay_pos_x';
  static const String _keyPosY = 'overlay_pos_y';
  static const String _keyLockScreen = 'overlay_lock_screen';

  static Future<void> saveLockScreen(bool lock) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLockScreen, lock);
  }

  static Future<bool> getLockScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLockScreen) ?? true; // Default locked
  }

  static Future<void> saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyImagePath, path);
  }

  static Future<String?> getImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyImagePath);
  }

  static Future<void> saveSize(String size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySize, size);
  }

  static Future<String> getSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySize) ?? 'M';
  }

  static Future<void> saveEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, enabled);
  }

  static Future<bool> getEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? false;
  }

  static Future<void> savePosition(int x, int y) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPosX, x);
    await prefs.setInt(_keyPosY, y);
  }

  static Future<Map<String, int>?> getPosition() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_keyPosX) && prefs.containsKey(_keyPosY)) {
      return {
        'x': prefs.getInt(_keyPosX)!,
        'y': prefs.getInt(_keyPosY)!,
      };
    }
    return null;
  }
}
