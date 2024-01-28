import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../services/apiEndpoints.dart';
import 'package:just_audio_cache/just_audio_cache.dart';

class AudioController extends GetxController with WidgetsBindingObserver {
  final AudioPlayer _backgrounMusicPlayer = AudioPlayer();
  final DefaultCacheManager _cacheManager = DefaultCacheManager();
  bool isPlaying = false;
  bool wasPlayingBeforeInterruption = false;
  String backgroundAudioUrl = '';
  late final Directory appDocumentsDir;

  //final AudioPlayer _audioPlayer = AudioPlayer();
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
      String fullAudioUrl = '${APIEndpoints.menuUrl}$audioUrl';
      // await _backgrounMusicPlayer.dynamicSet(
      //     url: '${APIEndpoints.menuUrl}$audioUrl');
      final cachedFile = await _cacheManager.getSingleFile(fullAudioUrl);
      if (cachedFile != null) {
        debugPrint('Playing from cache: $fullAudioUrl');
        await _backgrounMusicPlayer.setFilePath(cachedFile.path);
      } else {
        debugPrint('Downloading and caching audio: $fullAudioUrl');
        await _cacheManager.downloadFile(fullAudioUrl);
        await _backgrounMusicPlayer.setUrl('${APIEndpoints.menuUrl}$fullAudioUrl');
      }
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

  void deleteDirectory(Directory directory) {
    if (directory.existsSync()) {
      directory.listSync().forEach((entity) {
        if (entity is File) {
          entity.deleteSync();
        } else if (entity is Directory) {
          deleteDirectory(entity);
        }
      });
      directory.deleteSync();
    }
  }
}
