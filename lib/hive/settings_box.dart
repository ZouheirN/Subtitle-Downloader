import 'package:hive/hive.dart';

import '../main.dart';

class SettingsBox {
  static Box settingsBox = Hive.box('settingsBox');

  static String getThemeMode() {
    logger.d('Getting theme mode');
    return settingsBox.get('themeMode', defaultValue: 'light');
  }

  static void toggleThemeMode() {
    final themeMode = getThemeMode();
    settingsBox.put('themeMode', themeMode == 'dark' ? 'light' : 'dark');
  }
}