import 'package:shared_preferences/shared_preferences.dart';

class AdManager {
  static Future<int> getAdShownCount(String bookTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(bookTitle) ?? 0;
  }

  static Future<void> incrementAdShownCount(String bookTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt(bookTitle) ?? 0;
    await prefs.setInt(bookTitle, currentCount + 1);
  }

  static Future<void> resetAdShownCount(String bookTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(bookTitle);
  }
}
