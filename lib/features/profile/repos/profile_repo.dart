import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../main.dart';
import '../../firestore/repos/firestore_service.dart';

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

  Future<Either<RepositoryError, void>> deleteAccount(
      BuildContext context) async {
    try {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.delete();

        // cancel the listener
        FirestoreService().cancelListener();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        try {
          final result = await _reauthenticateAndDelete(context);
          result.fold(
            (l) {
              return left(l);
            },
            (r) {
              return right(null);
            },
          );
        } catch (e) {
          rethrow;
        }
      }
    } catch (e) {
      logger.e(e);
    }

    return left(RepositoryError('An error occurred'));
  }

  Future<Either<RepositoryError, void>> _reauthenticateAndDelete(
      BuildContext context) async {
    try {
      final providerData = _auth.currentUser?.providerData.first;

      if (AppleAuthProvider().providerId == providerData!.providerId) {
        await _auth.currentUser!
            .reauthenticateWithProvider(AppleAuthProvider());
      } else if (GoogleAuthProvider().providerId == providerData.providerId) {
        await _auth.currentUser!
            .reauthenticateWithProvider(GoogleAuthProvider());
      } else {
        final emailTextEditingController = TextEditingController();
        final passwordTextEditingController = TextEditingController();
        final formKey = GlobalKey<FormState>();

        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailTextEditingController,
                    decoration: const InputDecoration(hintText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordTextEditingController,
                    decoration: const InputDecoration(hintText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        AuthCredential credentials =
                            EmailAuthProvider.credential(
                                email: emailTextEditingController.text.trim(),
                                password:
                                    passwordTextEditingController.text.trim());

                        try {
                          await _auth.currentUser
                              ?.reauthenticateWithCredential(credentials);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-mismatch' ||
                              e.code == 'invalid-credential' ||
                              e.code == 'invalid-email' ||
                              e.code == 'wrong-password' ||
                              e.code == 'user-not-found') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Invalid credentials'),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text('Reauthenticate'),
                  )
                ],
              ),
            );
          },
        );
      }

      await _auth.currentUser?.delete();

      // cancel the listener
      FirestoreService().cancelListener();

      return right(null);
    } on FirebaseAuthException catch (e) {
      logger.e(e);
      if (e.code == 'user-mismatch' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-email' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        return left(RepositoryError('Invalid credentials'));
      }
    } catch (e) {
      logger.e(e);
    }

    return left(RepositoryError('An error occurred'));
  }
}
