// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:audioplayers/audioplayers.dart';

// import '../services/apiEndpoints.dart';

// class BookAudioController extends GetxController with WidgetsBindingObserver {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool isPlaying = false;
//   bool wasPlayingBeforeInterruption = false; // New flag to track previous state
//   List<String> audioUrls = [];
//   int _counter = 0;

//   int get counter => _counter;

//   void incrementCounter() {
//     _counter++;
//     update();
//   }

//   bool _listen = false;

//   bool get listen => _listen;

//   void setListenMode(bool value) {
//     _listen = value;
//     update();
//     updateAudioPlayback();
//   }

//   void resetAudioController() {
//     // Reset all variables and flags to their initial state
//     _counter = 0;
//     isPlaying = false;
//     wasPlayingBeforeInterruption = false;
//     audioUrls.clear(); // Clear the list of audio URLs
//     _audioPlayer.stop(); // Stop audio playback
//     _audioPlayer.dispose;

//     // Notify listeners of state changes
//     update();
//   }

//   void updateAudioPlayback() {
//     if (_listen) {
//       _audioPlayer.onPlayerStateChanged.listen(
//         (it) {
//           switch (it) {
//             case PlayerState.stopped:
//               print(
//                 'Player stopped!'
//                 'toast-player-stopped-index',
//               );
//               break;
//             case PlayerState.completed:
//               if (_counter < audioUrls.length - 1) {
//                 incrementCounter();
//                 _playAudioAtIndex(_counter);
//               } else {
//                 isPlaying = false;
//                 update();
//               }

//               print(
//                 'Player complete!'
//                 'toast-player-complete-index',
//               );
//               break;
//             default:
//               break;
//           }
//         },
//       );
//     } else {
//       _audioPlayer.stop(); // Stop audio if not in listen mode
//     }
//   }

//   void decrementCounter() {
//     _counter--;
//     update();
//   }

//   void clearplayer() {
//     _counter = 0;
//     _audioPlayer.stop();
//     isPlaying = false;
//     update();
//     _audioPlayer.dispose;
//   }

//   // void clearcounter() {
//   //   _counter = 0;

//   //   update();
//   // }

//   @override
//   void onInit() {
//     super.onInit();
//     //_audioPlayer.setReleaseMode(ReleaseMode.loop);

//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void onClose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _audioPlayer.dispose();
//     _counter = 0;
//     _audioPlayer.stop();
//     isPlaying = false;
//     update();

//     super.onClose();
//   }

//   @override
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

//   void toggleAudio() async {
//     if (isPlaying) {
//       await _audioPlayer.pause();
//     } else {
//       await _audioPlayer.resume();
//     }
//     isPlaying = !isPlaying;
//     update(); // Notify listeners of state change
//   }

//   // void startAudio(String audioUrl) async {
//   //   await _audioPlayer.play(UrlSource(audioUrl));

//   //   isPlaying = true;
//   //   update();
//   // }
//   // Function to start playing audio at a given index
//   void _playAudioAtIndex(int index) async {
//     if (index < audioUrls.length) {
//       await _audioPlayer.play(UrlSource(audioUrls[index]));
//       isPlaying = true;
//       update();
//     }
//   }

//   // Function to start playing the list of audio URLs
//   void startAudio(List<String> urls) {
//     audioUrls = List<String>.from(urls);

//     // if (start != null) {
//     //   _counter = 0;
//     // }
//     _playAudioAtIndex(_counter);
//     setListenMode(true);
//   }

//   void audioVolumeUp() {
//     _audioPlayer.setVolume(1);
//   }

//   void audioVolumeDown() {
//     _audioPlayer.setVolume(0.3);
//   }
// }



// //!backup working with single audio
// /* 
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:audioplayers/audioplayers.dart';

// import '../services/apiEndpoints.dart';

// class BookAudioController extends GetxController with WidgetsBindingObserver {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool isPlaying = false;
//   bool wasPlayingBeforeInterruption = false; // New flag to track previous state

//   int _counter = 0;

//   int get counter => _counter;

//   void incrementCounter() {
//     _counter++;
//     update();
//   }
//   void decrementCounter() {
//     _counter--;
//     update();
//   }


//   @override
//   void onInit() {
//     super.onInit();
//     //_audioPlayer.setReleaseMode(ReleaseMode.loop);
    
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void onClose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _audioPlayer.dispose();
//     super.onClose();
//   }

//   @override
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

//   void toggleAudio() async {
//     if (isPlaying) {
//       await _audioPlayer.pause();
//     } else {
//       await _audioPlayer.resume();
//     }
//     isPlaying = !isPlaying;
//     update(); // Notify listeners of state change
//   }

//   void startAudio(String audioUrl) async {
//     await _audioPlayer.play(UrlSource(audioUrl));

//     isPlaying = true;
//     update();
//   }

//   void audioVolumeUp() {
//     _audioPlayer.setVolume(1);
//   }

//   void audioVolumeDown() {
//     _audioPlayer.setVolume(0.3);
//   }
// }

// */
