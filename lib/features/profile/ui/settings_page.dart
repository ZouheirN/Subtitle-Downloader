import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:subtitle_downloader/components/language_dropdown.dart';
import 'package:subtitle_downloader/features/authentication/repos/auth_service.dart';
import 'package:subtitle_downloader/hive/downloaded_subtitles_box.dart';

import '../../../hive/settings_box.dart';
import '../bloc/profile_bloc.dart';

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
                if (FirebaseAuth.instance.currentUser == null) {
                  DownloadedSubtitlesBox.clearAllDownloadedSubtitles(
                      localOnly: true);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Clear Downloaded Subtitles History'),
                        content: const Text(
                            'Do you also want to remove the downloaded subtitles from the cloud?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              DownloadedSubtitlesBox
                                  .clearAllDownloadedSubtitles(
                                      localOnly: false);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Downloaded Subtitles History Cleared'),
                                ),
                              );
                            },
                            child: const Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () {
                              DownloadedSubtitlesBox
                                  .clearAllDownloadedSubtitles(localOnly: true);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Downloaded Subtitles History Cleared'),
                                ),
                              );
                            },
                            child: const Text('Local Only'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            if (FirebaseAuth.instance.currentUser != null)
              Column(
                children: [
                  const Divider(),
                  ListTile(
                    title: const Text('Send Password Reset Email'),
                    leading: const Icon(Icons.password_rounded),
                    onTap: () async {
                      await AuthService().sendPasswordResetEmail(
                          FirebaseAuth.instance.currentUser!.email!);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset email sent'),
                        ),
                      );
                    },
                  ),
                  BlocConsumer<ProfileBloc, ProfileState>(
                    listener: (context, state) {
                      if (state is DeleteAccountSuccessfulState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account successfully deleted'),
                          ),
                        );
                        Navigator.of(context).pop();
                      } else if (state is DeleteAccountErrorState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.errorMessage),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is DeleteAccountLoadingState) {
                        return const ListTile(
                          title: Text(
                            'Deleting Account...',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          leading: CircularProgressIndicator(
                            color: Colors.red,
                          ),
                        );
                      }

                      return ListTile(
                        title: const Text(
                          'Delete Account',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        leading: const Icon(
                          Icons.delete_forever_rounded,
                          color: Colors.red,
                        ),
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete your Account?'),
                                content: const Text(
                                    '''If you select Delete we will delete your account on our server.

Your app data will also be deleted and you won't be able to retrieve it.

Since this is a security-sensitive operation, you may be asked to login before your account can be deleted.'''),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                    onPressed: () {
                                      context
                                          .read<ProfileBloc>()
                                          .add(DeleteAccountEvent(context));
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
