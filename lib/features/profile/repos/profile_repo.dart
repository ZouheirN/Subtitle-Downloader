import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../main.dart';
import '../../firestore/repos/firestore_service.dart';
import '../../main/app_navigation.dart';

class RepositoryError {
  final String message;

  RepositoryError(this.message);
}

class ProfileRepo {
  final _auth = FirebaseAuth.instance;
  final _storageRef = FirebaseStorage.instance.ref();

  Future<Uint8List?> getProfilePicture() async {
    try {
      final imageRef =
          _storageRef.child('profile_pictures/${_auth.currentUser?.uid}.jpg');

      final imageBytes = await imageRef.getData();

      return imageBytes;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  Future<Uint8List?> changeProfilePicture(XFile image) async {
    final imageRef =
        _storageRef.child('profile_pictures/${_auth.currentUser?.uid}.jpg');

    try {
      final imageBytes = await image.readAsBytes();
      await imageRef.putData(imageBytes);

      return imageBytes;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  Future<Either<RepositoryError, void>> deleteAccount() async {
    try {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.delete();

        // cancel the listener
        FirestoreService().cancelListener();

        // delete subtitles from Firestore
        FirestoreService().deleteAccount();

        return right(null);
      }
    } on FirebaseAuthException catch (e) {
      logger.e(e);
      if (e.code == "requires-recent-login") {
        try {
          final result = await _reauthenticateAndDelete();

          return result.fold(
            (l) => left(l),
            (r) => right(null),
          );
        } catch (e) {
          logger.e(e);
          return left(RepositoryError('Re-authentication failed'));
        }
      } else {
        return left(RepositoryError(e.message ?? 'FirebaseAuthException'));
      }
    } catch (e) {
      logger.e(e);
      return left(RepositoryError('An unexpected error occurred'));
    }

    return left(RepositoryError('An error occurred'));
  }

  Future<Either<RepositoryError, void>> _reauthenticateAndDelete() async {
    try {
      final providerData = _auth.currentUser?.providerData.firstOrNull;
      if (providerData == null) {
        return left(RepositoryError('No provider data available'));
      }

      if (AppleAuthProvider().providerId == providerData.providerId) {
        await _auth.currentUser!
            .reauthenticateWithProvider(AppleAuthProvider());
      } else if (GoogleAuthProvider().providerId == providerData.providerId) {
        await _auth.currentUser!
            .reauthenticateWithProvider(GoogleAuthProvider());
      } else {
        final navContext =
            AppNavigation.rootNavigatorKey.currentContext;
        if (navContext == null) {
          return left(RepositoryError('Navigation context unavailable'));
        }

        final passwordTextEditingController = TextEditingController();

        // Show dialog and await user input
        final String? password = await showDialog<String>(
          context: navContext,
          builder: (context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordTextEditingController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Password'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(passwordTextEditingController.text);
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            );
          },
        );

        if (password == null || password.isEmpty) {
          return left(RepositoryError('Password is required'));
        }

        AuthCredential credentials = EmailAuthProvider.credential(
          email: _auth.currentUser!.email!,
          password: password,
        );

        await _auth.currentUser?.reauthenticateWithCredential(credentials);
      }

      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
      } else {
        return left(RepositoryError('No current user to delete'));
      }

      FirestoreService().cancelListener();

      // delete subtitles from Firestore
      FirestoreService().deleteAccount();

      // delete profile picture
      final imageRef =
          _storageRef.child('profile_pictures/${_auth.currentUser?.uid}.jpg');
      try {
        await imageRef.delete();
      } catch (e) {
        logger.e(e);
      }

      return right(null);
    } on FirebaseAuthException catch (e) {
      logger.e(e);
      if (e.code == 'user-mismatch' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-email' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        return left(RepositoryError('Invalid credentials'));
      } else if (e.code == 'web-context-canceled') {
        return left(RepositoryError('Operation canceled'));
      }
    } catch (e) {
      logger.e(e);
    }

    return left(RepositoryError('An error occurred'));
  }
}
