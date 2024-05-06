import 'package:hive/hive.dart';

class DownloadSubtitlesBox {
  static Box downloadedSubtitlesBox = Hive.box('downloadedSubtitlesBox');

  static void addDownloadedSubtitle(String url) {
    downloadedSubtitlesBox.put(url, true);
  }

  static bool isSubtitleDownloaded(String url) {
    return downloadedSubtitlesBox.get(url, defaultValue: false);
  }
}
