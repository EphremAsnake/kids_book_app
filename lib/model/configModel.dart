class ConfigApiResponseModel {
  AppRateAndShare? appRateAndShare;
  HouseAd? houseAd;
  String aboutApp;
  AndroidSettings androidSettings;
  IOSSettings iosSettings;

  ConfigApiResponseModel({
    this.appRateAndShare,
    this.houseAd,
    required this.aboutApp,
    required this.androidSettings,
    required this.iosSettings,
  });

  factory ConfigApiResponseModel.fromJson(Map<String, dynamic> json) {
    return ConfigApiResponseModel(
      appRateAndShare: json.containsKey('android_settings') &&
              json['android_settings'].containsKey('app_rate_share')
          ? AppRateAndShare.fromJson(json['android_settings']['app_rate_share'])
          : null,
      houseAd: json.containsKey('android_settings') &&
              json['android_settings'].containsKey('house_ad')
          ? HouseAd.fromJson(json['android_settings']['house_ad'])
          : null,
      aboutApp: json['android_settings']['about_app'] ?? '',
      androidSettings: AndroidSettings.fromJson(json['android_settings']),
      iosSettings: IOSSettings.fromJson(json['ios_settings']),
    );
  }
}

class AppRateAndShare {
  String? urlId;
  String? share;

  AppRateAndShare({
    this.urlId,
    this.share,
  });

  factory AppRateAndShare.fromJson(Map<String, dynamic> json) {
    return AppRateAndShare(
      urlId: json['url_id'] ?? '',
      share: json['share'] ?? '',
    );
  }
}

class HouseAd {
  String? buttonText;
  bool? show;
  String? urlId;
  String? buttonColor;
  String? buttonTextColor;

  HouseAd({
    this.buttonText,
    this.show,
    this.urlId,
    this.buttonColor,
    this.buttonTextColor,
  });

  factory HouseAd.fromJson(Map<String, dynamic> json) {
    return HouseAd(
      buttonText: json['button_text'] ?? '',
      show: json['show'] ?? false,
      urlId: json['url_id'] ?? '',
      buttonColor: json['button_bacground_color'] ?? '#ffe600',
      buttonTextColor: json['button_text_color'] ?? '#2b2b2b',
    );
  }
}

class AndroidSettings {
  SubscriptionSettings subscriptionSettings;
  String? unlockDialogText;
  AdmobSettings admobSettings;
  AppRateAndShare? appRateAndShare;
  HouseAd? houseAd;
  bool? parentalGate;
  String aboutApp;
  String? fallbackServerUrl;

  AndroidSettings({
    required this.subscriptionSettings,
    this.unlockDialogText,
    required this.admobSettings,
    this.appRateAndShare,
    this.houseAd,
    this.parentalGate,
    required this.aboutApp,
    this.fallbackServerUrl,
  });

  factory AndroidSettings.fromJson(Map<String, dynamic> json) {
    return AndroidSettings(
      subscriptionSettings:
          SubscriptionSettings.fromJson(json['subscription_settings']),
      unlockDialogText: json['unlock_dialog_text'],
      admobSettings: AdmobSettings.fromJson(json['admob_settings']),
      appRateAndShare: json.containsKey('app_rate_share')
          ? AppRateAndShare.fromJson(json['app_rate_share'])
          : null,
      houseAd: json.containsKey('house_ad')
          ? HouseAd.fromJson(json['house_ad'])
          : null,
      parentalGate:  true,
      aboutApp: json['about_app'] ?? '',
      fallbackServerUrl: json['fallback_server_url']??'',
    );
  }
}

class IOSSettings {
  SubscriptionSettings subscriptionSettings;
  String? unlockDialogText;
  AdmobSettings admobSettings;
  AppRateAndShare? appRateAndShare;
  HouseAd? houseAd;
  bool? parentalGate;
  String aboutApp;
  String? fallbackServerUrl;

  IOSSettings({
    required this.subscriptionSettings,
    this.unlockDialogText,
    required this.admobSettings,
    this.appRateAndShare,
    this.houseAd,
    this.parentalGate,
    required this.aboutApp,
    this.fallbackServerUrl,
  });

  factory IOSSettings.fromJson(Map<String, dynamic> json) {
    return IOSSettings(
      subscriptionSettings:
          SubscriptionSettings.fromJson(json['subscription_settings']),
      unlockDialogText: json['unlock_dialog_text'],
      admobSettings: AdmobSettings.fromJson(json['admob_settings']),
      appRateAndShare: json.containsKey('app_rate_share')
          ? AppRateAndShare.fromJson(json['app_rate_share'])
          : null,
      houseAd: json.containsKey('house_ad')
          ? HouseAd.fromJson(json['house_ad'])
          : null,
      parentalGate: json['parental_gate'] ?? true,
      aboutApp: json['about_app'] ?? '',
      fallbackServerUrl: json['fallback_server_url']??'',
    );
  }
}

class SubscriptionSettings {
  String? generalSubscriptionText;
  String? monthSubscriptionText;
  String? yearSubscriptionText;
  String? termOfUseUrl;
  String? privacyPolicyUrl;

  SubscriptionSettings({
    this.generalSubscriptionText,
    this.monthSubscriptionText,
    this.yearSubscriptionText,
    this.termOfUseUrl,
    this.privacyPolicyUrl,
  });

  factory SubscriptionSettings.fromJson(Map<String, dynamic> json) {
    return SubscriptionSettings(
      generalSubscriptionText: json['general_subscription_text'],
      monthSubscriptionText: json['month_subscription_text'],
      yearSubscriptionText: json['year_subscription_text'],
      termOfUseUrl: json['term_of_use_url'],
      privacyPolicyUrl: json['privacy_policy_url'],
    );
  }
}

class AdmobSettings {
  bool? adsEnabled;
  AdmobRewardedAd? admobRewardedAd;
  AdmobInterstitialAd? admobInterstitialAd;

  AdmobSettings({
    this.adsEnabled,
    this.admobRewardedAd,
    this.admobInterstitialAd,
  });

  factory AdmobSettings.fromJson(Map<String, dynamic> json) {
    return AdmobSettings(
      adsEnabled: json['ads_enabled'],
      admobRewardedAd: json.containsKey('admob_rewarded_ad')
          ? AdmobRewardedAd.fromJson(json['admob_rewarded_ad'])
          : null,
      admobInterstitialAd: json.containsKey('admob_interstitial_ad')
          ? AdmobInterstitialAd.fromJson(json['admob_interstitial_ad'])
          : null,
    );
  }
}

class AdmobRewardedAd {
  String? adUnitId;
  int? rewardedCount;

  AdmobRewardedAd({
    this.adUnitId,
    this.rewardedCount,
  });

  factory AdmobRewardedAd.fromJson(Map<String, dynamic> json) {
    return AdmobRewardedAd(
      adUnitId: json['ad_unit_id'],
      rewardedCount: json['rewarded_count'],
    );
  }
}

class AdmobInterstitialAd {
  String? adUnitId;
  bool? showInterstitial;

  AdmobInterstitialAd({
    this.adUnitId,
    this.showInterstitial,
  });

  factory AdmobInterstitialAd.fromJson(Map<String, dynamic> json) {
    return AdmobInterstitialAd(
      adUnitId: json['ad_unit_id'],
      showInterstitial: json['show_interstitial'],
    );
  }
}
