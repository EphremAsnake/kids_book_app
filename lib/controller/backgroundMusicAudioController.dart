import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../services/apiEndpoints.dart';
import 'package:just_audio_cache/just_audio_cache.dart';

class AudioController extends GetxController with WidgetsBindingObserver {
  final AudioPlayer _backgrounMusicPlayer = AudioPlayer();
  bool isPlaying = false;
  bool wasPlayingBeforeInterruption = false;
  String backgroundAudioUrl = '';
  late final Directory appDocumentsDir;

  //final AudioPlayer _audioPlayer = AudioPlayer();
  @override
  void onInit() {
    super.onInit();
    _backgrounMusicPlayer.setLoopMode(LoopMode.one);
    initMethod();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> initMethod() async {
    appDocumentsDir = await getApplicationDocumentsDirectory();
  }

  Future<Directory> _openDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final Directory targetDir = Directory(dir.path + '/background_audio_cache');
    if (!targetDir.existsSync()) {
      targetDir.createSync();
    }
    return targetDir;
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
    final cacheManager = DefaultCacheManager();

    try {
      //backgroundAudioUrl = '${APIEndpoints.menuUrl}$audioUrl';
      await cacheManager.downloadFile('${APIEndpoints.menuUrl}$audioUrl');
      File file =
          await cacheManager.getSingleFile('${APIEndpoints.menuUrl}$audioUrl');
      
      await _backgrounMusicPlayer.setFilePath(file.path);

      // await _backgrounMusicPlayer.dynamicSet(
      //     url: '${APIEndpoints.menuUrl}$audioUrl');
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

  Future<void> clearCache() async {
    //_backgrounMusicPlayer.getCachedPath();
    _backgrounMusicPlayer.clearCache();
    //deleteDirectory(Directory('/data/user/0/com.itdc.story/app_flutter/background_audio_cache'));
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
