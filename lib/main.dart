import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:resize/resize.dart';
import 'package:wakelock/wakelock.dart';

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
  runApp(const MyApp());
}

Future<void> _initGoogleMobileAds() async {
  await MobileAds.instance.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


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
