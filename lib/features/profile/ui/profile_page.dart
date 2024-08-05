import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (context, snapshot) => Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      'https://avatars.githubusercontent.com/u/13942674?v=4'),
                ),
                const Gap(20),
                Text(
                  snapshot.data?.displayName ?? 'Not Logged In',
                  style: const TextStyle(fontSize: 20),
                ),
                const Gap(20),
                const Divider(),
                if (snapshot.data == null)
                  ListTile(
                    title: const Text('Login or Sign Up'),
                    leading: const Icon(Icons.login_rounded),
                    onTap: () {
                      context.pushNamed('Login');
                    },
                  )
                else
                  ListTile(
                    title: const Text('Logout'),
                    leading: const Icon(Icons.logout_rounded),
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                    },
                  ),
                ListTile(
                  title: const Text('View Downloaded Subtitles History'),
                  leading: const Icon(Icons.history_rounded),
                  onTap: () {
                    context.pushNamed('Downloaded Subtitles History');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
