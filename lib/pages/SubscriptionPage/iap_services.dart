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

        //!Handle Restore
      } else if (purchaseDetails.status == PurchaseStatus.restored) {
        logger.e(
            'Restore Called ${purchaseDetails.verificationData.localVerificationData}');
        _handleSuccessfulPurchase(purchaseDetails, isrestorepurchase: true);

        //!Handle Cancel
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        //updateSubscriptionStatus(false, false);
        subscriptionController.hideProgress();

        //!Handle Error
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

  // void checkSubscriptionValidity() async {
  //   DateTime? storedPurchaseDate =
  //       await subscriptionStatus.getStoredPurchaseDate();

  //   if (storedPurchaseDate != null) {
  //     logger.e('Stored Purchase Date: $storedPurchaseDate');

  //     bool isActive =
  //         subscriptionStatus.isSubscriptionActive(storedPurchaseDate);
  //     logger.e('Is Subscription Active: $isActive');
  //     if (isActive) {
  //       if (subscriptionStatus.isMonthly.value) {
  //         subscriptionStatus.saveSubscriptionStatus(true, false);
  //       } else if (subscriptionStatus.isYearly.value) {
  //         subscriptionStatus.saveSubscriptionStatus(false, true);
  //       }
  //     } else {
  //       logger.e('Subscription Expired or other issue found.');
  //       subscriptionStatus.saveSubscriptionStatus(false, false);
  //     }
  //   } else {
  //     logger.e('No stored purchase date found.');
  //   }
  // }
  Future<void> updateSubscriptionStatus(bool isMonthly, bool isYearly) async {
    await subscriptionStatus.saveSubscriptionStatus(isMonthly, isYearly);
  }

  Future<void> _handleRestorePurchases(
    PurchaseDetails purchaseDetails,
  ) async {
    // TODO: Monthly Restore

    if (purchaseDetails.productID == monthlyProductId) {
      //!Get transaction time
      int timestampMilliseconds =
          int.tryParse(purchaseDetails.transactionDate!) ?? 0;

      DateTime transactionDateTime =
          DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

      subscriptionStatus.storePurchaseDate(transactionDateTime, 'monthly');

      //!get Stored Last Purchase Date
      DateTime? storedPurchaseDate =
          await subscriptionStatus.getStoredPurchaseDate();

      //!Check If Stored Last Purchase Date is not null
      if (storedPurchaseDate != null) {
        //!Check If the Subscription is Active
        bool isActive =
            subscriptionStatus.isSubscriptionActive(storedPurchaseDate);

        if (isActive) {
          subscriptionStatus.saveSubscriptionStatus(true, false);
        } else {
          subscriptionStatus.saveSubscriptionStatus(false, false);
        }
      }
    }

    // TODO: Yearly Restore

    else if (purchaseDetails.productID == yearlyProductId) {
      //!Get transaction time
      int timestampMilliseconds =
          int.tryParse(purchaseDetails.transactionDate!) ?? 0;

      DateTime transactionDateTime =
          DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

      //!Store the transaction date // purchased date
      subscriptionStatus.storePurchaseDate(transactionDateTime, 'yearly');

      //!get Stored Last Purchase Date
      DateTime? storedPurchaseDate =
          await subscriptionStatus.getStoredPurchaseDate();

      //!Check If Stored Last Purchase Date is not null
      if (storedPurchaseDate != null) {
        //!Check If the Subscription is Active
        bool isActive =
            subscriptionStatus.isSubscriptionActive(storedPurchaseDate);

        if (isActive) {
          subscriptionStatus.saveSubscriptionStatus(false, true);
        } else {
          subscriptionStatus.saveSubscriptionStatus(false, false);
        }
      }
    } else {
      subscriptionStatus.saveSubscriptionStatus(false, false);
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails,
      {bool? isrestorepurchase}) async {
    if (purchaseDetails.productID == monthlyProductId) {
      if (Platform.isAndroid) {
        Map purchaseData =
            json.decode(purchaseDetails.verificationData.localVerificationData);
        logger.e(purchaseData);
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
            logger.e('P Time: ${transactionDateTime}');
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
        logger.e('Monthly Subsccccc');
        int timestampMilliseconds =
            int.tryParse(purchaseDetails.transactionDate!) ?? 0;

        DateTime transactionDateTime =
            DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

        subscriptionStatus.storePurchaseDate(transactionDateTime, 'monthly');

        subscriptionController.hideProgress();
      }
    }
    if (purchaseDetails.productID == yearlyProductId) {
      logger.e('Yearly Sub...');
      if (Platform.isAndroid) {
        Map purchaseData =
            json.decode(purchaseDetails.verificationData.localVerificationData);
        logger.e(purchaseData);
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
      [Duration monthduration = const Duration(minutes: 4),
      Duration yearduration = const Duration(minutes: 10),
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

          logger.e('All Purchases List Length: ${allPurchases.length}');

          logger.e('last purchase status: ${lastPurchase.status}');
          logger.e(
              'last purchase transaction date: ${lastPurchase.transactionDate}');
          int timestampMilliseconds =
              int.tryParse(lastPurchase.transactionDate!) ?? 0;
          logger
              .e('last purchase timestampMilliseconds: $timestampMilliseconds');

          DateTime transactionDateTime =
              DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

          logger.e('last purchase transactionDateTime: $transactionDateTime');
          logger.e('Now time: ${DateTime.now()}');

          Duration difference = DateTime.now().difference(transactionDateTime);

          logger.e('last purchase difference: ${difference.inMinutes}');

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
          logger.e(' List is empty');
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
          // allPurchases.sort((a, b) {
          //   int timestampA = int.tryParse(a.transactionDate!) ?? 0;
          //   int timestampB = int.tryParse(b.transactionDate!) ?? 0;

          //   DateTime dateTimeA =
          //       DateTime.fromMillisecondsSinceEpoch(timestampA);
          //   DateTime dateTimeB =
          //       DateTime.fromMillisecondsSinceEpoch(timestampB);

          //   return dateTimeA.compareTo(dateTimeB);

          // });

          //var lastPurchase = allPurchases[allPurchases.length - 1];
          // var lastPurchase = allPurchases.lastWhere(
          //   (purchase) => purchase.productID == yearlyProductId,
          //   orElse: () => allPurchases[allPurchases.length - 1],
          // );

          PurchaseDetails? yearlyPurchase;

          for (var i = allPurchases.length - 1; i >= 0; i--) {
            if (allPurchases[i].productID == yearlyProductId) {
              yearlyPurchase = allPurchases[i];
              break; // Found yearly purchase, exit loop
            }
          }

          var lastPurchase = yearlyPurchase != null
              ? yearlyPurchase
              : allPurchases.isNotEmpty
                  ? allPurchases[allPurchases.length - 1]
                  : allPurchases[allPurchases.length - 1];

          int timestampMilliseconds =
              int.tryParse(lastPurchase.transactionDate!) ?? 0;
          DateTime transactionDateTime =
              DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

          logger.e('time: ${transactionDateTime}');

          if (lastPurchase.productID == monthlyProductId) {
            updateSubscriptionStatus(true, false);
          } else if (lastPurchase.productID == yearlyProductId) {
            updateSubscriptionStatus(false, true);
          } else {
            logger.e(' Product Id Don\'t Match');
            logger.e(lastPurchase);
            updateSubscriptionStatus(false, false);
          }
          // logger.e('list length: ${historyPurchaseDetails.length}');
          // logger.e('list : ${historyPurchaseDetails[0]}');
        } else {
          logger.e(' List is empty');
          updateSubscriptionStatus(false, false);
        }
      });

      // DateTime? storedPurchaseDateAndroid =
      //     await subscriptionStatus.getStoredPurchaseDateAndroid();

      // String? storedSubType =
      //     await subscriptionStatus.getStoredPurchaseTypeAndroid();
      // if (storedPurchaseDateAndroid != null) {
      //   // int timestampMilliseconds =
      //   //     int.tryParse(storedPurchaseDateAndroid) ?? 0;

      //   // DateTime transactionDateTime =
      //   //     DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);
      //   Duration differenceA =
      //       DateTime.now().difference(storedPurchaseDateAndroid);
      //   logger.e('differenceA: ${differenceA.inMinutes}');
      //   logger.e('storedPurchaseDateAndroid: ${storedPurchaseDateAndroid}');
      //   if (storedSubType != null && storedSubType == 'monthly') {
      //     if (differenceA.inMinutes <= monthduration.inMinutes) {
      //       updateSubscriptionStatus(true, false);
      //     } else {
      //       updateSubscriptionStatus(false, false);
      //     }
      //   } else if (storedSubType != null && storedSubType == 'yearly') {
      //     if (differenceA.inMinutes <= yearduration.inMinutes) {
      //       updateSubscriptionStatus(false, true);
      //     } else {
      //       updateSubscriptionStatus(false, false);
      //     }
      //   } else {
      //     updateSubscriptionStatus(false, false);
      //   }
      // }

      // // InAppPurchase.instance.purchaseStream
      // //     .listen((List<PurchaseDetails> list) {
      // //   if (list.isNotEmpty) {
      // //     logger.e('List Not Empty');
      // //     for (var purchase in list) {
      // //       logger.e('status: ${purchase.status}');
      // //       logger.e('transaction date: ${purchase.transactionDate}');

      // //       int timestampMilliseconds =
      // //           int.tryParse(purchase.transactionDate!) ?? 0;

      // //       logger.e('timestampMilliseconds: $timestampMilliseconds');

      // //       DateTime transactionDateTime =
      // //           DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

      // //       logger.e('transactionDateTime: $transactionDateTime');

      // //       Duration difference =
      // //           DateTime.now().difference(transactionDateTime);

      // //       logger.e('difference: $difference');
      // //       //! String productId = purchase.productID;
      // //       if (purchase.productID == monthlyProductId) {
      // //         updateSubscriptionStatus(true, false);
      // //         subscriptionStatus.storePurchaseDate(
      // //             transactionDateTime, 'monthly');
      // //         subscriptionController.setUserSubscription(true, false);
      // //         subscriptionController.hideProgress();
      // //       } else if (purchase.productID == yearlyProductId) {
      // //         updateSubscriptionStatus(false, true);
      // //         subscriptionStatus.storePurchaseDate(
      // //             transactionDateTime, 'yearly');
      // //         subscriptionController.setUserSubscription(false, true);
      // //         subscriptionController.hideProgress();
      // //       } else {
      // //         updateSubscriptionStatus(false, false);
      // //         subscriptionController.setUserSubscription(false, false);
      // //       }

      // //       // i++;
      // //     }
      // //   } else {
      // //     logger.e('List is Empty');
      // //     updateSubscriptionStatus(false, false);
      // //   }
      // // });
      // //updateSubscriptionStatus(false, false);
    }
    // throw PlatformException(
    //     code: Platform.operatingSystem, message: "platform not supported");
  }
}
