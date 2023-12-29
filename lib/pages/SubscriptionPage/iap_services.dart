import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../controller/subscriptionController.dart';

class IAPService {
  final String monthlyProductId;
  final String yearlyProductId;

  IAPService({required this.monthlyProductId, required this.yearlyProductId});

  SubscriptionController subscriptionController =
      Get.put(SubscriptionController());

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
      subscriptionController.setUserSubscription(true, false);
    }
    if (purchaseDetails.productID == yearlyProductId) {
      subscriptionController.setUserSubscription(false, true);
    }
  }
}
