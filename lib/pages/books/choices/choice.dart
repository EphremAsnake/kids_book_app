import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/backgroundMusicAudioController.dart';
import '../../../model/booklistModel.dart';
import '../../../model/configModel.dart';
import '../../../widget/animated_button_widget.dart';
import '../../bookList.dart';

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
                        // InkWell(
                        //   onTap: () {},
                        //   child: Container(
                        //     height: 47,
                        //     width: MediaQuery.of(context).size.width * .3,
                        //     decoration: BoxDecoration(
                        //         color: Colors.blue,
                        //         borderRadius: BorderRadius.circular(12)),
                        //     child: const Center(
                        //       child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           Icon(
                        //             Icons.chrome_reader_mode_rounded,
                        //             color: Colors.white,
                        //           ),
                        //           SizedBox(
                        //             width: 5,
                        //           ),
                        //           Text(
                        //             'Read',
                        //             style: TextStyle(
                        //                 fontSize: 20,
                        //                 color: Colors.white,
                        //                 fontWeight: FontWeight.w500),
                        //             textAlign: TextAlign.center,
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(
                        //   height: 20.0,
                        // ),
                        // InkWell(
                        //   onTap: () {},
                        //   child: Container(
                        //     height: 47,
                        //     width: MediaQuery.of(context).size.width * .3,
                        //     decoration: BoxDecoration(
                        //         color: Colors.blue,
                        //         borderRadius: BorderRadius.circular(12)),
                        //     child: const Center(
                        //       child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           Icon(
                        //             Icons.headphones,
                        //             color: Colors.white,
                        //           ),
                        //           SizedBox(
                        //             width: 5,
                        //           ),
                        //           Text(
                        //             'Listen',
                        //             style: TextStyle(
                        //                 fontSize: 20,
                        //                 color: Colors.white,
                        //                 fontWeight: FontWeight.w500),
                        //             textAlign: TextAlign.center,
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(
                        //   height: 20.0,
                        // ),
                        InkWell(
                          onTap: () => widget.read(),
                          child: AnimatedButtonWidget(
                            buttonDelayDuration:
                                const Duration(milliseconds: 1),
                            buttonPlayDuration: buttonPlayDuration,
                            text: 'Read',
                            icon: Icons.chrome_reader_mode_rounded,
                          ),
                        ),

                        const SizedBox(
                          height: 20.0,
                        ),
                        InkWell(
                          onTap: () => widget.listen(),
                          child: AnimatedButtonWidget(
                            buttonDelayDuration:
                                const Duration(milliseconds: 1),
                            buttonPlayDuration: buttonPlayDuration,
                            text: 'Listen',
                            icon: Icons.headphones,
                          ),
                        ),

                        // const SizedBox(
                        //   height: 20.0,
                        // ),
                        // AnimatedButtonWidget(
                        //   buttonDelayDuration: const Duration(milliseconds: 1),
                        //   buttonPlayDuration: buttonPlayDuration,
                        //   text: 'Record',
                        //   icon: Icons.mic,
                        // ),

                        // const SizedBox(
                        //     height: 20.0,
                        //   ),
                        // Container(
                        //   width: MediaQuery.of(context).size.width - 20,
                        //   height: 200,
                        //   color: Colors.orange,
                        //   child: Center(child: Text("Second Screen", )),
                        // ),
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
