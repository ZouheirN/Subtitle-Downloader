import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:subtitle_downloader/hive/settings_box.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'features/main/app_navigation.dart';

final logger = Logger();

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  await Hive.openBox('settingsBox');
  await Hive.openBox('recentSearchesBox');
  await Hive.openBox('downloadedSubtitlesBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settingsBox').listenable(),
      builder: (BuildContext context, Box<dynamic> value, Widget? child) {
        // get the theme mode from the settings box
        final themeMode = SettingsBox.getThemeMode();

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: AppNavigation.router,
          themeMode: themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light,
          theme: FlexThemeData.light(
            scheme: FlexScheme.blue,
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: 7,
            subThemesData: const FlexSubThemesData(
              blendOnLevel: 10,
              blendOnColors: false,
              useTextTheme: true,
              useM2StyleDividerInM3: true,
              alignedDropdown: true,
              useInputDecoratorThemeInDialogs: true,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
            swapLegacyOnMaterial3: true,
          ),
          darkTheme: FlexThemeData.dark(
            scheme: FlexScheme.blue,
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: 13,
            subThemesData: const FlexSubThemesData(
              blendOnLevel: 20,
              useTextTheme: true,
              useM2StyleDividerInM3: true,
              alignedDropdown: true,
              useInputDecoratorThemeInDialogs: true,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
            swapLegacyOnMaterial3: true,
          ),
        );
      },
    );
  }
}
