import 'package:shared_preferences/shared_preferences.dart';

//! Constants for keys used in SharedPreferences
const String monthlySubscriptionKey = 'isSubscribedMonthly';
const String yearlySubscriptionKey = 'isSubscribedYearly';

class SubscriptionStatus {
  //! Function to save subscription status locally
  static Future<void> saveSubscriptionStatus(
      bool isMonthly, bool isYearly) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(monthlySubscriptionKey, isMonthly);
    await prefs.setBool(yearlySubscriptionKey, isYearly);
  }

  //! Function to retrieve subscription status from local storage
  static Future<Map<String, bool>> getSubscriptionStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isMonthly = prefs.getBool(monthlySubscriptionKey) ?? false;
    final bool isYearly = prefs.getBool(yearlySubscriptionKey) ?? false;

    return {
      monthlySubscriptionKey: isMonthly,
      yearlySubscriptionKey: isYearly,
    };
  }
}
