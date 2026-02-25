import 'package:hive/hive.dart';

class RecentSearchesBox {
  static Box settingsBox = Hive.box('recentSearchesBox');

  static void addSearch(String search) {
    if (search == '') return;

    final searches = settingsBox.get('searches', defaultValue: <String>[]);

    // if search already exists, put it at the top
    if (searches.contains(search)) {
      searches.remove(search);
    }

    searches.add(search);
    settingsBox.put('searches', searches);
  }

  static List<String> getSearches() {
    final searches = settingsBox.get('searches', defaultValue: <String>[]);

    return searches.reversed.toList();
  }

  static void removeSearch(String search) {
    final searches = settingsBox.get('searches', defaultValue: <String>[]);
    searches.remove(search);
    settingsBox.put('searches', searches);
  }
}
