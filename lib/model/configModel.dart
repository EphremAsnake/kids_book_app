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

  AppRateAndShare? appRateAndShare;
  HouseAd? houseAd;
  String aboutApp;
  bool? parentalGate;
  String? fallbackServerUrl;

  AndroidSettings({
    required this.subscriptionSettings,
    this.appRateAndShare,
    this.houseAd,
    required this.aboutApp,
    required this.parentalGate,
    this.fallbackServerUrl,
  });

  factory AndroidSettings.fromJson(Map<String, dynamic> json) {
    return AndroidSettings(
      subscriptionSettings:
          SubscriptionSettings.fromJson(json['subscription_settings']),
      appRateAndShare: json.containsKey('app_rate_share')
          ? AppRateAndShare.fromJson(json['app_rate_share'])
          : null,
      houseAd: json.containsKey('house_ad')
          ? HouseAd.fromJson(json['house_ad'])
          : null,
      parentalGate: json['parental_gate'] ?? true,
      aboutApp: json['about_app'] ?? '',
      fallbackServerUrl: json['fallback_server_url'] ?? '',
    );
  }
}

class IOSSettings {
  SubscriptionSettings subscriptionSettings;
  AppRateAndShare? appRateAndShare;
  HouseAd? houseAd;
  String aboutApp;
  bool? parentalGate;
  String? fallbackServerUrl;

  IOSSettings({
    required this.subscriptionSettings,
    this.appRateAndShare,
    this.houseAd,
    required this.parentalGate,
    required this.aboutApp,
    this.fallbackServerUrl,
  });

  factory IOSSettings.fromJson(Map<String, dynamic> json) {
    return IOSSettings(
      subscriptionSettings:
          SubscriptionSettings.fromJson(json['subscription_settings']),
      appRateAndShare: json.containsKey('app_rate_share')
          ? AppRateAndShare.fromJson(json['app_rate_share'])
          : null,
      houseAd: json.containsKey('house_ad')
          ? HouseAd.fromJson(json['house_ad'])
          : null,
      aboutApp: json['about_app'] ?? '',
      parentalGate: json['parental_gate'] ?? true,
      fallbackServerUrl: json['fallback_server_url'] ?? '',
    );
  }
}

class SubscriptionSettings {
  String? generalSubscriptionText;
  String? monthSubscriptionText;
  String? yearSubscriptionText;
  String? monthSubscriptionProductID;
  String? yearSubscriptionProductID;
  String? termOfUseUrl;
  String? privacyPolicyUrl;

  SubscriptionSettings({
    this.generalSubscriptionText,
    this.monthSubscriptionText,
    this.yearSubscriptionText,
    this.monthSubscriptionProductID,
    this.yearSubscriptionProductID,
    this.termOfUseUrl,
    this.privacyPolicyUrl,
  });

  factory SubscriptionSettings.fromJson(Map<String, dynamic> json) {
    return SubscriptionSettings(
      generalSubscriptionText: json['general_subscription_text'],
      monthSubscriptionText: json['month_subscription_text'],
      yearSubscriptionText: json['year_subscription_text'],
      monthSubscriptionProductID: json['month_subscription_id'],
      yearSubscriptionProductID: json['year_subscription_id'],
      termOfUseUrl: json['term_of_use_url'],
      privacyPolicyUrl: json['privacy_policy_url'],
    );
  }
}
