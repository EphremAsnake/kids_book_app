class ConfigApiResponseModel {
  AdmobRewardedAd? admobRewardedAd;
  AdmobInterstitialAd? admobInterstitialAd;
  HouseAd? houseAd;
  String aboutApp;

  ConfigApiResponseModel({
    this.admobRewardedAd,
    this.admobInterstitialAd,
    this.houseAd,
    required this.aboutApp,
  });

  factory ConfigApiResponseModel.fromJson(Map<String, dynamic> json) {
    return ConfigApiResponseModel(
      admobRewardedAd: json.containsKey('admob_rewarded_ad')
          ? AdmobRewardedAd.fromJson(json['admob_rewarded_ad'])
          : null,
      admobInterstitialAd: json.containsKey('admob_interstitial_ad')
          ? AdmobInterstitialAd.fromJson(json['admob_interstitial_ad'])
          : null,
      houseAd: json.containsKey('house_ad')
          ? HouseAd.fromJson(json['house_ad'])
          : null,
      aboutApp: json['about_app'] ?? '',
    );
  }
}

class AdmobRewardedAd {
  String? ios;
  String? android;
  int? rewardedCount;

  AdmobRewardedAd({this.ios, this.android, this.rewardedCount});

  factory AdmobRewardedAd.fromJson(Map<String, dynamic> json) {
    return AdmobRewardedAd(
      ios: json['ios'],
      android: json['android'],
      rewardedCount: json['rewarded_count'] ?? 0,
    );
  }
}

class AdmobInterstitialAd {
  String? ios;
  String? android;

  AdmobInterstitialAd({this.ios, this.android});

  factory AdmobInterstitialAd.fromJson(Map<String, dynamic> json) {
    return AdmobInterstitialAd(
      ios: json['ios'],
      android: json['android'],
    );
  }
}

class HouseAd {
  String? buttonText;
  bool? show;
  bool? typeApp;
  String? iosUrl;
  String? androidUrl;

  HouseAd({
    this.buttonText,
    this.show,
    this.typeApp,
    this.iosUrl,
    this.androidUrl,
  });

  factory HouseAd.fromJson(Map<String, dynamic> json) {
    return HouseAd(
      buttonText: json['button_text'],
      show: json['show'] ?? false,
      typeApp: json['type_app'] ?? false,
      iosUrl: json['ios_url'],
      androidUrl: json['android_url'],
    );
  }
}
