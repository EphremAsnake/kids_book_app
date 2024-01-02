import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'dart:io' show Platform;
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import '../../controller/subscriptionController.dart';
import 'status/subscriptionstatus.dart';

class IAPService {
  final String monthlyProductId;
  final String yearlyProductId;

  IAPService({required this.monthlyProductId, required this.yearlyProductId});

  SubscriptionController subscriptionController =
      Get.put(SubscriptionController());
  final SubscriptionStatus subscriptionStatus = Get.put(SubscriptionStatus());
  Logger logger = Logger();

  void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailList) {
    // ignore: avoid_function_literals_in_foreach_calls
    purchaseDetailList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        // String transactionReceipt = purchaseDetails.verificationData
        _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.restored) {
        _handleSuccessfulPurchase(purchaseDetails, isrestorepurchase: true);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        //updateSubscriptionStatus(false, false);
        subscriptionController.hideProgress();
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        Get.snackbar(
          '',
          '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.yellow,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          isDismissible: true,
          titleText: const Text(
            'Failure',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
          maxWidth: 400,
          messageText: const Text(
            'Something Went Wrong',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        );
        subscriptionController.hideProgress();
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }

      //InAppPurchase.instance.purchaseStream.listen((event) { })
    });
  }

  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails,
      {bool? isrestorepurchase}) {
    //DateTime purchaseDate = DateTime.now();
    if (purchaseDetails.productID == monthlyProductId) {
      //DateTime expiryDate = purchaseDate.add(Duration(days: 30));
      logger.e('Monthly Subsccccc');
      int timestampMilliseconds =
          int.tryParse(purchaseDetails.transactionDate!) ?? 0;

      DateTime transactionDateTime =
          DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);
      subscriptionStatus.storePurchaseDate(transactionDateTime, 'monthly');
      subscriptionController.setUserSubscription(true, false);
      updateSubscriptionStatus(true, false);
      if (isrestorepurchase == null) {
        Get.snackbar(
          '',
          '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          isDismissible: true,
          titleText: const Text(
            'Success',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
          maxWidth: 400,
          messageText: const Text(
            'You have Successfully Subscribed to Monthly Package  Thank You!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        );
      }
      subscriptionController.hideProgress();
    }
    if (purchaseDetails.productID == yearlyProductId) {
      logger.e('Yearly Subsccccc');

      int timestampMilliseconds =
          int.tryParse(purchaseDetails.transactionDate!) ?? 0;

      DateTime transactionDateTime =
          DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

      subscriptionController.setUserSubscription(false, true);
      subscriptionStatus.storePurchaseDate(transactionDateTime, 'yearly');
      updateSubscriptionStatus(false, true);
      if (isrestorepurchase == null) {
        Get.snackbar(
          '',
          '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          isDismissible: true,
          titleText: const Text(
            'Success',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
          maxWidth: 400,
          messageText: const Text(
            'You have Successfully Subscribed to Yearly Package Thank You!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        );
      }
      subscriptionController.hideProgress();
    }
  }

  Future<void> updateSubscriptionStatus(bool isMonthly, bool isYearly) async {
    await subscriptionStatus.saveSubscriptionStatus(isMonthly, isYearly);
  }

  //!old checker
  // Future<void> checkSubscriptionAvailabilty() async {
  //   //await InAppPurchase.instance.restorePurchases();

  //   InAppPurchase.instance.purchaseStream.listen((List<PurchaseDetails> list) {
  //     if (list.isNotEmpty) {
  //       int i = 0;
  //       for (var purchase in list) {
  //         String productId = purchase.productID;
  //         _handleSuccessfulPurchase(list[i]);
  //         i++;
  //         print('Product ID: $productId');
  //       }
  //     } else {
  //       updateSubscriptionStatus(false, false);
  //     }
  //   });

  //   InAppPurchase.instance.purchaseStream.listen((list) {
  //     if (list.isNotEmpty) {
  //       int i = 0;
  //       for (var element in list) {
  //         list[i].verificationData.localVerificationData
  //       }
  //     } else {

  //     }
  //   });
  // }
  //}

  // TODO: NEW WAY OF CHEKING SUBSCRIPTION STATUS

  Future<void> checkSubscriptionAvailabilty(
      [Duration monthduration = const Duration(minutes: 4),
      Duration yearduration = const Duration(minutes: 10),
      Duration grace = const Duration(days: 0)]) async {
    logger.e('Test Test');
    //await InAppPurchase.instance.restorePurchases();

    if (Platform.isIOS) {
      // List<PurchaseDetails> historyPurchaseDetails = [];
      // InAppPurchase.instance.purchaseStream
      //     .listen((List<PurchaseDetails> list) {
      //   historyPurchaseDetails.addAll(list);
      // });
      InAppPurchase.instance.purchaseStream
          .listen((List<PurchaseDetails> historyPurchaseDetails) {
        if (historyPurchaseDetails.isNotEmpty) {
          for (var purchase in historyPurchaseDetails) {
            logger.e('status: ${purchase.status}');
            logger.e('transaction date: ${purchase.transactionDate}');

            int timestampMilliseconds =
                int.tryParse(purchase.transactionDate!) ?? 0;

            logger.e('timestampMilliseconds: $timestampMilliseconds');

            DateTime transactionDateTime =
                DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

            logger.e('transactionDateTime: $transactionDateTime');

            Duration difference =
                DateTime.now().difference(transactionDateTime);

            logger.e('difference: $difference');

            if (purchase.productID == monthlyProductId) {
              updateSubscriptionStatus(true, false);
              subscriptionStatus.storePurchaseDate(
                  transactionDateTime, 'monthly');
              subscriptionController.setUserSubscription(true, false);
              subscriptionController.hideProgress();
            } else if (purchase.productID == yearlyProductId) {
              updateSubscriptionStatus(false, true);
              subscriptionStatus.storePurchaseDate(
                  transactionDateTime, 'yearly');
              subscriptionController.setUserSubscription(false, true);
              subscriptionController.hideProgress();
            } else {
              updateSubscriptionStatus(false, false);
              subscriptionController.setUserSubscription(false, false);
            }
          }
        } else {
          logger.e(' List is empty');
          updateSubscriptionStatus(false, false);
          subscriptionController.setUserSubscription(false, false);
        }
      });
    } else if (Platform.isAndroid) {
      InAppPurchase.instance.purchaseStream
          .listen((List<PurchaseDetails> list) {
        if (list.isNotEmpty) {
          // int i = 0;
          for (var purchase in list) {
            logger.e('status: ${purchase.status}');
            logger.e('transaction date: ${purchase.transactionDate}');

            int timestampMilliseconds =
                int.tryParse(purchase.transactionDate!) ?? 0;

            logger.e('timestampMilliseconds: $timestampMilliseconds');

            DateTime transactionDateTime =
                DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

            logger.e('transactionDateTime: $transactionDateTime');

            Duration difference =
                DateTime.now().difference(transactionDateTime);

            logger.e('difference: $difference');
            //! String productId = purchase.productID;
            if (purchase.productID == monthlyProductId) {
              updateSubscriptionStatus(true, false);
              subscriptionStatus.storePurchaseDate(
                  transactionDateTime, 'monthly');
              subscriptionController.setUserSubscription(true, false);
              subscriptionController.hideProgress();
            } else if (purchase.productID == yearlyProductId) {
              updateSubscriptionStatus(false, true);
              subscriptionStatus.storePurchaseDate(
                  transactionDateTime, 'yearly');
              subscriptionController.setUserSubscription(false, true);
              subscriptionController.hideProgress();
            } else {
              updateSubscriptionStatus(false, false);
              subscriptionController.setUserSubscription(false, false);
            }

            // i++;
          }
        } else {
          updateSubscriptionStatus(false, false);
        }
      });
    }
    throw PlatformException(
        code: Platform.operatingSystem, message: "platform not supported");
  }
}



// Future<bool> verifyPurchase(PurchaseDetails purchaseDetails) async {

//     if (Platform.isAndroid) {
//       final localDataVerification = json.decode(purchaseDetails.verificationData.localVerificationData) as Map<String, dynamic>;
//       final orderId = localDataVerification['orderId'] as String;
//       final productId = localDataVerification['productId'] as String;
//       final packageName = localDataVerification['packageName'] as String;
//       final token = localDataVerification['purchaseToken'] as String;
//     } else if (Platform.isIOS) {
//       final appStorePurchaseDetails = purchaseDetails as AppStorePurchaseDetails;
//       final paymentToken = appStorePurchaseDetails.verificationData.localVerificationData;
//       final transitionId = appStorePurchaseDetails.skPaymentTransaction.originalTransaction?.transactionIdentifier;
//       final storeId = purchaseDetails.productID;
//     }

//     return Future<bool>.value(true);
//   }
// Future<void> handleExpiredPurchases() async {
//   final prefs = await SharedPreferences.getInstance();

//   final platform = defaultTargetPlatform;

//   if (platform == TargetPlatform.android) {
//     final QueryPurchaseDetailsResponse response =
//         await InAppPurchase.instance.queryPastPurchases();
//     final bool isSubscriptionActive = response.pastPurchases
//         .any((purchase) => purchase.productID == 'your_subscription_id');
//     prefs.setBool('isSubscribed', isSubscriptionActive);
//   } else if (platform == TargetPlatform.iOS) {
//     final QueryPurchaseDetailsResponse response =
//         await InAppPurchase.instance.restorePurchases();
//     final bool isSubscriptionActive = response.pastPurchases
//         .any((purchase) =>
//             purchase.productID == 'your_subscription_id' &&
//             DateTime.now().isBefore(purchase.expirationDate));
//     prefs.setBool('isSubscribed', isSubscriptionActive);
//   }
//  }
