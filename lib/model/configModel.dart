class ConfigApiResponseModel {
  AppRateAndShare? appRateAndShare;
  HouseAd? houseAd;
  String aboutApp;

  ConfigApiResponseModel({
    this.appRateAndShare,
    this.houseAd,
    required this.aboutApp,
  });

  factory ConfigApiResponseModel.fromJson(Map<String, dynamic> json) {
    return ConfigApiResponseModel(
      appRateAndShare: json.containsKey('app_rate_share')
          ? AppRateAndShare.fromJson(json['app_rate_share'])
          : null,
      houseAd: json.containsKey('house_ad')
          ? HouseAd.fromJson(json['house_ad'])
          : null,
      aboutApp: json['about_app'] ?? '',
    );
  }
}


class AppRateAndShare {
  String? iosID;
  String? androidID;
  String? iosShare;
  String? androidShare;

  AppRateAndShare(
      {this.iosID, this.androidID, this.iosShare, this.androidShare});

  factory AppRateAndShare.fromJson(Map<String, dynamic> json) {
    return AppRateAndShare(
      iosID: json['ios_id'] ?? '',
      androidID: json['android_id'] ?? '',
      iosShare: json['ios_share'] ?? '',
      androidShare: json['android_share'] ?? '',
    );
  }
}

class HouseAd {
  String? buttonText;
  bool? show;
  // bool? typeApp;
  String? iosUrl;
  String? androidUrl;
  String? buttonColor;
  String? buttonTextColor;

  HouseAd({
    this.buttonText,
    this.show,
    // this.typeApp,
    this.iosUrl,
    this.androidUrl,
    this.buttonColor,
    this.buttonTextColor,
  });

  factory HouseAd.fromJson(Map<String, dynamic> json) {
    return HouseAd(
        buttonText: json['button_text'] ?? '',
        show: json['show'] ?? false,
        //  typeApp: json['type_app'] ?? false,
        iosUrl: json['ios_url'] ?? '',
        androidUrl: json['android_url'] ?? '',
        buttonColor: json['button_bacground_color'] ?? '#ffe600',
        buttonTextColor: json['button_text_color'] ?? '#2b2b2b');
  }
}
