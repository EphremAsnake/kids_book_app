import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:resize/resize.dart';
import 'package:wakelock/wakelock.dart';
import 'controller/backgroundMusicAudioController.dart';
import 'pages/SplashScreen/splashScreen.dart';
import 'utils/Constants/AllStrings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    restorepurchase();
  }

  Future<void> restorepurchase() async {
    await InAppPurchase.instance.restorePurchases();
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
