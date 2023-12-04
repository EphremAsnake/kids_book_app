import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../services/apiEndpoints.dart';

class AudioController extends GetxController with WidgetsBindingObserver {
  final AudioPlayer _backgrounMusicPlayer = AudioPlayer();
  bool isPlaying = false;
  bool wasPlayingBeforeInterruption = false; // New flag to track previous state

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

//  @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.inactive) {
//       if (isPlaying) {
//         wasPlayingBeforeInterruption = true; // Update flag
//         _audioPlayer.stop();
//       }
//     } else if (state == AppLifecycleState.resumed) {
//       if (wasPlayingBeforeInterruption) {
//         wasPlayingBeforeInterruption = false; // Reset flag
//         //_audioPlayer.resume();
//       }
//     }
//   }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App resumed from the background
      // Check if audio was playing before going to the background
      if (wasPlayingBeforeInterruption) {
        // _backgrounMusicPlayer.seek(Duration.zero);
        _backgrounMusicPlayer.play();
        wasPlayingBeforeInterruption = false;
        isPlaying = true;
        update();
        // setState(() {
        //   isPlaying = true;
        // });
      }
    } else if (state == AppLifecycleState.paused) {
      // App went to the background
      // Check if audio is playing and store its state
      wasPlayingBeforeInterruption = _backgrounMusicPlayer.playing;
      if (_backgrounMusicPlayer.playing) {
        isPlaying = false;

        _backgrounMusicPlayer.pause();
        update();
        // setState(() {
        //   isPlaying = false;
        // });
      }else{
        _backgrounMusicPlayer.stop();
      }

      // Pause or stop audio playback here if needed
      // Example: bookplayer.pause();
    }
  }

  void toggleAudio() async {
    if (isPlaying) {
      _backgrounMusicPlayer.pause();
    } else {
      _backgrounMusicPlayer.play();
    }
    isPlaying = !isPlaying;
    update(); // Notify listeners of state change
  }

  //  void togglePlayback() {
  //   if (bookplayer.playing) {
  //     bookplayer.pause();
  //     setState(() {
  //       isPlaying = false;
  //     });
  //   } else {
  //     bookplayer.seek(Duration.zero);
  //     bookplayer.play();
  //     setState(() {
  //       isPlaying = true;
  //     });
  //   }
  // }

  void startAudio(String audioUrl) async {
    await _backgrounMusicPlayer.setUrl('${APIEndpoints.menuUrl}$audioUrl');
    _backgrounMusicPlayer.play();
    isPlaying = true;
    update();
  }

  void audioVolumeUp() {
    _backgrounMusicPlayer.setVolume(1);
  }

  void audioVolumeDown() {
    _backgrounMusicPlayer.setVolume(0.3);
  }
}
