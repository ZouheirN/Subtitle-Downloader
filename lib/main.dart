import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';

import 'features/main/app_navigation.dart';

final logger = Logger();

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  await Hive.openBox('settingsBox');

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
        final themeMode = value.get('themeMode', defaultValue: 'light');

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          darkTheme: ThemeData.dark(),
          themeMode: themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light,
          routerConfig: AppNavigation.router,
        );
      },
    );
  }
}
