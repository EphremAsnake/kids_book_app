import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:storyapp/utils/Constants/AllStrings.dart';
import 'dart:io' show Platform;
import '../../controller/subscriptionController.dart';
import 'status/subscriptionstatus.dart';

class IAPService {
  final String monthlyProductId;
  final String yearlyProductId;

  IAPService({required this.monthlyProductId, required this.yearlyProductId});

  SubscriptionController subscriptionController =
      Get.put(SubscriptionController());
  final SubscriptionStatus subscriptionStatus = Get.put(SubscriptionStatus());

  void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailList) {
    // ignore: avoid_function_literals_in_foreach_calls
    purchaseDetailList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        _handleSuccessfulPurchase(purchaseDetails);

        //!Handle Restore
      } else if (purchaseDetails.status == PurchaseStatus.restored) {
        _handleSuccessfulPurchase(purchaseDetails, isrestorepurchase: true);

        //!Handle Cancel
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        subscriptionController.hideProgress();

        //!Handle Error
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        Get.snackbar(
          '',
          '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          isDismissible: true,
          titleText: const Text(
            Strings.failure,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
          maxWidth: 400,
          messageText: const Text(
            Strings.unableToCompletePurchaseMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        );
        subscriptionController.hideProgress();
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    });
  }

  Future<void> updateSubscriptionStatus(bool isMonthly, bool isYearly) async {
    await subscriptionStatus.saveSubscriptionStatus(isMonthly, isYearly);
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails,
      {bool? isrestorepurchase}) async {
    if (purchaseDetails.productID == monthlyProductId) {
      if (Platform.isAndroid) {
        Map purchaseData =
            json.decode(purchaseDetails.verificationData.localVerificationData);

        if (!purchaseData["acknowledged"]) {
          //!Restoring Purchase
          final InAppPurchaseAndroidPlatformAddition androidPlatformAddition =
              InAppPurchase.instance
                  .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
          await androidPlatformAddition
              .consumePurchase(purchaseDetails)
              .then((value) {
            //!Rest
            int timestampMilliseconds = purchaseData["purchaseTime"] ?? 0;

            DateTime transactionDateTime =
                DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

            subscriptionStatus.storePurchaseDateAndroid(
                transactionDateTime, 'monthly');
            updateSubscriptionStatus(true, false);
            subscriptionController.hideProgress();
          });
        } else {
          //!First Time Purchase
          int timestampMilliseconds =
              int.tryParse(purchaseDetails.transactionDate!) ?? 0;

          DateTime transactionDateTime =
              DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);
          subscriptionStatus.storePurchaseDateAndroid(
              transactionDateTime, 'monthly');
          updateSubscriptionStatus(true, false);
          subscriptionController.hideProgress();
        }
      } else {
        //!Platform Is IOS

        int timestampMilliseconds =
            int.tryParse(purchaseDetails.transactionDate!) ?? 0;

        DateTime transactionDateTime =
            DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

        subscriptionStatus.storePurchaseDate(transactionDateTime, 'monthly');

        subscriptionController.hideProgress();
      }
    }
    if (purchaseDetails.productID == yearlyProductId) {
      if (Platform.isAndroid) {
        Map purchaseData =
            json.decode(purchaseDetails.verificationData.localVerificationData);
        if (!purchaseData["acknowledged"]) {
          //!Restoring Purchase
          final InAppPurchaseAndroidPlatformAddition androidPlatformAddition =
              InAppPurchase.instance
                  .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
          await androidPlatformAddition
              .consumePurchase(purchaseDetails)
              .then((value) {
            //!Rest
            int timestampMilliseconds = purchaseData["purchaseTime"] ?? 0;

            DateTime transactionDateTime =
                DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);
            subscriptionStatus.storePurchaseDateAndroid(
                transactionDateTime, 'yearly');
            updateSubscriptionStatus(false, true);
            subscriptionController.hideProgress();
          });
        } else {
          //!First Time Purchase
          int timestampMilliseconds =
              int.tryParse(purchaseDetails.transactionDate!) ?? 0;

          DateTime transactionDateTime =
              DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);
          subscriptionStatus.storePurchaseDateAndroid(
              transactionDateTime, 'yearly');
          updateSubscriptionStatus(false, true);
          subscriptionController.hideProgress();
        }
      } else {
        int timestampMilliseconds =
            int.tryParse(purchaseDetails.transactionDate!) ?? 0;

        DateTime transactionDateTime =
            DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

        subscriptionStatus.storePurchaseDate(transactionDateTime, 'yearly');

        subscriptionController.hideProgress();
      }
    }
  }

  // TODO: NEW WAY OF CHEKING SUBSCRIPTION STATUS

  Future<void> checkSubscriptionAvailabilty(
      [Duration monthduration = const Duration(days: 1),
      Duration yearduration = const Duration(days: 2),
      Duration grace = const Duration(days: 0)]) async {
    if (Platform.isIOS) {
      List<PurchaseDetails> allPurchases = [];

      InAppPurchase.instance.purchaseStream
          .listen((List<PurchaseDetails> historyPurchaseDetails) {
        if (historyPurchaseDetails.isNotEmpty) {
          allPurchases.clear();
          allPurchases.addAll(historyPurchaseDetails);
          allPurchases.sort((a, b) {
            int timestampA = int.tryParse(a.transactionDate!) ?? 0;
            int timestampB = int.tryParse(b.transactionDate!) ?? 0;

            DateTime dateTimeA =
                DateTime.fromMillisecondsSinceEpoch(timestampA);
            DateTime dateTimeB =
                DateTime.fromMillisecondsSinceEpoch(timestampB);

            return dateTimeA.compareTo(dateTimeB);
          });

          var lastPurchase = allPurchases.last;

          int timestampMilliseconds =
              int.tryParse(lastPurchase.transactionDate!) ?? 0;

          DateTime transactionDateTime =
              DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

          Duration difference = DateTime.now().difference(transactionDateTime);

          if (lastPurchase.productID == monthlyProductId) {
            if (difference.inMinutes <= monthduration.inMinutes) {
              updateSubscriptionStatus(true, false);
              subscriptionStatus.storePurchaseDate(
                  transactionDateTime, 'monthly');
              subscriptionController.hideProgress();
            } else {
              updateSubscriptionStatus(false, false);
              subscriptionController.hideProgress();
            }
          } else if (lastPurchase.productID == yearlyProductId) {
            if (difference <= yearduration) {
              updateSubscriptionStatus(false, true);
              subscriptionStatus.storePurchaseDate(
                  transactionDateTime, 'yearly');
              subscriptionController.hideProgress();
            } else {
              updateSubscriptionStatus(false, false);
              subscriptionController.hideProgress();
            }
          } else {
            updateSubscriptionStatus(false, false);
          }
        } else {
          updateSubscriptionStatus(false, false);
        }
      });
    } else {
      //!Platform is Android

      List<PurchaseDetails> allPurchases = [];

      InAppPurchase.instance.purchaseStream
          .listen((List<PurchaseDetails> historyPurchaseDetails) {
        if (historyPurchaseDetails.isNotEmpty) {
          allPurchases.clear();
          allPurchases.addAll(historyPurchaseDetails);

          PurchaseDetails? yearlyPurchase;

          for (var i = allPurchases.length - 1; i >= 0; i--) {
            if (allPurchases[i].productID == yearlyProductId) {
              yearlyPurchase = allPurchases[i];
              break; //! Found yearly purchase, exit loop
            }
          }

          var lastPurchase = yearlyPurchase ??
              (allPurchases.isNotEmpty
                  ? allPurchases[allPurchases.length - 1]
                  : allPurchases[allPurchases.length - 1]);

          if (lastPurchase.productID == monthlyProductId) {
            updateSubscriptionStatus(true, false);
          } else if (lastPurchase.productID == yearlyProductId) {
            updateSubscriptionStatus(false, true);
          } else {
            updateSubscriptionStatus(false, false);
          }
        } else {
          updateSubscriptionStatus(false, false);
        }
      });
    }
  }
}
