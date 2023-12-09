import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdController extends GetxController {
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  RxBool rewardedAdLoaded = false.obs;
  RxBool interstitialAdLoaded = false.obs;

  late String? rewardedAdUnitId;
  late String? interstitialAdUnitId;

  AdController({
    this.rewardedAdUnitId,
    this.interstitialAdUnitId,
  });

  @override
  void onInit() {
    super.onInit();
    _loadAds();
  }

  Future<void> _loadAds() async {
    _loadRewardedAd();
    _loadInterstitialAd();
  }

  Future<void> _loadRewardedAd() async {
    if (_rewardedAd == null) {
      RewardedAd.load(
        adUnitId: rewardedAdUnitId!,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            rewardedAdLoaded.value = true;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose;
                _loadRewardedAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose;
                _loadRewardedAd();
              },
            );
            update();
          },
          onAdFailedToLoad: (error) {
            _loadRewardedAd();
            debugPrint('Rewarded Ad failed to load: $error');
          },
        ),
      );
    }
  }

  Future<void> _loadInterstitialAd() async {
    if (_interstitialAd == null) {
      InterstitialAd.load(
        adUnitId: interstitialAdUnitId!,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            interstitialAdLoaded.value = true;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
              },
              onAdImpression: (ad) {
                _interstitialAd = ad;
              },
            );

            //_interstitialAd = ad;
            update();
          },
          onAdFailedToLoad: (error) {
            _loadInterstitialAd();
            debugPrint('Interstitial Ad failed to load: $error');
          },
        ),
      );
    }
  }

  void showRewardedAd(
      Function()? onUserEarnedReward, Function()? onContentClosed) {
    if (rewardedAdLoaded.value) {
      _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
        // onAdFailedToShowFullScreenContent: (ad, error) {
        //   _loadRewardedAd();
        //   //onRewardadFailedtoLoad?.call();
        //   //! Handle failed ad (Try to Load Again)
        // },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd();
          onContentClosed?.call();

          //! Callback after content is closed
        },
      );

      _rewardedAd?.show(
        onUserEarnedReward: (ad, reward) async {
          onUserEarnedReward?.call();

          //! Callback after earning reward
          _loadRewardedAd();
        },
      );
    } else {
      debugPrint('Rewarded Ad is not ready yet');
    }
  }

  Future<void> showInterstitialAd(Function()? onContentClosed) async {
    if (_interstitialAd == null) {
      _loadInterstitialAd();
    }
    if (interstitialAdLoaded.value) {
      //_interstitialAd?.setImmersiveMode(true);
      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdFailedToShowFullScreenContent: (ad, error) {
          _loadInterstitialAd();
        },
        onAdDismissedFullScreenContent: (ad) {
          _loadInterstitialAd();
          onContentClosed?.call();
        },
      );
      _interstitialAd?.show();
    }
  }

  Future<void> loadRewardedAdAfterError() async {
    if (!rewardedAdLoaded.value) {
      //!Ad still failed to load so try to load again

      _loadRewardedAd();

      //! Load rewarded ad

      //!Get.snackbar('Ad Loading Failed', 'Unable to load rewarded ad');
    }
  }

  Future<void> loadInterstitialAdAfterError() async {
    //! Load rewarded ad
    if (_interstitialAd == null) {
      //!Ad still null
      _loadInterstitialAd();

      //!Get.snackbar('Ad Loading Failed', 'Unable to load rewarded ad');
    }
  }

  @override
  void onClose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}
