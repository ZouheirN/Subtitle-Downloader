import 'package:hive/hive.dart';
import 'package:subtitle_downloader/features/firestore/repos/firestore_service.dart';

class DownloadedSubtitlesBox {
  static Box downloadedSubtitlesBox = Hive.box('downloadedSubtitlesBox');

  static void addDownloadedSubtitle(
    String url,
    String releaseName,
    String author,
    String movieName, {
    required bool localOnly,
  }) {
    // do not add if already exists
    if (downloadedSubtitlesBox.containsKey(url)) return;

    downloadedSubtitlesBox.put(url, {
      'releaseName': releaseName,
      'author': author,
      'movieName': movieName,
      'downloaded_on': DateTime.now().toIso8601String(),
    });

    if (localOnly) return;
    // sync to firestore
    FirestoreService().addSubtitleToFirestore(
      url,
      releaseName,
      author,
      movieName,
    );
  }

  static bool isSubtitleDownloaded(String url) {
    return downloadedSubtitlesBox.containsKey(url);
  }

  static List<Map<String, List>> getAllDownloadedSubtitles() {
    List<Map<String, List>> downloadedSubtitles = [];
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var url in downloadedSubtitlesBox.keys) {
      final subtitle = downloadedSubtitlesBox.get(url);
      if (subtitle == null || subtitle is! Map) continue;
      subtitle['url'] = url;
      final movieName = subtitle['movieName'] ?? 'Unknown';
      grouped
          .putIfAbsent(movieName, () => [])
          .add(Map<String, dynamic>.from(subtitle));
    }

    // sort each movie's list by downloaded_on descending (newest first)
    for (var entry in grouped.entries) {
      entry.value.sort((a, b) {
        final aStr = a['downloaded_on'] ?? '';
        final bStr = b['downloaded_on'] ?? '';
        DateTime aDt;
        DateTime bDt;
        try {
          aDt = DateTime.parse(aStr);
        } catch (_) {
          aDt = DateTime.fromMillisecondsSinceEpoch(0);
        }
        try {
          bDt = DateTime.parse(bStr);
        } catch (_) {
          bDt = DateTime.fromMillisecondsSinceEpoch(0);
        }
        return bDt.compareTo(aDt);
      });
      downloadedSubtitles.add({entry.key: entry.value});
    }

    return downloadedSubtitles;
  }

  static void clearAllDownloadedSubtitles({required bool localOnly}) {
    downloadedSubtitlesBox.clear();

    if (localOnly) return;

    // clear firestore
    FirestoreService().clearAllSubtitlesFromFirestore();
  }

  static Future<void> deleteDownloadedSubtitle(
    String url,
    bool localOnly,
  ) async {
    downloadedSubtitlesBox.delete(url);

    if (localOnly) return;

    await FirestoreService().deleteSubtitleFromFirestore(url);
  }
}
