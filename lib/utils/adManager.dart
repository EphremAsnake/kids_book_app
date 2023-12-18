import 'package:shared_preferences/shared_preferences.dart';

class BookPreferences {
  static const String watchedKey = 'watched_';
  static const String openedKey = 'opened_';

  static Future<void> setBookWatched(String bookTitle, bool watched) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(watchedKey + bookTitle, watched);
  }

  static Future<bool> getBookWatched(String bookTitle) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(watchedKey + bookTitle) ?? false;
  }

  static Future<void> incrementBookOpened(String bookTitle) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentOpened = prefs.getInt(openedKey + bookTitle) ?? 0;
    await prefs.setInt(openedKey + bookTitle, currentOpened + 1);
  }

  static Future<int> getBookOpenedCount(String bookTitle) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(openedKey + bookTitle) ?? 0;
  }

  static Future<void> resetBookData(String bookTitle) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(watchedKey + bookTitle);
    await prefs.remove(openedKey + bookTitle);
  }
}