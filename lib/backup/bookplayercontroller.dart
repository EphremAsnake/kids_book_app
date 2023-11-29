// import 'dart:async';

// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:audioplayers/audioplayers.dart';

// import '../services/apiEndpoints.dart';

// int defaultPlayerCount = 4;

// class BookAudioController extends GetxController with WidgetsBindingObserver {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool isPlaying = false;
//   bool wasPlayingBeforeInterruption = false;

//   List<AudioPlayer> audioPlayers = List.generate(
//     defaultPlayerCount,
//     (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop),
//   );

//   int selectedPlayerIdx = 0;

//   AudioPlayer get selectedAudioPlayer => audioPlayers[selectedPlayerIdx];
//   List<StreamSubscription> streams = [];

//   @override
//   void onInit() {
//     super.onInit();
//     //_audioPlayer.setReleaseMode(ReleaseMode.loop);
//     // _audioPlayer.onPlayerStateChanged.listen(
//     //   (it) {
//     //     switch (it) {
//     //       case PlayerState.stopped:
//     //         toast(
//     //           'Player stopped!',
//     //           textKey: Key('toast-player-stopped-$index'),
//     //         );
//     //         break;
//     //       case PlayerState.completed:
//     //         toast(
//     //           'Player complete!',
//     //           textKey: Key('toast-player-complete-$index'),
//     //         );
//     //         break;
//     //       default:
//     //         break;
//     //     }
//     //   },
//     // );

//     audioPlayers.asMap().forEach((index, player) {
//       streams.add(
//         player.onPlayerStateChanged.listen(
//           (it) {
//             switch (it) {
//               case PlayerState.stopped:
//                 print(
//                   'Player stopped!'
//                   'toast-player-stopped-$index',
//                 );
//                 break;
//               case PlayerState.completed:
//                 print(
//                   'Player complete!'
//                   'toast-player-complete-$index',
//                 );
//                 break;
//               default:
//                 break;
//             }
//           },
//         ),
//       );
//       streams.add(
//         player.onSeekComplete.listen(
//           (it) => print('Seek complete!'
//               'toast-seek-complete-$index'),
//         ),
//       );
//     });

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
//     await _audioPlayer.play(UrlSource('${APIEndpoints.booksUrl}$audioUrl'));

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
