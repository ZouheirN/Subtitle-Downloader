import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:subtitle_downloader/features/firestore/repos/firestore_service.dart';
import 'package:subtitle_downloader/main.dart';

class RepositoryError {
  final String message;

  RepositoryError(this.message);
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Either<RepositoryError, User?>> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // update the user's display name and trigger auth state changes
      await userCredential.user!.updateDisplayName(username);

      // start the listener
      FirestoreService().startListener();

      return right(userCredential.user);
    } on FirebaseAuthException catch (e) {
      logger.e(e);
      switch (e.code) {
        case 'email-already-in-use':
          return left(RepositoryError('Email already in use'));
        case 'invalid-email':
          return left(RepositoryError('Invalid email provided'));
        case 'operation-not-allowed':
          return left(RepositoryError('Operation not allowed'));
        case 'weak-password':
          return left(RepositoryError('Weak password provided'));
        case 'network-request-failed':
          return left(RepositoryError('Network request failed'));
        case 'too-many-requests':
          return left(
              RepositoryError('Too many requests. Please try again later'));
        default:
          return left(RepositoryError(e.message.toString()));
      }
    } catch (e) {
      logger.e(e);
      return right(null);
    }
  }

  Future<Either<RepositoryError, User?>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // start the listener
      FirestoreService().startListener();

      return right(userCredential.user);
    } on FirebaseAuthException catch (e) {
      logger.e(e);
      switch (e.code) {
        case 'user-not-found' || 'wrong-password' || 'invalid-credential':
          return left(RepositoryError('Invalid credentials provided'));
        case 'invalid-email':
          return left(RepositoryError('Invalid email provided'));
        case 'user-disabled':
          return left(RepositoryError('User has been disabled'));
        case 'too-many-requests':
          return left(
              RepositoryError('Too many requests. Please try again later'));
        case 'network-request-failed':
          return left(RepositoryError('Network request failed'));
        default:
          return left(RepositoryError(e.message.toString()));
      }
    } catch (e) {
      logger.e(e);
      return right(null);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      logger.e(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();

      final googleAuth = await googleUser?.authentication;

      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await _auth.signInWithCredential(cred);
    } catch (e) {
      logger.e(e);
    }

    return null;
  }

  Future<void> signOut() async {
    try {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        // cancel the listener
        FirestoreService().cancelListener();

        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      logger.e(e);
    }
  }
}
