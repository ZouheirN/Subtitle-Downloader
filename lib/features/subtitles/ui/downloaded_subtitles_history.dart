import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:subtitle_downloader/hive/downloaded_subtitles_box.dart';
import 'package:subtitle_downloader/main.dart';

class DownloadedSubtitlesHistory extends StatelessWidget {
  const DownloadedSubtitlesHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Subtitles History'),
      ),
      body: ValueListenableBuilder(
        valueListenable:
            DownloadedSubtitlesBox.downloadedSubtitlesBox.listenable(),
        builder: (context, value, child) {
          final subtitles = DownloadedSubtitlesBox.getAllDownloadedSubtitles();

          final movieNames = subtitles.map((e) => e.keys.first).toList();

          logger.i(subtitles);
          return ListView.builder(
            itemBuilder: (context, index) {
              return ExpansionTile(
                title: Text(movieNames[index]),
                children: subtitles[index][movieNames[index]]!
                    .map<Widget>((e) => ListTile(
                          title: Text(e['releaseName']),
                          subtitle: Text('Uploader: ${e['author']}'),
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
