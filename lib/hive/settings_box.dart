import 'package:hive/hive.dart';

class SettingsBox {
  static Box settingsBox = Hive.box('settingsBox');

  static String getThemeMode() {
    return settingsBox.get('themeMode', defaultValue: 'light');
  }

  static void toggleThemeMode() {
    final themeMode = getThemeMode();
    settingsBox.put('themeMode', themeMode == 'dark' ? 'light' : 'dark');
  }

  static String getDefaultLanguage() {
    return settingsBox.get('defaultLanguage', defaultValue: 'EN');
  }

  static setDefaultLanguage(String language) {
    settingsBox.put('defaultLanguage', language);
  }
}