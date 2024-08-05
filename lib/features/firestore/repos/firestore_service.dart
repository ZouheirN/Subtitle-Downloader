import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void addSubtitleToFirestore(
      String url, String releaseName, String author, String movieName) {
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

  Stream<QuerySnapshot> getAllSubtitlesFromFirestore() {
    if (FirebaseAuth.instance.currentUser == null) return const Stream.empty();

    final uid = FirebaseAuth.instance.currentUser!.uid;
    return firestore
        .collection('users')
        .doc(uid)
        .collection('downloadedSubtitles')
        .snapshots();
  }
}
