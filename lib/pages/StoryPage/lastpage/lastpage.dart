import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:open_store/open_store.dart';
import 'package:resize/resize.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controller/backgroundMusicAudioController.dart';
import '../../../model/booklistModel.dart';
import '../../../model/configModel.dart';
import '../../../utils/Constants/colors.dart';
import '../../../utils/Constants/dimention.dart';
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

  void shareApp() {
    //! Share the app link and message using the share dialog
    final shareMessage = Platform.isAndroid
        ? widget.configResponse.androidSettings.appRateAndShare?.share ?? ""
        : widget.configResponse.iosSettings.appRateAndShare?.share ?? "";

    Share.share(shareMessage);
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

    _launchURL(appStoreUrl);
  }

  Future<void> _launchURL(String _url) async {
    if (!await launchUrl(Uri.parse(_url))) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainPlayDuration = 1000.ms;
    final buttonPlayDuration = mainPlayDuration - 200.ms;
    // ignore: deprecated_member_use
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
                        backgroundColor: AppColors.backgroundColor,
                        child: IconButton(
                          iconSize: IconSizes.medium,
                          icon: const Icon(Icons.close,
                              color: AppColors.iconColor),
                          onPressed: () => widget.close(),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15.0),
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
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: AnimatedButtonWidget(
                                  buttonDelayDuration:
                                      const Duration(milliseconds: 1),
                                  buttonPlayDuration: buttonPlayDuration,
                                  text: 'Home ',
                                  icon: Icons.home_outlined,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15.0),
                              onTap: () => widget.replay(),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: AnimatedButtonWidget(
                                  buttonDelayDuration:
                                      const Duration(milliseconds: 1),
                                  buttonPlayDuration: buttonPlayDuration,
                                  text: 'Replay',
                                  icon: Icons.replay,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15.0),
                                  onTap: () {
                                    if (Platform.isAndroid) {
                                      widget.configResponse.androidSettings
                                              .parentalGate!
                                          ? Permission.getPermission(
                                              context: context,
                                              onSuccess: () {
                                                shareApp();
                                              },
                                              onFail: () {},
                                              backgroundColor:
                                                  AppColors.primaryColor,
                                            )
                                          : shareApp();
                                    } else if (Platform.isIOS) {
                                      widget.configResponse.iosSettings
                                              .parentalGate!
                                          ? Permission.getPermission(
                                              context: context,
                                              onSuccess: () {
                                                shareApp();
                                              },
                                              onFail: () {},
                                              backgroundColor:
                                                  AppColors.primaryColor,
                                            )
                                          : shareApp();
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: AnimatedButtonWidget(
                                      isRow: true,
                                      buttonDelayDuration:
                                          const Duration(milliseconds: 1),
                                      buttonPlayDuration: buttonPlayDuration,
                                      text: '',
                                      icon: Icons.share,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .01,
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15.0),
                                  onTap: () {
                                    if (Platform.isAndroid) {
                                      widget.configResponse.androidSettings
                                              .parentalGate!
                                          ? Permission.getPermission(
                                              context: context,
                                              onSuccess: () {
                                                openUrlAndroid(widget
                                                    .configResponse
                                                    .androidSettings
                                                    .appRateAndShare!
                                                    .urlId!);
                                              },
                                              onFail: () {},
                                              backgroundColor:
                                                  AppColors.primaryColor,
                                            )
                                          : openUrlAndroid(widget
                                              .configResponse
                                              .androidSettings
                                              .appRateAndShare!
                                              .urlId!);
                                    } else {
                                      widget.configResponse.iosSettings
                                              .parentalGate!
                                          ? Permission.getPermission(
                                              context: context,
                                              onSuccess: () {
                                                openAppStore(widget
                                                    .configResponse
                                                    .iosSettings
                                                    .appRateAndShare!
                                                    .urlId!);
                                              },
                                              onFail: () {},
                                              backgroundColor:
                                                  AppColors.primaryColor,
                                            )
                                          : openAppStore(widget
                                              .configResponse
                                              .iosSettings
                                              .appRateAndShare!
                                              .urlId!);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: AnimatedButtonWidget(
                                      isRow: true,
                                      buttonDelayDuration:
                                          const Duration(milliseconds: 1),
                                      buttonPlayDuration: buttonPlayDuration,
                                      text: '',
                                      icon: Icons.star_border,
                                    ),
                                  ),
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
