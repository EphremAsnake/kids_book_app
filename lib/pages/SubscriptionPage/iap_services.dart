import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailList) {
    purchaseDetailList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    });
  }
}
