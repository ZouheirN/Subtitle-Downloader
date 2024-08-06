import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:subtitle_downloader/features/subtitles/bloc/subtitle_bloc.dart';
import 'package:subtitle_downloader/hive/downloaded_subtitles_box.dart';

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

  @override
  Widget build(BuildContext context) {
    var subtitles = DownloadedSubtitlesBox.getAllDownloadedSubtitles();
    var movieNames = subtitles.map((e) => e.keys.first).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Subtitles History'),
      ),
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(movieNames[index]),
                onDismissed: (direction) async {
                  await DownloadedSubtitlesBox.deleteDownloadedSubtitle(
                      subtitles[index].values.first.first['url']);

                  final removedMovieName = movieNames[index];

                  setState(() {
                    subtitles =
                        DownloadedSubtitlesBox.getAllDownloadedSubtitles();
                    movieNames = subtitles.map((e) => e.keys.first).toList();
                  });

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$removedMovieName Deleted'),
                    ),
                  );
                },
                background: Container(color: Colors.red),
                child: ExpansionTile(
                  title: Text(movieNames[index]),
                  subtitle: Text(
                      'Total Subtitles: ${subtitles[index][movieNames[index]]!.length}'),
                  children: subtitles[index][movieNames[index]]!
                      .map<Widget>((e) =>
                          BlocListener<SubtitleBloc, SubtitleState>(
                            bloc: subtitleBloc,
                            listenWhen: (previous, current) =>
                                current is SubtitleActionState,
                            listener: (context, state) {
                              switch (state.runtimeType) {
                                case const (SubtitleDownloadPermissionNotGrantedState):
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Write Permissions Were Not Granted'),
                                    ),
                                  );
                                  break;
                                case const (SubtitleDownloadStartedState):
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Downloading Subtitle...'),
                                    ),
                                  );
                                  break;
                                case const (SubtitleDownloadSuccessState):
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Subtitle Downloaded'),
                                    ),
                                  );
                                  break;
                                case const (SubtitleDownloadErrorState):
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
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
                ),
              );
            },
            itemCount: subtitles.length,
          ),
        ],
      ),
    );
  }
}
