import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:open_store/open_store.dart';
import 'package:storyapp/pages/parentalgate/parentalgate.dart';
import 'package:storyapp/utils/Constants/AllStrings.dart';
import 'package:storyapp/utils/Constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:resize/resize.dart';
import 'package:storyapp/utils/colorConvet.dart';
import '../../controller/backgroundMusicAudioController.dart';
import '../../model/booklistModel.dart';
import '../../model/configModel.dart';
import '../../model/storyPage.dart';
import '../../services/apiEndpoints.dart';
import '../../utils/Constants/dimention.dart';
import '../../widget/aboutdialog.dart';
import '../../widget/choice.dart';
import '../../widget/dialog.dart';
import '../StoryPage/StoryPage.dart';
import 'package:get/get.dart' hide Response;
import '../SubscriptionPage/iap_services.dart';
import '../SubscriptionPage/status/subscriptionstatus.dart';
import '../SubscriptionPage/subscription.dart';

class BookListPage extends StatefulWidget {
  final ApiResponse booksList;
  final ConfigApiResponseModel configResponse;
  final bool? fromlocal;
  final bool? isbackgroundsilent;
  const BookListPage(
      {Key? key,
      required this.booksList,
      required this.configResponse,
      this.fromlocal,
      this.isbackgroundsilent})
      : super(key: key);

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final ScrollController _scrollController = ScrollController();

  late StreamSubscription<List<PurchaseDetails>> _iapSubscription;

  late AudioController audioController;
  late List<Future<bool>> lockStatusList;

  Dio dio = Dio();
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  List<StoryPageApiResponse?> storypageresponses = [];
  StoryPageApiResponse? singlestoryPageResponse;
  String folderName = '';

  bool musicForAd = false;
  Color buttonColor = AppColors.backgroundColor;
  bool loadingStory = false;

  bool adsEnabled = true;

  //!check Sub
  // bool isSubscribedMonthly = false;
  // bool isSubscribedYearly = false;

  //!ad
  final SubscriptionStatus subscriptionStatus = Get.put(SubscriptionStatus());
  // Future<void> loadSubscriptionStatus() async {
  //   final Map<String, bool> subscriptionStatus =
  //       await SubscriptionStatus.getSubscriptionStatus();
  //   setState(() {
  //     isSubscribedMonthly = subscriptionStatus[monthlySubscriptionKey] ?? false;
  //     isSubscribedYearly = subscriptionStatus[yearlySubscriptionKey] ?? false;
  //   });
  // }
  Future<void> restorepurchase() async {
    await InAppPurchase.instance.restorePurchases();
  }

  // void checkSubscriptionValidity() async {
  //   DateTime? storedPurchaseDate =
  //       await subscriptionStatus.getStoredPurchaseDate();

  //   if (storedPurchaseDate != null) {
  //     logger.e('Stored Purchase Date: $storedPurchaseDate');

  //     bool isActive =
  //         subscriptionStatus.isSubscriptionActive(storedPurchaseDate);
  //     logger.e('Is Subscription Active: $isActive');
  //     if (isActive) {
  //       if (subscriptionStatus.isMonthly.value) {
  //         subscriptionStatus.saveSubscriptionStatus(true, false);
  //       } else if (subscriptionStatus.isYearly.value) {
  //         subscriptionStatus.saveSubscriptionStatus(false, true);
  //       }
  //     } else {
  //       logger.e('Subscription Expired or other issue found.');
  //       subscriptionStatus.saveSubscriptionStatus(false, false);
  //     }
  //   } else {
  //     logger.e('No stored purchase date found.');
  //   }
  // }

