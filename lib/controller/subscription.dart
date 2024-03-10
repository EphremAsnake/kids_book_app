import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionPriceController extends GetxController {
  static const String monthlyPriceKey = 'monthly_price';
  static const String yearlyPriceKey = 'yearly_price';
  late SharedPreferences _prefs;
  final RxString monthlyPrice = ''.obs;
  final RxString yearlyPrice = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    monthlyPrice.value = _prefs.getString(monthlyPriceKey) ?? '';
    yearlyPrice.value = _prefs.getString(yearlyPriceKey) ?? '';
  }

  void saveMonthlyPrice(String price) {
    monthlyPrice.value = price;
    _prefs.setString(monthlyPriceKey, price);
    update();
  }

  void saveYearlyPrice(String price) {
    yearlyPrice.value = price;
    _prefs.setString(yearlyPriceKey, price);
    update();
  }
}
