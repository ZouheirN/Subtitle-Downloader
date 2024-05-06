import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:subtitle_downloader/hive/settings_box.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      'https://avatars.githubusercontent.com/u/13942674?v=4'),
                ),
                const Gap(20),
                const Text(
                  'John Doe',
                  style: TextStyle(fontSize: 20),
                ),
                const Gap(20),
                const Divider(),
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
              ],
            ),
          ),
        ));
  }
}