  @override
  void initState() {
    super.initState();

    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;

    _iapSubscription = purchaseUpdated.listen((purchaseDetailsList) {
      IAPService(
              monthlyProductId: Platform.isAndroid
                  ? widget.configResponse.androidSettings.subscriptionSettings
                      .monthSubscriptionProductID!
                  : widget.configResponse.iosSettings.subscriptionSettings
                      .monthSubscriptionProductID!,
              yearlyProductId: Platform.isAndroid
                  ? widget.configResponse.androidSettings.subscriptionSettings
                      .yearSubscriptionProductID!
                  : widget.configResponse.iosSettings.subscriptionSettings
                      .yearSubscriptionProductID!)
          .listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _iapSubscription.cancel();
    }, onError: (error) {
      _iapSubscription.cancel();
    }) as StreamSubscription<List<PurchaseDetails>>;

    //!Check Subscription Availability
    IAPService(
            monthlyProductId: Platform.isAndroid
                ? widget.configResponse.androidSettings.subscriptionSettings
                    .monthSubscriptionProductID!
                : widget.configResponse.iosSettings.subscriptionSettings
                    .monthSubscriptionProductID!,
            yearlyProductId: Platform.isAndroid
                ? widget.configResponse.androidSettings.subscriptionSettings
                    .yearSubscriptionProductID!
                : widget.configResponse.iosSettings.subscriptionSettings
                    .yearSubscriptionProductID!)
        .checkSubscriptionAvailabilty();

    // loadSubscriptionStatus();
    //checkSubscriptionValidity();
    //restorepurchase();
    initcalls();
    fetchAdIds();
  }

  //!usage
  Future<void> fetchAdIds() async {
    //! Initialize AdController with fetched ad IDs
  }

  void initcalls() {
    audioController = Get.put(AudioController());
    if (widget.isbackgroundsilent == null) {
      audioController.startAudio(widget.booksList.backgroundMusic);
    } else {
      audioController.startAudio(widget.booksList.backgroundMusic,
          backgroundMusicPause: true);
    }

    lockStatusList = List<Future<bool>>.generate(
      widget.booksList.books.length,
      (index) => getLockStatus(widget.booksList.books[index].title),
    );

    _scrollController.addListener(() {
      setState(() {
        showScrollToTopButton = _scrollController.offset > 0;
      });
    });

    setState(() {
      adsEnabled = Platform.isAndroid
          ? widget.configResponse.androidSettings.admobSettings.adsEnabled!
          : widget.configResponse.iosSettings.admobSettings.adsEnabled!;
    });
  }

