import 'package:hive/hive.dart';
import 'package:subtitle_downloader/features/firestore/repos/firestore_service.dart';

class DownloadedSubtitlesBox {
  static Box downloadedSubtitlesBox = Hive.box('downloadedSubtitlesBox');

  static void addDownloadedSubtitle(
      String url, String releaseName, String author, String movieName,
      {required bool localOnly}) {
    // do not add if already exists
    if (downloadedSubtitlesBox.containsKey(url)) return;

    downloadedSubtitlesBox.put(url, {
      'releaseName': releaseName,
      'author': author,
      'movieName': movieName,
    });

    if (localOnly) return;
    // sync to firestore
    FirestoreService()
        .addSubtitleToFirestore(url, releaseName, author, movieName);
  }

  static bool isSubtitleDownloaded(String url) {
    return downloadedSubtitlesBox.containsKey(url);
  }

  static List<Map<String, List>> getAllDownloadedSubtitles() {
    // group by movie name: [{"movieName": [{}, {}]}, {"movieName2": [{}, {}]}]
    List<Map<String, List>> downloadedSubtitles = [];

    for (var url in downloadedSubtitlesBox.keys) {
      final subtitle = downloadedSubtitlesBox.get(url);
      // add url
      subtitle['url'] = url;
      final movieName = subtitle['movieName'];

      final movieIndex = downloadedSubtitles
          .indexWhere((element) => element.keys.first == movieName);

      if (movieIndex == -1) {
        downloadedSubtitles.add({
          movieName: [subtitle]
        });
      } else {
        downloadedSubtitles[movieIndex][movieName]?.add(subtitle);
      }
    }

    return downloadedSubtitles;
  }

  static void clearAllDownloadedSubtitles() {
    downloadedSubtitlesBox.clear();

    // clear firestore
    FirestoreService().clearAllSubtitlesFromFirestore();
  }

  static Future<void> deleteDownloadedSubtitle(String url) async {
    downloadedSubtitlesBox.delete(url);
    await FirestoreService().deleteSubtitleFromFirestore(url);
  }
}
