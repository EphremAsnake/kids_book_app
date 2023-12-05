// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class AdController extends GetxController {
//   late RewardedAd _rewardedAd;
//   late InterstitialAd _interstitialAd;

//   bool rewardedAdLoaded = false;
//   bool interstitialAdLoaded = false;

//   late String? rewardedAdUnitId;
//   late String? interstitialAdUnitId;

//   AdController({
//     this.rewardedAdUnitId,
//     this.interstitialAdUnitId,
//   });

//   @override
//   void onInit() {
//     super.onInit();
//     _loadRewardedAd();
//     _loadInterstitialAd();
//   }

//   void _loadRewardedAd() {
//     RewardedAd.load(
//       adUnitId: rewardedAdUnitId!,
//       request: const AdRequest(),
//       rewardedAdLoadCallback: RewardedAdLoadCallback(
//         onAdLoaded: (ad) {
//           _rewardedAd = ad;
//           rewardedAdLoaded = true;
//           ad.fullScreenContentCallback = FullScreenContentCallback(
//             onAdDismissedFullScreenContent: (ad) => _loadRewardedAd(),
//           );
//           update();
//         },
//         onAdFailedToLoad: (error) {
//           debugPrint('Rewarded Ad failed to load: $error');
//         },
//       ),
//     );
//   }

//   void _loadInterstitialAd() {
//     InterstitialAd.load(
//       adUnitId: interstitialAdUnitId!,
//       request: const AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (ad) {
//           _interstitialAd = ad;
//           interstitialAdLoaded = true;
//           ad.fullScreenContentCallback = FullScreenContentCallback(
//             onAdDismissedFullScreenContent: (ad) => _loadInterstitialAd(),
//           );
//           update();
//         },
//         onAdFailedToLoad: (error) {
//           debugPrint('Interstitial Ad failed to load: $error');
//         },
//       ),
//     );
//   }

//   void showRewardedAd() {
//     if (rewardedAdLoaded) {
//       _rewardedAd.show(onUserEarnedReward: (ad, reward) {
//         // Handle reward logic here
//       });
//     } else {
//       debugPrint('Rewarded Ad is not ready yet');
//     }
//   }

//   void showInterstitialAd() {
//     if (interstitialAdLoaded) {
//       _interstitialAd.show();
//     } else {
//       debugPrint('Interstitial Ad is not ready yet');
//     }
//   }
// }



// //!usage
// // Future<void> fetchAdIds() async {
// //     //! Simulating async fetching of ad IDs
// //     await Future.delayed(const Duration(seconds: 1));

// //     String? rewardedAdId = AdHelper.getRewardedAdUnitId();
// //     String? interstitialAdId = AdHelper.getInterstitalAdUnitId();

// //     //! Initialize AdController with fetched ad IDs
// //     adController = Get.put(AdController(
// //       rewardedAdUnitId: rewardedAdId,
// //       interstitialAdUnitId: interstitialAdId,
// //     ));
// //   }