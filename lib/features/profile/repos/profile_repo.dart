import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  Future<Either<RepositoryError, void>> deleteAccount(String password) async {
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
          final result = await _reauthenticateAndDelete(password);

          // Properly return the result from the fold
          return result.fold(
            (l) => left(l),
            (r) => right(null),
          );
        } catch (e) {
          // Catch and log the reauthentication error
          logger.e(e);
          return left(RepositoryError('Re-authentication failed'));
        }
      } else {
        // Handle other FirebaseAuthException cases if necessary
        return left(RepositoryError(e.message ?? 'FirebaseAuthException'));
      }
    } catch (e) {
      // Log and return a generic error if an unexpected exception occurs
      logger.e(e);
      return left(RepositoryError('An unexpected error occurred'));
    }

    // Default return if no conditions are met
    return left(RepositoryError('An error occurred'));
  }

  Future<Either<RepositoryError, void>> _reauthenticateAndDelete(
      String password) async {
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
      }
    } catch (e) {
      logger.e(e);
    }

    return left(RepositoryError('An error occurred'));
  }
}
