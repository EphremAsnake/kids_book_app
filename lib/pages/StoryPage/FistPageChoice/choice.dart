import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:resize/resize.dart';
import 'package:storyapp/utils/Constants/AllStrings.dart';

import '../../../controller/backgroundMusicAudioController.dart';
import '../../../model/booklistModel.dart';
import '../../../model/configModel.dart';
import '../../../widget/animated_button_widget.dart';
import '../../BookListMenu.dart';

class ChoiceScreen extends StatefulWidget {
  final Function read;
  final Function listen;

  final ApiResponse booksList;
  final ConfigApiResponseModel configResponse;
  const ChoiceScreen(
      {super.key,
      required this.read,
      required this.listen,
      required this.booksList,
      required this.configResponse});

  @override
  State<ChoiceScreen> createState() => _ChoiceScreenState();
}

class _ChoiceScreenState extends State<ChoiceScreen> {
  AudioController backgroundaudioController = Get.put(AudioController());
  @override
  Widget build(BuildContext context) {
    final mainPlayDuration = 1000.ms;
    final buttonPlayDuration = mainPlayDuration - 200.ms;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        
        backgroundColor: Colors.transparent,
        body: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.7),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    left: MediaQuery.of(context).size.width * 0.075,
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.height * 0.06,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon:
                            const Icon(Icons.home_outlined, color: Colors.blue),
                        onPressed: () {
                          if (backgroundaudioController.isPlaying) {
                            Get.offAll(
                                BookListPage(
                                  booksList: widget.booksList,
                                  configResponse: widget.configResponse,
                                ),
                                transition: Transition.fadeIn,
                                duration: const Duration(seconds: 2));

                           
                          } else {
                            Get.offAll(
                                BookListPage(
                                  booksList: widget.booksList,
                                  configResponse: widget.configResponse,
                                  isbackgroundsilent: true,
                                ),
                                transition: Transition.fadeIn,
                                duration: const Duration(seconds: 2));

                         
                          }
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: MediaQuery.of(context).size.width * 0.075,
                    child: CircleAvatar(
                        radius: MediaQuery.of(context).size.height * 0.06,
                        backgroundColor: Colors.white,
                        child: GetBuilder<AudioController>(
                            builder: (audioController) {
                          return IconButton(
                            icon: GetBuilder<AudioController>(
                              builder: (audioController) {
                                return Icon(
                                  audioController.isPlaying
                                      ? Icons.music_note_outlined
                                      : Icons.music_off_outlined,
                                  color: Colors.blue,
                                );
                              },
                            ),
                            onPressed: () {
                              AudioController audioController =
                                  Get.find<AudioController>();
                              audioController.toggleAudio();
                            },
                          );
                        })),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => widget.listen(),
                          child: AnimatedButtonWidget(
                            buttonDelayDuration:
                                const Duration(milliseconds: 1),
                            buttonPlayDuration: buttonPlayDuration,
                            text: Strings.readtoMe,
                            // icon: Icons.headphones,
                          ),
                        ),
                        SizedBox(
                          height: 50.h,
                        ),
                        InkWell(
                          onTap: () => widget.read(),
                          child: AnimatedButtonWidget(
                            buttonDelayDuration:
                                const Duration(milliseconds: 1),
                            buttonPlayDuration: buttonPlayDuration,
                            text: Strings.readMySelf,
                            //icon: Icons.chrome_reader_mode_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
