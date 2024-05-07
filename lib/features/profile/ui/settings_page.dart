import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:subtitle_downloader/components/language_dropdown.dart';
import 'package:subtitle_downloader/hive/downloaded_subtitles_box.dart';

import '../../../hive/settings_box.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: SettingsBox.settingsBox.listenable(),
              builder: (context, value, child) {
                return ListTile(
                  title: Text(
                      'Switch to ${SettingsBox.getThemeMode() == 'light' ? 'Dark' : 'Light'} Mode'),
                  leading: SettingsBox.getThemeMode() == 'light'
                      ? const Icon(Icons.dark_mode)
                      : const Icon(Icons.light_mode),
                  onTap: () {
                    SettingsBox.toggleThemeMode();
                  },
                );
              },
            ),
            ValueListenableBuilder(
                valueListenable: SettingsBox.settingsBox.listenable(),
                builder: (context, value, child) {
                  return ListTile(
                    title: const Text('Default Language'),
                    leading: const Icon(Icons.language_rounded),
                    trailing: LanguageDropdown(
                      initialLanguage: SettingsBox.getDefaultLanguage(),
                      onLanguageChanged: (language) {
                        SettingsBox.setDefaultLanguage(language);
                      },
                    ),
                  );
                }),
            ListTile(
              title: const Text('Clear Downloaded Subtitles History'),
              leading: const Icon(Icons.history_rounded),
              onTap: () {
                DownloadedSubtitlesBox.clearAllDownloadedSubtitles();
              },
            ),
          ],
        ),
      ),
    );
  }
}
