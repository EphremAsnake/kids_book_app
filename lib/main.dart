import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:resize/resize.dart';
import 'package:wakelock/wakelock.dart';

import 'controller/backgroundMusicAudioController.dart';
import 'backup/listenBookAudioController.dart';
import 'pages/splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await _initGoogleMobileAds();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  Wakelock.enable();
  Get.put(AudioController());
  //Get.put(BookAudioController());
  runApp(const MyApp());
}

Future<void> _initGoogleMobileAds() async {
  await MobileAds.instance.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return Resize(builder: () {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Story Book',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      );
    });
  }
}
