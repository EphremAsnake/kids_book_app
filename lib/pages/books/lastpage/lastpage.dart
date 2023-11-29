import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:resize/resize.dart';

import '../../../controller/backgroundMusicAudioController.dart';
import '../../../model/booklistModel.dart';
import '../../../model/configModel.dart';
import '../../../widget/animated_button_widget.dart';
import '../../bookList.dart';

class LastScreen extends StatefulWidget {
  final Function replay;

  final ApiResponse booksList;
  final ConfigApiResponseModel configResponse;
  const LastScreen(
      {super.key,
      required this.replay,
      required this.booksList,
      required this.configResponse});

  @override
  State<LastScreen> createState() => _ChoiceScreenState();
}

class _ChoiceScreenState extends State<LastScreen> {
  @override
  Widget build(BuildContext context) {
    final mainPlayDuration = 1000.ms;
    final leavesDelayDuration = 600.ms;
    final titleDelayDuration = mainPlayDuration + 50.ms;
    final descriptionDelayDuration = titleDelayDuration + 300.ms;
    final buttonDelayDuration = descriptionDelayDuration + 100.ms;
    final buttonPlayDuration = mainPlayDuration - 200.ms;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        // ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.7),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    // Positioned(
                    //   top: 20,
                    //   left: MediaQuery.of(context).size.width * 0.075,
                    //   child: CircleAvatar(
                    //     radius: MediaQuery.of(context).size.height * 0.06,
                    //     backgroundColor: Colors.white,
                    //     child: IconButton(
                    //       icon:
                    //           const Icon(Icons.home_outlined, color: Colors.blue),
                    //       onPressed: () {
                    //         Navigator.pushReplacement(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => BookListPage(
                    //               booksList: widget.booksList,
                    //               configResponse: widget.configResponse,
                    //             ),
                    //           ),
                    //         );
                    //       },
                    //     ),
                    //   ),
                    // ),
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
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookListPage(
                                    booksList: widget.booksList,
                                    configResponse: widget.configResponse,
                                  ),
                                ),
                              );
                            },
                            child: AnimatedButtonWidget(
                              buttonDelayDuration:
                                  const Duration(milliseconds: 1),
                              buttonPlayDuration: buttonPlayDuration,
                              text: 'Home',
                              icon: Icons.home_outlined,
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          InkWell(
                            onTap: () => widget.replay(),
                            child: AnimatedButtonWidget(
                              buttonDelayDuration:
                                  const Duration(milliseconds: 1),
                              buttonPlayDuration: buttonPlayDuration,
                              text: 'Replay Story',
                              icon: Icons.headphones,
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          InkWell(
                            onTap: () {},
                            child: AnimatedButtonWidget(
                              buttonDelayDuration:
                                  const Duration(milliseconds: 1),
                              buttonPlayDuration: buttonPlayDuration,
                              text: 'Rate',
                              icon: Icons.headphones,
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          InkWell(
                            onTap: () => {},
                            child: AnimatedButtonWidget(
                              buttonDelayDuration:
                                  const Duration(milliseconds: 1),
                              buttonPlayDuration: buttonPlayDuration,
                              text: 'Share',
                              icon: Icons.headphones,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
