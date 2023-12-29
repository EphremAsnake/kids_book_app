import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';

import '../../controller/subscriptionController.dart';
import 'status/subscriptionstatus.dart';

class IAPService {
  final String monthlyProductId;
  final String yearlyProductId;

  IAPService({required this.monthlyProductId, required this.yearlyProductId});

  SubscriptionController subscriptionController =
      Get.put(SubscriptionController());

  Logger logger = Logger();

  void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailList) {
    purchaseDetailList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _handleSuccessfulPurchase(purchaseDetails);
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    });
  }

  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    //DateTime purchaseDate = DateTime.now();
    if (purchaseDetails.productID == monthlyProductId) {
      //DateTime expiryDate = purchaseDate.add(Duration(days: 30));
      logger.e('Monthly Subsccccc');
      subscriptionController.setUserSubscription(true, false);
      updateSubscriptionStatus(true, false);
    }
    if (purchaseDetails.productID == yearlyProductId) {
      logger.e('Yearly Subsccccc');
      subscriptionController.setUserSubscription(false, true);
      updateSubscriptionStatus(false, true);
    }
  }

  Future<void> updateSubscriptionStatus(bool isMonthly, bool isYearly) async {
    await SubscriptionStatus.saveSubscriptionStatus(isMonthly, isYearly);
  }
}
