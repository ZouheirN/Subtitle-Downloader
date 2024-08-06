import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:subtitle_downloader/main.dart';

class FirestoreService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void addSubtitleToFirestore(
      String url, String releaseName, String author, String movieName) {
    if (FirebaseAuth.instance.currentUser == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    firestore
        .collection('users')
        .doc(uid)
        .collection('downloadedSubtitles')
        .add({
      'url': url,
      'releaseName': releaseName,
      'author': author,
      'movieName': movieName,
    });
  }

  void clearAllSubtitlesFromFirestore() {
    if (FirebaseAuth.instance.currentUser == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    firestore
        .collection('users')
        .doc(uid)
        .collection('downloadedSubtitles')
        .get()
        .then((value) {
      for (var doc in value.docs) {
        doc.reference.delete();
      }
    });
  }

  Future<void> deleteSubtitleFromFirestore(String url) async {
    if (FirebaseAuth.instance.currentUser == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    await firestore
        .collection('users')
        .doc(uid)
        .collection('downloadedSubtitles')
        .where('url', isEqualTo: url)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        doc.reference.delete();
      }
    });
  }

  Stream<QuerySnapshot> getAllSubtitlesFromFirestoreStream() {
    if (FirebaseAuth.instance.currentUser == null) return const Stream.empty();

    final uid = FirebaseAuth.instance.currentUser!.uid;
    return firestore
        .collection('users')
        .doc(uid)
        .collection('downloadedSubtitles')
        .snapshots();
  }
}
