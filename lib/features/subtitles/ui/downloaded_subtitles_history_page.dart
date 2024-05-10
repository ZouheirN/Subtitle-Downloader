import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:subtitle_downloader/features/subtitles/bloc/subtitle_bloc.dart';
import 'package:subtitle_downloader/hive/downloaded_subtitles_box.dart';
import 'package:subtitle_downloader/main.dart';

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
    final subtitles = DownloadedSubtitlesBox.getAllDownloadedSubtitles();
    final movieNames = subtitles.map((e) => e.keys.first).toList();

    logger.d(subtitles);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Subtitles History'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(movieNames[index]),
            children: subtitles[index][movieNames[index]]!
                .map<Widget>((e) => BlocListener<SubtitleBloc, SubtitleState>(
                      bloc: subtitleBloc,
                      listenWhen: (previous, current) =>
                          current is SubtitleActionState,
                      listener: (context, state) {
                        switch (state.runtimeType) {
                          case const (SubtitleDownloadPermissionNotGrantedState):
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Write Permissions Were Not Granted'),
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
      ),
    );
  }
}
