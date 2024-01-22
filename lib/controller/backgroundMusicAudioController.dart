import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../services/apiEndpoints.dart';
import 'package:just_audio_cache/just_audio_cache.dart';

class AudioController extends GetxController with WidgetsBindingObserver {
  final AudioPlayer _backgrounMusicPlayer = AudioPlayer();
  bool isPlaying = false;
  bool wasPlayingBeforeInterruption = false;

  @override
  void onInit() {
    super.onInit();
    _backgrounMusicPlayer.setLoopMode(LoopMode.one);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgrounMusicPlayer.dispose();
    super.onClose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (wasPlayingBeforeInterruption) {
        _backgrounMusicPlayer.play();
        wasPlayingBeforeInterruption = false;
        isPlaying = true;
        update();
      }
    } else if (state == AppLifecycleState.paused) {
      wasPlayingBeforeInterruption = _backgrounMusicPlayer.playing;
      if (_backgrounMusicPlayer.playing) {
        isPlaying = false;

        _backgrounMusicPlayer.pause();
        update();
      }
    }
  }

  void toggleAudio() async {
    if (isPlaying) {
      _backgrounMusicPlayer.pause();
    } else {
      _backgrounMusicPlayer.play();
    }
    isPlaying = !isPlaying;
    update();
  }

  void startAudio(String audioUrl, {bool? backgroundMusicPause}) async {
    try {
      await _backgrounMusicPlayer.dynamicSet(
          url: '${APIEndpoints.menuUrl}$audioUrl');
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
    if (backgroundMusicPause != null && backgroundMusicPause) {
      isPlaying = false;
    } else {
      _backgrounMusicPlayer.play();
      isPlaying = true;
    }

    update();
  }

  void audioVolumeUp() {
    _backgrounMusicPlayer.setVolume(1);
  }

  void audioVolumeDown() {
    _backgrounMusicPlayer.setVolume(0.2);
  }
}
