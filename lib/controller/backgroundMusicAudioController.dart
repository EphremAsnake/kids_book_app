import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/apiEndpoints.dart';

class AudioController extends GetxController with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool wasPlayingBeforeInterruption = false; // New flag to track previous state

  @override
  void onInit() {
    super.onInit();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (isPlaying) {
        wasPlayingBeforeInterruption = true; // Update flag
        _audioPlayer.stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (wasPlayingBeforeInterruption) {
        wasPlayingBeforeInterruption = false; // Reset flag
        //_audioPlayer.resume();
      }
    }
  }

  void toggleAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    isPlaying = !isPlaying;
    update(); // Notify listeners of state change
  }

  void startAudio(String audioUrl) async {
    await _audioPlayer.play(UrlSource('${APIEndpoints.menuUrl}$audioUrl'));

    isPlaying = true;
    update();
  }

  void audioVolumeUp() {
    _audioPlayer.setVolume(1);
  }

  void audioVolumeDown() {
    _audioPlayer.setVolume(0.3);
  }
}
