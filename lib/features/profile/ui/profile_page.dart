import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:subtitle_downloader/hive/settings_box.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () {
                context.pushNamed('Settings');
              },
            ),
          ],
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
                ListTile(
                  title: const Text('View Downloaded Subtitles History'),
                  leading: const Icon(Icons.history_rounded),
                  onTap: () {
                    context.pushNamed('Downloaded Subtitles History');
                  },
                )
              ],
            ),
          ),
        ));
  }
}
