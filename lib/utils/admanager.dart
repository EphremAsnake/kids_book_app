import 'package:shared_preferences/shared_preferences.dart';

class AdManagesr {
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

// class NewAdManager {
//   static Future<int> getBookWatchedCount(String bookTitle) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getInt(bookTitle) ?? 0;
//   }

//   static Future<void> incrementBookWatchedCount(String bookTitle) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int currentCount = prefs.getInt(bookTitle) ?? 0;
//     await prefs.setInt(bookTitle, currentCount + 1);
//   }

//   // static Future<void> adWatchedForBook(String bookTitle) async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   await prefs.setBool(bookTitle, true);
//   // }

//   // static Future<bool> getAdWatchedStatusForBook(String bookTitle) async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   return prefs.getBool(bookTitle) ?? false;
//   // }

//   // static Future<void> resetadWatchedForBook(String bookTitle) async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   await prefs.setBool(bookTitle, false);
//   // }

//   static Future<void> resetBookWatchedCount(String bookTitle) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove(bookTitle);
//   }
// }

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
