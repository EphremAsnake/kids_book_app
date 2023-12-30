import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  RxBool isSubscribedMonthly = false.obs;
  RxBool isSubscribedYearly = false.obs;

  void setUserSubscription(bool isMonthly, bool isYearly) {
    isSubscribedMonthly.value = isMonthly;
    isSubscribedYearly.value = isYearly;
  }

  bool get isUserSubscribedMonthly => isSubscribedMonthly.value;
  bool get isUserSubscribedYearly => isSubscribedYearly.value;

  var isLoading = false.obs;

  void showProgress() {
    isLoading.value = true;
  }

  void hideProgress() {
    isLoading.value = false;
  }
}
