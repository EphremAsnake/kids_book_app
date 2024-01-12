import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

//! Constants for keys used in SharedPreferences
const String monthlySubscriptionKey = 'isSubscribedMonthly';
const String yearlySubscriptionKey = 'isSubscribedYearly';

class SubscriptionStatus extends GetxController {
  @override
  void onInit() {
    getSubscriptionStatus();
    super.onInit();
  }

  RxBool isMonthly = false.obs;
  RxBool isYearly = false.obs;

  //! Function to save subscription status locally
  Future<void> saveSubscriptionStatus(bool monthly, bool yearly) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(monthlySubscriptionKey, monthly);
    await prefs.setBool(yearlySubscriptionKey, yearly);
    // Update reactive variables
    isMonthly.value = monthly;
    isYearly.value = yearly;
  }

  Future<void> storePurchaseDate(
      DateTime purchaseDate, String purchasetype) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('purchase_date', purchaseDate.toIso8601String());
    //prefs.setString('purchase_type', purchasetype);
  }

  Future<void> storePurchaseDateAndroid(
      DateTime purchaseDate, String purchasetype) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('purchase_date_android', purchaseDate.toIso8601String());
    prefs.setString('purchase_type_Android', purchasetype);
  }

  Future<DateTime?> getStoredPurchaseDateAndroid() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedPurchaseDate = prefs.getString('purchase_date_android');
    if (storedPurchaseDate != null) {
      return DateTime.parse(storedPurchaseDate);
    }
    return null;
  }

  Future<String?> getStoredPurchaseTypeAndroid() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedPurchaseType = prefs.getString('purchase_type_Android');
    if (storedPurchaseType != null) {
      return storedPurchaseType;
    }
    return null;
  }

  Future<DateTime?> getStoredPurchaseDate() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedPurchaseDate = prefs.getString('purchase_date');
    if (storedPurchaseDate != null) {
      return DateTime.parse(storedPurchaseDate);
    }
    return null;
  }

  //! Function to retrieve subscription status from local storage
  Future<void> getSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isMonthly.value = prefs.getBool(monthlySubscriptionKey) ?? false;
    isYearly.value = prefs.getBool(yearlySubscriptionKey) ?? false;
  }

  //!
  DateTime getExpirationDate(DateTime purchaseDate) {
    int subscriptionDurationInDays = isMonthly.value ? 4 : 10;
    return purchaseDate.add(Duration(minutes: subscriptionDurationInDays));
  }

  bool isSubscriptionActive(DateTime purchaseDate) {
    DateTime expirationDate = getExpirationDate(purchaseDate);
    DateTime currentDate = DateTime.now();

    return currentDate.isBefore(expirationDate);
  }
}
