import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../hive/downloaded_subtitles_box.dart';

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

  void listenForUpdates() {
    final docRef = firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('downloadedSubtitles');
    docRef.snapshots().listen(
      (event) {
        for (int i = 0; i < event.docChanges.length; i++) {
          final subtitle = event.docChanges[i].doc.data();
          final change = event.docChanges[i].type;

          switch (change) {
            case DocumentChangeType.added:
              // check if subtitle is in local data
              // if not, add it
              DownloadedSubtitlesBox.isSubtitleDownloaded(subtitle?['url'])
                  ? null
                  : DownloadedSubtitlesBox.addDownloadedSubtitle(
                      subtitle?['url'],
                      subtitle?['releaseName'],
                      subtitle?['author'],
                      subtitle?['movieName'],
                      localOnly: true,
                    );
              break;
            case DocumentChangeType.modified:
              // check if subtitle is in local data
              // if not, remove then add it
              DownloadedSubtitlesBox.isSubtitleDownloaded(subtitle?['url'])
                  ? null
                  : DownloadedSubtitlesBox.deleteDownloadedSubtitle(
                      subtitle?['url']);

              DownloadedSubtitlesBox.addDownloadedSubtitle(
                subtitle?['url'],
                subtitle?['releaseName'],
                subtitle?['author'],
                subtitle?['movieName'],
                localOnly: true,
              );
              break;
            case DocumentChangeType.removed:
              // check if subtitle is in local data
              // if not, remove it
              DownloadedSubtitlesBox.isSubtitleDownloaded(subtitle?['url'])
                  ? null
                  : DownloadedSubtitlesBox.deleteDownloadedSubtitle(
                      subtitle?['url']);
              break;
          }
        }
      },
      onError: (error) => print("Listen failed: $error"),
    );
  }
}
