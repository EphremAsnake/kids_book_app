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

class NewAdManager {
  static Future<int> getBookWatchedCount(String bookTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(bookTitle) ?? 0;
  }

  static Future<void> incrementBookWatchedCount(String bookTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt(bookTitle) ?? 0;
    await prefs.setInt(bookTitle, currentCount + 1);
  }

  static Future<void> adWatchedForBook(String bookTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(bookTitle, true);
  }

  static Future<void> resetadWatchedForBook(String bookTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(bookTitle, false);
  }

  static Future<void> resetBookWatchedCount(String bookTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(bookTitle);
  }
}

// class BookManager {
//   static Future<int> getBookWatchedCount(String bookTitle) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('$bookTitle\_watchedCount') ?? 0;
//   }

//   static Future<bool> getAdWatchedStatus(String bookTitle) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('$bookTitle\_adWatched') ?? false;
//   }

//   static Future<void> onBookPressed(String bookTitle) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int watchedCount = await getBookWatchedCount(bookTitle);
//     bool adWatched = await getAdWatchedStatus(bookTitle);

//     watchedCount++;
//     await prefs.setInt('$bookTitle\_watchedCount', watchedCount);

//     if (!adWatched && watchedCount >= maxWatchLimit) {
//       await prefs.setBool('$bookTitle\_adWatched', true);
//     }
//   }

//   static Future<void> resetBookWatchedStatus(String bookTitle) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('$bookTitle\_watchedCount');
//     await prefs.setBool('$bookTitle\_adWatched', false);
//   }
// }