  Future<void> checkInternetConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _connectivityResult = connectivityResult;
    });

    if (connectivityResult == ConnectivityResult.none) {
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ChoiceDialogBox(
              title: Strings.noInternet,
              titleColor: const Color(0xffED1E54),
              descriptions: Strings.noInternetDescription,
              text: Strings.ok,
              functionCall: () {
                Navigator.pop(context);
                checkInternetConnection();
              },
              closeicon: true,
            );
          });
    } else {
      initcalls();
    }
  }

  bool showScrollToTopButton = false;
  void showDialogss(BuildContext context) {
    checkInternetConnection();
    if (_connectivityResult != ConnectivityResult.none) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ChoiceDialogBox(
              title: Strings.oops,
              titleColor: const Color(0xffED1E54),
              descriptions: Strings.storyTryagain,
              text: Strings.ok,
              functionCall: () {
                Navigator.pop(context);
              },
              closeicon: true,
            );
          });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _iapSubscription.cancel();
  }

  Future<bool> getLockStatus(String bookTitle) async {
    int rewardedCountLimit = Platform.isAndroid
        ? widget.configResponse.androidSettings.admobSettings.admobRewardedAd!
                .rewardedCount ??
            3
        : widget.configResponse.iosSettings.admobSettings.admobRewardedAd!
                .rewardedCount ??
            3;

    return false;
  }

  void goToStoryPage(String folder) {
    if (folderName == folder) {
      Get.offAll(
          BookPage(
            response: singlestoryPageResponse!,
            folder: folder,
            backgroundMusic: widget.booksList.backgroundMusic,
            booksList: widget.booksList,
            configResponse: widget.configResponse,
          ),
          transition: Transition.circularReveal,
          duration: const Duration(seconds: 2));
    } else {
      getSelectedStory(folder, goto: true);
    }
  }

  Future<void> getSelectedStory(String folder, {bool? goto}) async {
    setState(() {
      loadingStory = true;
    });
    try {
      Response sResponse =
          await dio.get('${APIEndpoints.baseUrl}/$folder/book.json');
      //logger.e('${APIEndpoints.baseUrl}/$folder/book.json');
      if (sResponse.statusCode == 200) {
        setState(() {
          loadingStory = false;
        });
        StoryPageApiResponse storyPageresponse =
            StoryPageApiResponse.fromJson(sResponse.data);
        singlestoryPageResponse = storyPageresponse;
        folderName = folder;

        if (goto != null) {
          Get.offAll(
              BookPage(
                response: singlestoryPageResponse!,
                folder: folder,
                backgroundMusic: widget.booksList.backgroundMusic,
                booksList: widget.booksList,
                configResponse: widget.configResponse,
              ),
              transition: Transition.circularReveal,
              duration: const Duration(seconds: 2));
        }
      } else {
        setState(() {
          loadingStory = false;
        });

        // ignore: use_build_context_synchronously
        showDialogss(context);
      }
    } catch (e) {
      setState(() {
        loadingStory = false;
      });
    }
  }

  bool _isMenuOpen = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.booksList.backgroundColor.toColor(),
      // floatingActionButton: Padding(
      //   padding: EdgeInsets.only(
      //     bottom: 4.0,
      //     right: (MediaQuery.of(context).size.height * 0.08) - 16,
      //   ),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.end,
      //     crossAxisAlignment: CrossAxisAlignment.end,
      //     children: [
      //       //!About FAB
      //       Visibility(
      //         visible: _isMenuOpen,
      //         child: CircleAvatar(
      //           radius: 25,
      //           child: FloatingActionButton(
      //             onPressed: () {
      //               showDialog(
      //                 context: context,
      //                 barrierDismissible: false,
      //                 builder: (BuildContext context) {
      //                   return AboutDialogBox(
      //                     titleColor: Colors.orange,
      //                     descriptions: Platform.isAndroid
      //                         ? widget.configResponse.androidSettings.aboutApp
      //                         : widget.configResponse.iosSettings.aboutApp,
      //                     secfunctionCall: () {
      //                       Navigator.pop(context);
      //                     },
      //                   );
      //                 },
      //               );
      //             },
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(20.0),
      //             ),
      //             heroTag: 'About',
      //             tooltip: 'About',
      //             backgroundColor: buttonColor,
      //             child: const Icon(Icons.privacy_tip_outlined),
      //           ),
      //         ),
      //       ),
      //       const SizedBox(height: 10),

      //       //!Settings FAB
      //       Visibility(
      //         visible: _isMenuOpen,
      //         child: CircleAvatar(
      //           radius: 25,
      //           child: FloatingActionButton(
      //             onPressed: () {
      //               Permission.getPermission(
      //                 context: context,
      //                 onSuccess: () {
      //                   openSubscriptionPage();
      //                   print("True");
      //                 },
      //                 onFail: () {
      //                   print("false");
      //                 },
      //               );
      //             },
      //             backgroundColor: buttonColor,
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(20.0),
      //             ),
      //             heroTag: 'Settings',
      //             tooltip: 'Settings',
      //             child: const Icon(Icons.settings),
      //           ),
      //         ),
      //       ),
      //       const SizedBox(height: 10),

      //       //!FAB
      //       CircleAvatar(
      //         radius: 25,
      //         child: FloatingActionButton(
      //           backgroundColor: buttonColor,
      //           onPressed: () {
      //             setState(() {
      //               _isMenuOpen = !_isMenuOpen;
      //             });
      //           },
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(20.0),
      //           ),
      //           tooltip: 'Toggle',
      //           child: _isMenuOpen
      //               ? const Icon(Icons.close)
      //               : const Icon(Icons.expand_less_outlined),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: Stack(
        children: [
          //!Background Image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),

          //!BookList GridView
          Padding(
            padding: EdgeInsets.only(
              //top: 20.0,
              left: MediaQuery.of(context).size.height * 0.25,
              right: MediaQuery.of(context).size.height * 0.25,
            ),
            child: AnimationLimiter(
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.15,
                        top: widget.configResponse.houseAd!.show != null &&
                                Platform.isAndroid
                            ? widget.configResponse.androidSettings.houseAd!
                                    .show!
                                ? 25.w
                                : 20
                            : widget.configResponse.iosSettings.houseAd!.show!
                                ? 25.w
                                : 20,
                      ),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 30,
                          crossAxisCount: 3,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            BookList book = widget.booksList.books[index];
                            return FutureBuilder<bool>(
                                future: lockStatusList[index],
                                builder: (context, snapshot) {
                                  bool bookstatus =
                                      subscriptionStatus.isMonthly.value ||
                                              subscriptionStatus.isYearly.value
                                          ? true
                                          : snapshot.data ?? false;
                                  int rewardedCountLimit = Platform.isAndroid
                                      ? widget
                                              .configResponse
                                              .androidSettings
                                              .admobSettings
                                              .admobRewardedAd!
                                              .rewardedCount ??
                                          3
                                      : widget
                                              .configResponse
                                              .iosSettings
                                              .admobSettings
                                              .admobRewardedAd!
                                              .rewardedCount ??
                                          3;
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 500),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: InkWell(
                                            onTap: () async {
                                              if (!loadingStory) {
                                                final connectivityResult =
                                                    await (Connectivity()
                                                        .checkConnectivity());

                                                if (connectivityResult ==
                                                    ConnectivityResult.none) {
                                                  // ignore: use_build_context_synchronously
                                                  showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (BuildContext
                                                          context) {
                                                        return ChoiceDialogBox(
                                                          title: Strings
                                                              .noInternet,
                                                          titleColor:
                                                              const Color(
                                                                  0xffED1E54),
                                                          descriptions: Strings
                                                              .noInternetDescription,
                                                          text: Strings.ok,
                                                          functionCall: () {
                                                            Navigator.pop(
                                                                context);
                                                            //checkInternetConnection();
                                                          },
                                                          closeicon: true,
                                                        );
                                                      });
                                                } else {
                                                  getSelectedStory(book.path);
                                                  if (!book.locked ||
                                                      subscriptionStatus
                                                          .isMonthly.value ||
                                                      subscriptionStatus
                                                          .isYearly.value) {
                                                    //!Navigate to Story Page for First index Without Ad
                                                    getSelectedStory(book.path,
                                                        goto: true);
                                                  } else if (book.locked ==
                                                      true) {
                                                    //!show reward ad if available for locked books
                                                    final isAndroid =
                                                        Platform.isAndroid;

                                                    final unlockMessage = isAndroid
                                                        ? widget
                                                                .configResponse
                                                                .androidSettings
                                                                .unlockDialogText ??
                                                            ""
                                                        : widget
                                                                .configResponse
                                                                .iosSettings
                                                                .unlockDialogText ??
                                                            "";

                                                    final subscriptionMessage = isAndroid
                                                        ? widget
                                                                .configResponse
                                                                .androidSettings
                                                                .subscriptionSettings
                                                                .generalSubscriptionText ??
                                                            ""
                                                        : widget
                                                                .configResponse
                                                                .iosSettings
                                                                .subscriptionSettings
                                                                .generalSubscriptionText ??
                                                            "";
                                                    // ignore: use_build_context_synchronously
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (BuildContext
                                                          context) {
                                                        return CustomDialogBox(
                                                          title: Strings
                                                              .unloackStory,
                                                          titleColor:
                                                              Colors.orange,
                                                          descriptions: unlockMessage
                                                                  .isNotEmpty
                                                              ? unlockMessage
                                                              : subscriptionMessage,
                                                          text: null,
                                                          text2: "Subscribe",
                                                          functionCall: () {},
                                                          secfunctionCall: () {
                                                            Navigator.pop(
                                                                context);
                                                            if (Platform
                                                                .isAndroid) {
                                                              widget
                                                                      .configResponse
                                                                      .androidSettings
                                                                      .parentalGate!
                                                                  ? Permission
                                                                      .getPermission(
                                                                      context:
                                                                          context,
                                                                      onSuccess:
                                                                          () {
                                                                        debugPrint(
                                                                            "True");
                                                                        openSubscriptionPage();
                                                                      },
                                                                      onFail:
                                                                          () {
                                                                        debugPrint(
                                                                            "false");
                                                                      },
                                                                      backgroundColor: widget
                                                                          .booksList
                                                                          .backgroundColor
                                                                          .toColor(),
                                                                    )
                                                                  : openSubscriptionPage();
                                                            } else if (Platform
                                                                .isIOS) {
                                                              widget
                                                                      .configResponse
                                                                      .iosSettings
                                                                      .parentalGate!
                                                                  ? Permission
                                                                      .getPermission(
                                                                      context:
                                                                          context,
                                                                      onSuccess:
                                                                          () {
                                                                        debugPrint(
                                                                            "True");
                                                                        openSubscriptionPage();
                                                                      },
                                                                      onFail:
                                                                          () {
                                                                        debugPrint(
                                                                            "false");
                                                                      },
                                                                      backgroundColor: widget
                                                                          .booksList
                                                                          .backgroundColor
                                                                          .toColor(),
                                                                    )
                                                                  : openSubscriptionPage();
                                                            }
                                                          },
                                                        );
                                                      },
                                                    );
                                                  } else {}
                                                }
                                              }
                                            },
                                            child: buildBookCard(
                                                book, bookstatus)),
                                      ),
                                    ),
                                  );
                                });
                          },
                          childCount: widget.booksList.books.length,
                        ),
                      )),

                  //!End Text
                  if (widget.booksList.bookListEndText != null)
                    SliverToBoxAdapter(
                      child: Center(
                          child: Text(
                        widget.booksList.bookListEndText!,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubikBubbles(
                            color: Colors.white, fontSize: 14.sp),
                      )),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.15,
                    ),
                  )
                ],
              ),
            ),
          ),

          //!Background Music
          Positioned(
            top: 20.0,
            right: MediaQuery.of(context).size.height * 0.08,
            child: CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.backgroundColor,
                child: GetBuilder<AudioController>(builder: (audioController) {
                  return IconButton(
                    iconSize: IconSizes.medium,
                    icon: Icon(
                      audioController.isPlaying
                          ? Icons.music_note_outlined
                          : Icons.music_off_outlined,
                      color: AppColors.iconColor,
                    ),
                    onPressed: () {
                      audioController.toggleAudio();
                    },
                  );
                })),
          ),

          // //!About
          Positioned(
            bottom: 20.0,
            right: MediaQuery.of(context).size.height * 0.08,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.end,
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                //!About FAB
                Visibility(
                  visible: _isMenuOpen,
                  child: CircleAvatar(
                    backgroundColor: AppColors.backgroundColor,
                    radius: 25,
                    child: FloatingActionButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AboutDialogBox(
                              titleColor: Colors.orange,
                              descriptions: Platform.isAndroid
                                  ? widget
                                      .configResponse.androidSettings.aboutApp
                                  : widget.configResponse.iosSettings.aboutApp,
                              secfunctionCall: () {
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      heroTag: 'About',
                      tooltip: 'About',
                      backgroundColor: buttonColor,
                      child: const Icon(
                        size: IconSizes.medium,
                        Icons.privacy_tip_outlined,
                        color: AppColors.iconColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                //!Settings FAB
                Visibility(
                  visible: _isMenuOpen,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.backgroundColor,
                    child: FloatingActionButton(
                      onPressed: () {
                        if (Platform.isAndroid) {
                          widget.configResponse.androidSettings.parentalGate!
                              ? Permission.getPermission(
                                  context: context,
                                  onSuccess: () {
                                    openSubscriptionPage();
                                    print("True");
                                  },
                                  onFail: () {
                                    print("false");
                                  },
                                  backgroundColor: widget
                                      .booksList.backgroundColor
                                      .toColor(),
                                )
                              : openSubscriptionPage();
                        } else if (Platform.isIOS) {
                          widget.configResponse.iosSettings.parentalGate!
                              ? Permission.getPermission(
                                  context: context,
                                  onSuccess: () {
                                    openSubscriptionPage();
                                    print("True");
                                  },
                                  onFail: () {
                                    print("false");
                                  },
                                  backgroundColor: widget
                                      .booksList.backgroundColor
                                      .toColor(),
                                )
                              : openSubscriptionPage();
                        }
                      },
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      heroTag: 'Settings',
                      tooltip: 'Settings',
                      child: const Icon(
                        size: IconSizes.medium,
                        Icons.settings,
                        color: AppColors.iconColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                //!FAB
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.backgroundColor,
                  child: FloatingActionButton(
                    backgroundColor: buttonColor,
                    onPressed: () {
                      setState(() {
                        _isMenuOpen = !_isMenuOpen;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    //tooltip: 'Toggle',
                    child: _isMenuOpen
                        ? const Icon(
                            size: IconSizes.medium,
                            Icons.close,
                            color: AppColors.iconColor)
                        : const Icon(
                            size: IconSizes.medium,
                            Icons.expand_less_outlined,
                            color: AppColors.iconColor,
                          ),
                  ),
                ),
              ],
            ),
          ),

          //!Scroll to Top
          if (showScrollToTopButton)
            Positioned(
              bottom: 20.0,
              left: MediaQuery.of(context).size.height * 0.08,
              child: CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.backgroundColor,
                child: IconButton(
                  iconSize: IconSizes.medium,
                  icon: const Icon(
                    Icons.arrow_upward_outlined,
                    color: AppColors.iconColor,
                  ),
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),

          //!House AD
          if (Platform.isAndroid)
            if (widget.configResponse.androidSettings.houseAd!.show != null &&
                widget.configResponse.androidSettings.houseAd!.show!)
              Align(
                alignment: Alignment.topCenter,
                child: InkWell(
                  onTap: () {
                    widget.configResponse.androidSettings.parentalGate!
                        ? Permission.getPermission(
                            context: context,
                            onSuccess: () {
                              openUrlAndroid(widget.configResponse
                                  .androidSettings.houseAd!.urlId!);
                              print("True");
                            },
                            onFail: () {
                              print("false");
                            },
                            backgroundColor:
                                widget.booksList.backgroundColor.toColor(),
                          )
                        : openUrlAndroid(widget
                            .configResponse.androidSettings.houseAd!.urlId!);
                  },
                  child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      height: 25.w,
                      decoration: BoxDecoration(
                          color: widget.configResponse.androidSettings.houseAd!
                              .buttonColor!
                              .toColor(opacity: 0.95),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12))),
                      child: Center(
                          child: Text(
                        widget.configResponse.androidSettings.houseAd!
                            .buttonText!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 8.sp,
                            height: 1.2,
                            color: widget.configResponse.androidSettings
                                .houseAd!.buttonTextColor!
                                .toColor()),
                      ))),
                ),
              ),

          if (Platform.isIOS)
            if (widget.configResponse.iosSettings.houseAd!.show != null &&
                widget.configResponse.iosSettings.houseAd!.show!)
              Align(
                alignment: Alignment.topCenter,
                child: InkWell(
                  onTap: () {
                    widget.configResponse.iosSettings.parentalGate!
                        ? Permission.getPermission(
                            context: context,
                            onSuccess: () {
                              openAppStore(widget
                                  .configResponse.iosSettings.houseAd!.urlId!);
                              print("True");
                            },
                            onFail: () {
                              print("false");
                            },
                            backgroundColor:
                                widget.booksList.backgroundColor.toColor(),
                          )
                        : openAppStore(
                            widget.configResponse.iosSettings.houseAd!.urlId!);
                  },
                  child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      height: 25.w,
                      decoration: BoxDecoration(
                          color: widget
                              .configResponse.iosSettings.houseAd!.buttonColor!
                              .toColor(opacity: 0.95),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12))),
                      child: Center(
                          child: Text(
                        widget.configResponse.iosSettings.houseAd!.buttonText!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 8.sp,
                            height: 1.2,
                            color: widget.configResponse.iosSettings.houseAd!
                                .buttonTextColor!
                                .toColor()),
                      ))),
                ),
              ),

          //!Loading
          if (loadingStory)
            Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ))
        ],
      ),
    );
  }

  void openUrlAndroid(String url) async {
    Uri uri = Uri.parse(url);

    if (uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https')) {
      //!The Url is a web link'
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch Url.';
      }
    } else {
      //!'The url is package name open playstore

      OpenStore.instance.open(
        //appStoreId: '1543803459',
        androidAppBundleId: url,
      );
    }
  }

  void openSubscriptionPage() {
    //Get.to(SubscriptionTest());
    Get.to(
        SubscriptionPage(
          generalSubscriptionText: Platform.isAndroid
              ? widget.configResponse.androidSettings.subscriptionSettings
                  .generalSubscriptionText!
              : widget.configResponse.iosSettings.subscriptionSettings
                  .generalSubscriptionText!,
          monthly: Platform.isAndroid
              ? widget.configResponse.androidSettings.subscriptionSettings
                  .monthSubscriptionText!
              : widget.configResponse.iosSettings.subscriptionSettings
                  .monthSubscriptionText!,
          yearly: Platform.isAndroid
              ? widget.configResponse.androidSettings.subscriptionSettings
                  .yearSubscriptionText!
              : widget.configResponse.iosSettings.subscriptionSettings
                  .yearSubscriptionText!,
          termofuseUrl: Platform.isAndroid
              ? widget.configResponse.androidSettings.subscriptionSettings
                  .termOfUseUrl!
              : widget.configResponse.iosSettings.subscriptionSettings
                  .termOfUseUrl!,
          privacyPolicyUrl: Platform.isAndroid
              ? widget.configResponse.androidSettings.subscriptionSettings
                  .privacyPolicyUrl!
              : widget.configResponse.iosSettings.subscriptionSettings
                  .privacyPolicyUrl!,
          backgroundcolor: widget.booksList.backgroundColor,
          monthlyProductId: Platform.isAndroid
              ? widget.configResponse.androidSettings.subscriptionSettings
                  .monthSubscriptionProductID!
              : widget.configResponse.iosSettings.subscriptionSettings
                  .monthSubscriptionProductID!,
          yearlyProductId: Platform.isAndroid
              ? widget.configResponse.androidSettings.subscriptionSettings
                  .yearSubscriptionProductID!
              : widget.configResponse.iosSettings.subscriptionSettings
                  .yearSubscriptionProductID!,
          booksList: widget.booksList,
          configResponse: widget.configResponse,
        ),
        transition: Transition.leftToRight);
  }

  void openAppStore(String appId) async {
    Uri uri = Uri.parse(appId);

    if (uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https')) {
      //!The Url is a web link'
      if (await canLaunch(appId)) {
        await launch(appId);
      } else {
        throw 'Could not launch Url.';
      }
    } else {
      //!'The url is AppId open Appstore
      OpenStore.instance.open(
        appStoreId: appId,
      );
    }
  }

  Widget buildBookCard(BookList book, bool bookState) {
    return SizedBox(
      height: 150,
      child: Card(
        elevation: 2,
        color: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FadeInImage(
                width: double.infinity,
                height: double.infinity,
                placeholder: const AssetImage('assets/bg.png'),
                image: CachedNetworkImageProvider(
                  '${APIEndpoints.baseUrl}/${book.thumbnail}',
                ),
                fadeInDuration: const Duration(milliseconds: 2000),
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.transparent,
                  );
                },
              ),
            ),
            //! Overlay for the title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12))),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      book.title,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                      maxLines: 3,
                      style: TextStyle(
                          height: 1,
                          color: Colors.white,
                          fontSize: 6.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),

            if (book.locked && !bookState)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  width: double.infinity,
                  height: double.infinity,
                  child: const Icon(Icons.lock, color: Colors.white, size: 30),
                ),
              )
          ],
        ),
      ),
    );
  }
}
