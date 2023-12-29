import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:resize/resize.dart';
import 'package:storyapp/pages/SubscriptionPage/iap_services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'controller/backgroundMusicAudioController.dart';
import 'pages/SplashScreen/splashScreen.dart';
import 'utils/Constants/AllStrings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initGoogleMobileAds();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
      overlays: []);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  Wakelock.enable();
  Get.put(AudioController());
  runApp(MyApp());
}

Future<void> _initGoogleMobileAds() async {
  await MobileAds.instance.initialize();
  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: ['E8B8069F86DB9F7CFC536F078FB104C1']),
  );
}

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //late StreamSubscription<List<PurchaseDetails>> _iapSubscription;

  @override
  void initState() {
    super.initState();

    // final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;

    // _iapSubscription = purchaseUpdated.listen((purchaseDetailsList) {
    //   IAPService().listenToPurchaseUpdated(purchaseDetailsList);
    // }, onDone: () {
    //   _iapSubscription.cancel();
    // }, onError: (error) {
    //   _iapSubscription.cancel();
    // }) as StreamSubscription<List<PurchaseDetails>>;
  }

  @override
  Widget build(BuildContext context) {
    return Resize(builder: () {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: Strings.appTitle,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      );
    });
  }
}
