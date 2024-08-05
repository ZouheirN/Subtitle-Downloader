import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:subtitle_downloader/features/subtitles/bloc/subtitle_bloc.dart';
import 'package:subtitle_downloader/hive/downloaded_subtitles_box.dart';
import 'package:subtitle_downloader/main.dart';

import '../../firestore/repos/firestore_service.dart';

class DownloadedSubtitlesHistoryPage extends StatefulWidget {
  const DownloadedSubtitlesHistoryPage({super.key});

  @override
  State<DownloadedSubtitlesHistoryPage> createState() =>
      _DownloadedSubtitlesHistoryPageState();
}

class _DownloadedSubtitlesHistoryPageState
    extends State<DownloadedSubtitlesHistoryPage> {
  final SubtitleBloc subtitleBloc = SubtitleBloc();
  Stream<QuerySnapshot> firestoreStream = FirestoreService().getAllSubtitlesFromFirestore();

  @override
  Widget build(BuildContext context) {
    final subtitles = DownloadedSubtitlesBox.getAllDownloadedSubtitles();
    final movieNames = subtitles.map((e) => e.keys.first).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Subtitles History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreStream,
        builder: (context, snapshot) {
          // check if local data is in sync with firestore
          if (snapshot.hasData) {
            final firestoreData = snapshot.data!.docs;
            final localData = DownloadedSubtitlesBox.getAllDownloadedSubtitles();
            final localUrls = localData.expand((e) => e.values.first).map((e) => e['url']).toList();
            final firestoreUrls = firestoreData.map((e) => e['url']).toList();

            // add local data to firestore
            for (var localUrl in localUrls) {
              if (!firestoreUrls.contains(localUrl)) {
                final localSubtitle = localData.expand((e) => e.values.first).firstWhere((element) => element['url'] == localUrl);
                FirestoreService().addSubtitleToFirestore(
                  localSubtitle['url'],
                  localSubtitle['releaseName'],
                  localSubtitle['author'],
                  localSubtitle['movieName'],
                );
              }
            }

            // add firestore data to local if not present
            for (var doc in firestoreData) {
              if (!localUrls.contains(doc['url'])) {
                DownloadedSubtitlesBox.addDownloadedSubtitle(
                  doc['url'],
                  doc['releaseName'],
                  doc['author'],
                  doc['movieName'],
                  localOnly: true,
                );
              }
            }

            // remove conflicts
            for (var localUrl in localUrls) {
              if (firestoreUrls.contains(localUrl)) {
                final localSubtitle = localData.expand((e) => e.values.first).firstWhere((element) => element['url'] == localUrl);
                final firestoreSubtitle = firestoreData.firstWhere((element) => element['url'] == localUrl);
                if (localSubtitle['releaseName'] != firestoreSubtitle['releaseName'] ||
                    localSubtitle['author'] != firestoreSubtitle['author'] ||
                    localSubtitle['movieName'] != firestoreSubtitle['movieName']) {
                  DownloadedSubtitlesBox.addDownloadedSubtitle(
                    firestoreSubtitle['url'],
                    firestoreSubtitle['releaseName'],
                    firestoreSubtitle['author'],
                    firestoreSubtitle['movieName'],
                    localOnly: true,
                  );
                }
              }
            }
          }

          return ListView.builder(
            itemBuilder: (context, index) {
              return ExpansionTile(
                title: Text(movieNames[index]),
                children: subtitles[index][movieNames[index]]!
                    .map<Widget>((e) =>
                        BlocListener<SubtitleBloc, SubtitleState>(
                          bloc: subtitleBloc,
                          listenWhen: (previous, current) =>
                              current is SubtitleActionState,
                          listener: (context, state) {
                            switch (state.runtimeType) {
                              case const (SubtitleDownloadPermissionNotGrantedState):
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Write Permissions Were Not Granted'),
                                  ),
                                );
                                break;
                              case const (SubtitleDownloadStartedState):
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Downloading Subtitle...'),
                                  ),
                                );
                                break;
                              case const (SubtitleDownloadSuccessState):
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Subtitle Downloaded'),
                                  ),
                                );
                                break;
                              case const (SubtitleDownloadErrorState):
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Subtitle Download Failed'),
                                  ),
                                );
                                break;
                            }
                          },
                          child: ListTile(
                            title: Text(e['releaseName']),
                            subtitle: Text('Uploader: ${e['author']}'),
                            onTap: () {
                              // download subtitle
                              subtitleBloc.add(SubtitleDownloadEvent(
                                e['url'],
                                e['releaseName'],
                                e['author'],
                                movieNames[index],
                                movieNames[index],
                                'movie',
                              ));
                            },
                          ),
                        ))
                    .toList(),
              );
            },
            itemCount: subtitles.length,
          );
        },
      ),
    );
  }
}
