import 'package:flutter/material.dart';
import 'package:subtitle_downloader/hive/downloaded_subtitles_box.dart';

class DownloadedSubtitlesHistory extends StatelessWidget {
  const DownloadedSubtitlesHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final subtitles = DownloadedSubtitlesBox.getAllDownloadedSubtitles();
    final movieNames = subtitles.map((e) => e.keys.first).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Subtitles History'),
      ),
      body: ListView.builder(
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
      ),
    );
  }
}
