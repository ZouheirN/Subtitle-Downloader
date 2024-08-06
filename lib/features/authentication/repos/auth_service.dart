import 'package:firebase_auth/firebase_auth.dart';
import 'package:subtitle_downloader/main.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // update the user's display name and trigger auth state changes
      await userCredential.user!.updateDisplayName(username);

      return userCredential.user;
    } catch (e) {
      logger.e(e);
    }

    return null;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      logger.e(e);
    }

    return null;
  }

  Future<void> signOut() async {
    try {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
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
