// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class AdController extends GetxController {
//   RewardedAd? rewardedAd;
//   bool isRewardedAdLoaded = false;
//   //!final AdController adController = Get.put(AdController());
//   void loadRewardedAd() {
//     if (rewardedAd != null) {
//       // Ad already loaded, do nothing
//       return;
//     } else {
//       RewardedAd.load(
//         adUnitId: 'your_rewarded_ad_unit_id',
//         request: AdRequest(),
//         rewardedAdLoadCallback: RewardedAdLoadCallback(
//           onAdLoaded: (ad) {
//             debugPrint("Ad Loaded");
//             rewardedAd = ad;
//             isRewardedAdLoaded = true;
//             update(); // Notify listeners about the ad loading
//           },
//           onAdFailedToLoad: (error) {
//             // Handle ad loading failure
//           },
//         ),
//       );
//     }
//   }

//   void showRewardedAd() {
//     if (isRewardedAdLoaded && rewardedAd != null) {
//       rewardedAd?.show(onUserEarnedReward: (ad, reward) {
//         // Handle user earning reward from the ad
//       });
//     } else {
//       // Ad not loaded or failed to load
//     }
//   }

//   @override
//   void onClose() {
//     rewardedAd?.dispose(); // Dispose the ad when the controller is closed
//     super.onClose();
//   }
// }
