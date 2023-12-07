class AdHelper {
  static String? interstitialAdUnitId;
  static String? rewardedAdUnitId;

  static void setAdUnits({
    required String? interstitialId,
    required String? rewardedId,
  }) {
    interstitialAdUnitId = interstitialId;
    rewardedAdUnitId = rewardedId;
  }

  static String getInterstitalAdUnitId() {
    if (interstitialAdUnitId != null) {
      return interstitialAdUnitId!;
    } else {
      throw Exception("Interstitial ad unit ID not available");
    }
  }

  static String getRewardedAdUnitId() {
    if (rewardedAdUnitId != null) {
      return rewardedAdUnitId!;
    } else {
      throw Exception("Rewarded ad unit ID not available");
    }
  }
}
