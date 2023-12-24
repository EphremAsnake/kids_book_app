import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:open_store/open_store.dart';
import 'package:resize/resize.dart';
import 'package:storyapp/utils/colorConvet.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controller/backgroundMusicAudioController.dart';
import '../../../model/booklistModel.dart';
import '../../../model/configModel.dart';
import '../../../widget/animatedbuttonwidget.dart';
import '../../BookMenu/BookListMenu.dart';
import '../../parentalgate/parentalgate.dart';

class LastScreen extends StatefulWidget {
  final Function replay;
  final Function close;
  final ApiResponse booksList;
  final ConfigApiResponseModel configResponse;
  const LastScreen({
    super.key,
    required this.replay,
    required this.booksList,
    required this.configResponse,
    required this.close,
  });

  @override
  State<LastScreen> createState() => _ChoiceScreenState();
}

class _ChoiceScreenState extends State<LastScreen> {
  AudioController backgroundaudioController = Get.put(AudioController());

  Future<void> shareApp() async {
    //! Share the app link and message using the share dialog
    await FlutterShare.share(
      title: 'Share App',
      text: Platform.isAndroid
          ? widget.configResponse.androidSettings.appRateAndShare!.share
          : widget.configResponse.iosSettings.appRateAndShare!.share,
    );
  }

  void openUrlAndroid(String url) async {
    //!open Playstore
    OpenStore.instance.open(
      androidAppBundleId: url,
    );
  }

  void openAppStore(String appId) async {
    final String appStoreUrl =
        'https://apps.apple.com/app/id$appId?action=write-review';

    if (await canLaunch(appStoreUrl)) {
      await launch(appStoreUrl);
    } else {
      throw 'Could not launch App Store';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainPlayDuration = 1000.ms;
    final buttonPlayDuration = mainPlayDuration - 200.ms;
    return WillPopScope(
      onWillPop: () async {
        widget.close();
        return false;
      },
      child: Scaffold(
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
                    Positioned(
                      top: 20,
                      right: MediaQuery.of(context).size.width * 0.075,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.blue),
                          onPressed: () => widget.close(),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
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
                            child: AnimatedButtonWidget(
                              buttonDelayDuration:
                                  const Duration(milliseconds: 1),
                              buttonPlayDuration: buttonPlayDuration,
                              text: 'Home ',
                              icon: Icons.home_outlined,
                            ),
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          InkWell(
                            onTap: () => widget.replay(),
                            child: AnimatedButtonWidget(
                              buttonDelayDuration:
                                  const Duration(milliseconds: 1),
                              buttonPlayDuration: buttonPlayDuration,
                              text: 'Replay',
                              icon: Icons.replay,
                            ),
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (Platform.isAndroid) {
                                    widget.configResponse.androidSettings
                                            .parentalGate!
                                        ? Permission.getPermission(
                                            context: context,
                                            onSuccess: () {
                                              shareApp();
                                              print("True");
                                            },
                                            onFail: () {
                                              print("false");
                                            },
                                            backgroundColor: widget
                                                .booksList.backgroundColor
                                                .toColor(),
                                          )
                                        : shareApp();
                                  } else if (Platform.isIOS) {
                                    widget.configResponse.iosSettings
                                            .parentalGate!
                                        ? Permission.getPermission(
                                            context: context,
                                            onSuccess: () {
                                              shareApp();
                                              print("True");
                                            },
                                            onFail: () {
                                              print("false");
                                            },
                                            backgroundColor: widget
                                                .booksList.backgroundColor
                                                .toColor(),
                                          )
                                        : shareApp();
                                  }
                                },
                                child: AnimatedButtonWidget(
                                  isRow: true,
                                  buttonDelayDuration:
                                      const Duration(milliseconds: 1),
                                  buttonPlayDuration: buttonPlayDuration,
                                  text: '',
                                  icon: Icons.share,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .01,
                              ),
                              InkWell(
                                onTap: () {
                                  if (Platform.isAndroid) {
                                    Permission.getPermission(
                                      context: context,
                                      onSuccess: () {
                                        openUrlAndroid(widget
                                            .configResponse
                                            .androidSettings
                                            .appRateAndShare!
                                            .urlId!);
                                        print("True");
                                      },
                                      onFail: () {
                                        print("false");
                                      },
                                      backgroundColor: widget
                                          .booksList.backgroundColor
                                          .toColor(),
                                    );
                                  } else {
                                    Permission.getPermission(
                                      context: context,
                                      onSuccess: () {
                                        openAppStore(widget
                                            .configResponse
                                            .iosSettings
                                            .appRateAndShare!
                                            .urlId!);
                                        print("True");
                                      },
                                      onFail: () {
                                        print("false");
                                      },
                                      backgroundColor: widget
                                          .booksList.backgroundColor
                                          .toColor(),
                                    );
                                  }
                                },
                                child: AnimatedButtonWidget(
                                  isRow: true,
                                  buttonDelayDuration:
                                      const Duration(milliseconds: 1),
                                  buttonPlayDuration: buttonPlayDuration,
                                  text: '',
                                  icon: Icons.star_border,
                                ),
                              ),
                            ],
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
