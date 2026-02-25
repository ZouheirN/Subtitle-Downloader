import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../hive/downloaded_subtitles_box.dart';
import '../../../main.dart';

class FirestoreService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>>? listener;

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

  void startListener() {
    if (FirebaseAuth.instance.currentUser == null) return;

    listener = firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('downloadedSubtitles');

    listener?.snapshots().listen(
      (event) {
        logger.i('Firestore listener triggered\n${event.docs.toString()}');

        for (int i = 0; i < event.docChanges.length; i++) {
          final subtitle = event.docChanges[i].doc.data();
          final change = event.docChanges[i].type;

          logger.i(change);

          switch (change) {
            case DocumentChangeType.added:
              // check if subtitle is in local data
              // if not, add it
              if (!DownloadedSubtitlesBox.isSubtitleDownloaded(
                  subtitle?['url'])) {
                DownloadedSubtitlesBox.addDownloadedSubtitle(
                  subtitle?['url'],
                  subtitle?['releaseName'],
                  subtitle?['author'],
                  subtitle?['movieName'],
                  localOnly: true,
                );
              }
              break;
            case DocumentChangeType.modified:
              // check if subtitle is in local data
              // if not, remove then add it
              if (DownloadedSubtitlesBox.isSubtitleDownloaded(
                  subtitle?['url'])) {
                DownloadedSubtitlesBox.deleteDownloadedSubtitle(
                    subtitle?['url'], true);
              }

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
              if (DownloadedSubtitlesBox.isSubtitleDownloaded(
                  subtitle?['url'])) {
                DownloadedSubtitlesBox.deleteDownloadedSubtitle(
                    subtitle?['url'], true);
              }
              break;
          }
        }
      },
      onError: (error) => logger.e("Listen failed: $error"),
    );
  }

  void cancelListener() {
    if (FirebaseAuth.instance.currentUser == null) return;

    listener?.snapshots().listen((event) {}).cancel();
  }

  Future<void> deleteAccount() async {
    if (FirebaseAuth.instance.currentUser == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await firestore.collection('users').doc(uid).delete();
    } catch (e) {
      logger.e(e);
    }
  }
}
