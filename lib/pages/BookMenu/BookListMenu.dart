import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';
import 'package:open_store/open_store.dart';
import 'package:storyapp/pages/parentalgate/parentalgate.dart';
import 'package:storyapp/utils/Constants/AllStrings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:resize/resize.dart';
import 'package:storyapp/utils/colorConvet.dart';
import '../../controller/adController.dart';
import '../../controller/backgroundMusicAudioController.dart';
import '../../model/booklistModel.dart';
import '../../model/configModel.dart';
import '../../model/storyPage.dart';
import '../../services/apiEndpoints.dart';
import '../../utils/adhelper.dart';
import '../../utils/admanager.dart';
import '../../widget/aboutdialog.dart';
import '../../widget/choice.dart';
import '../../widget/dialog.dart';
import '../Settings/settingpage.dart';
import '../StoryPage/StoryPage.dart';
import 'package:get/get.dart' hide Response;

import '../SubscriptionPage/iap_services.dart';
import '../SubscriptionPage/status/subscriptionstatus.dart';
import '../SubscriptionPage/subscription.dart';
import '../SubscriptionPage/test.dart';

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
  Color buttonColor = Colors.white;
  Logger logger = Logger();
  bool loadingStory = false;

  bool adsEnabled = true;

  //!check Sub
  bool isSubscribedMonthly = false;
  bool isSubscribedYearly = false;

  //!ad
  late AdController adController;

  Future<void> loadSubscriptionStatus() async {
    final Map<String, bool> subscriptionStatus =
        await SubscriptionStatus.getSubscriptionStatus();
    setState(() {
      isSubscribedMonthly = subscriptionStatus[monthlySubscriptionKey] ?? false;
      isSubscribedYearly = subscriptionStatus[yearlySubscriptionKey] ?? false;
    });
  }

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

    loadSubscriptionStatus();
    initcalls();
    fetchAdIds();
  }

  //!usage
  Future<void> fetchAdIds() async {
    String? rewardedAdId = AdHelper.getRewardedAdUnitId();
    String? interstitialAdId = AdHelper.getInterstitalAdUnitId();

    //! Initialize AdController with fetched ad IDs
    adController = Get.put(AdController(
      rewardedAdUnitId: rewardedAdId,
      interstitialAdUnitId: interstitialAdId,
    ));
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
    bool isWatched = await BookPreferences.getBookWatched(bookTitle);
    int openedCount = await BookPreferences.getBookOpenedCount(bookTitle);
    int rewardedCountLimit = Platform.isAndroid
        ? widget.configResponse.androidSettings.admobSettings.admobRewardedAd!
                .rewardedCount ??
            3
        : widget.configResponse.iosSettings.admobSettings.admobRewardedAd!
                .rewardedCount ??
            3;

    if (isWatched && openedCount <= rewardedCountLimit) {
      return true;
    } else {
      return false;
    }
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
        logger.e(storyPageresponse);
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
        logger.e(singlestoryPageResponse!.pages[0].image.toString());
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
                                      isSubscribedMonthly || isSubscribedYearly
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
                                                  if (index == 0 ||
                                                      isSubscribedMonthly ||
                                                      isSubscribedYearly) {
                                                    //!Navigate to Story Page for First index Without Ad
                                                    getSelectedStory(book.path,
                                                        goto: true);
                                                  } else if (book.locked ==
                                                      false) {
                                                    //!check if show interstitialad is true
                                                    if ((Platform.isAndroid &&
                                                            widget
                                                                    .configResponse
                                                                    .androidSettings
                                                                    .admobSettings
                                                                    .admobInterstitialAd
                                                                    ?.showInterstitial ==
                                                                true) ||
                                                        (Platform.isIOS &&
                                                            widget
                                                                    .configResponse
                                                                    .iosSettings
                                                                    .admobSettings
                                                                    .admobInterstitialAd
                                                                    ?.showInterstitial ==
                                                                true)) {
                                                      adController
                                                          .showInterstitialAd(
                                                              () async {
                                                        goToStoryPage(
                                                            book.path);
                                                      }, () {});
                                                    } else {
                                                      //!Interstitial ad show Set to False Navigate to Story Page
                                                      getSelectedStory(
                                                          book.path,
                                                          goto: true);
                                                    }
                                                  } else {
                                                    bool isWatched =
                                                        await BookPreferences
                                                            .getBookWatched(
                                                                book.title);
                                                    int openedCount =
                                                        await BookPreferences
                                                            .getBookOpenedCount(
                                                                book.title);

                                                    //!check if book finished it's session if so reset or lock it again

                                                    if (isWatched &&
                                                        openedCount >=
                                                            rewardedCountLimit) {
                                                      await BookPreferences
                                                          .resetBookData(
                                                              book.title);
                                                    }

                                                    //! For Locked Books
                                                    //!check if reward ad has been seen and if user has sessions left if so open story page

                                                    if (isWatched &&
                                                        openedCount <=
                                                            rewardedCountLimit) {
                                                      //!check if show interstitialad is true
                                                      if ((Platform.isAndroid &&
                                                              widget
                                                                      .configResponse
                                                                      .androidSettings
                                                                      .admobSettings
                                                                      .admobInterstitialAd
                                                                      ?.showInterstitial ==
                                                                  true) ||
                                                          (Platform.isIOS &&
                                                              widget
                                                                      .configResponse
                                                                      .iosSettings
                                                                      .admobSettings
                                                                      .admobInterstitialAd
                                                                      ?.showInterstitial ==
                                                                  true)) {
                                                        //!Check If Interstitial Ad is available
                                                        if (adController
                                                            .interstitialAdLoaded
                                                            .value) {
                                                          adController
                                                              .showInterstitialAd(
                                                                  () async {
                                                            //!Increment Count of Book Opened
                                                            await BookPreferences
                                                                .incrementBookOpened(
                                                                    book.title);

                                                            //!Navigate To Story Page
                                                            goToStoryPage(
                                                                book.path);
                                                          }, () async {
                                                            Get.snackbar(
                                                                '$isWatched    $openedCount    $rewardedCountLimit',
                                                                Strings
                                                                    .storyTryagain,
                                                                backgroundColor:
                                                                    Colors
                                                                        .orange);
                                                          });
                                                        } else {
                                                          //!try to load Interstitial Ad Again

                                                          //!try to show again
                                                          if (adController
                                                              .interstitialAdLoaded
                                                              .value) {
                                                            adController
                                                                .showInterstitialAd(
                                                                    () async {
                                                              //!Increment Count of Book Opened
                                                              await BookPreferences
                                                                  .incrementBookOpened(
                                                                      book.title);

                                                              //!Navigate To Story Page
                                                              goToStoryPage(
                                                                  book.path);
                                                            }, () {});
                                                          } else {
                                                            //!We tried to load and show interstial ad 2 times but got nothing so just open the story and Increment the book Opened Count
                                                            await BookPreferences
                                                                .incrementBookOpened(
                                                                    book.title);

                                                            //!Navigate to Story Page
                                                            goToStoryPage(
                                                                book.path);
                                                          }
                                                        }
                                                      } else {
                                                        //! show interstitial ad set to False
                                                        //!Navigate To Story Page
                                                        await BookPreferences
                                                            .incrementBookOpened(
                                                                book.title);
                                                        goToStoryPage(
                                                            book.path);
                                                      }
                                                    } else {
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
                                                        barrierDismissible:
                                                            false,
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
                                                            text: adsEnabled
                                                                ? Strings
                                                                    .watchAd
                                                                : null,
                                                            text2: "Subscribe",
                                                            functionCall:
                                                                adsEnabled
                                                                    ? () async {
                                                                        Navigator.pop(
                                                                            context);
                                                                        if (adController
                                                                            .rewardedAdLoaded
                                                                            .value) {
                                                                          if (audioController
                                                                              .isPlaying) {
                                                                            setState(() {
                                                                              musicForAd = true;
                                                                            });
                                                                            audioController.toggleAudio();
                                                                          }

                                                                          adController.showRewardedAd(
                                                                              //! onUserEarnedReward  Reward
                                                                              () async {
                                                                            if (musicForAd) {
                                                                              audioController.toggleAudio();
                                                                              setState(() {
                                                                                musicForAd = false;
                                                                              });
                                                                            }

                                                                            //!---! Chnage State of the book to Reward Ad watched and Book Opened

                                                                            await BookPreferences.setBookWatched(book.title,
                                                                                true);
                                                                            await BookPreferences.incrementBookOpened(book.title);

                                                                            //! Call setState to trigger a rebuild of the GridView item
                                                                            setState(() {});
                                                                          },
                                                                              //!onContentClosed   Reward
                                                                              () async {
                                                                            goToStoryPage(book.path);
                                                                          });
                                                                        } else {
                                                                          logger
                                                                              .e('false value for: ${adController.rewardedAdLoaded.value} \n');
                                                                          adController
                                                                              .loadRewardAd();
                                                                          //!check if show interstitialad is true
                                                                          if ((Platform.isAndroid && widget.configResponse.androidSettings.admobSettings.admobInterstitialAd?.showInterstitial == true) ||
                                                                              (Platform.isIOS && widget.configResponse.iosSettings.admobSettings.admobInterstitialAd?.showInterstitial == true)) {
                                                                            //!Check If Interstitial Ad is available
                                                                            if (adController.interstitialAdLoaded.value) {
                                                                              adController.showInterstitialAd(() async {
                                                                                //!---! Chnage State of the book to Reward Ad watched and Book Opened

                                                                                await BookPreferences.setBookWatched(book.title, true);
                                                                                await BookPreferences.incrementBookOpened(book.title);

                                                                                //! Call setState to trigger a rebuild of the GridView item
                                                                                setState(() {});
                                                                                goToStoryPage(book.path);
                                                                              }, () {});
                                                                            } else {
                                                                              //!try to load Interstitial Ad Again

                                                                              //!try to show again
                                                                              if (adController.interstitialAdLoaded.value) {
                                                                                adController.showInterstitialAd(() async {
                                                                                  //!---! Chnage State of the book to Reward Ad watched and Book Opened

                                                                                  await BookPreferences.setBookWatched(book.title, true);
                                                                                  await BookPreferences.incrementBookOpened(book.title);

                                                                                  //! Call setState to trigger a rebuild of the GridView item
                                                                                  setState(() {});
                                                                                  goToStoryPage(book.path);
                                                                                }, () {});
                                                                              } else {
                                                                                //! Both Reward ad and interstitial ad failed so show dialog
                                                                              }
                                                                            }
                                                                          } else {
                                                                            //! show interstitial ad set to False
                                                                            //!Navigate To Story Page
                                                                            goToStoryPage(book.path);
                                                                          }
                                                                        }
                                                                      }
                                                                    : () {},
                                                            secfunctionCall:
                                                                () {
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
                                                    }
                                                  }
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
                backgroundColor: Colors.white,
                child: GetBuilder<AudioController>(builder: (audioController) {
                  return IconButton(
                    icon: Icon(audioController.isPlaying
                        ? Icons.music_note_outlined
                        : Icons.music_off_outlined),
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
                    backgroundColor: Colors.white,
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
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      heroTag: 'About',
                      tooltip: 'About',
                      backgroundColor: buttonColor,
                      child: const Icon(Icons.privacy_tip_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                //!Settings FAB
                Visibility(
                  visible: _isMenuOpen,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
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
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      heroTag: 'Settings',
                      tooltip: 'Settings',
                      child: const Icon(Icons.settings),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                //!FAB
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: FloatingActionButton(
                    backgroundColor: buttonColor,
                    onPressed: () {
                      setState(() {
                        _isMenuOpen = !_isMenuOpen;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    //tooltip: 'Toggle',
                    child: _isMenuOpen
                        ? const Icon(Icons.close)
                        : const Icon(Icons.expand_less_outlined),
                  ),
                ),
              ],
            ),
            //         // showDialog(
            //         //   context: context,
            //         //   barrierDismissible: false,
            //         //   builder: (BuildContext context) {
            //         //     return AboutDialogBox(
            //         //       //title: 'Unlock Your Story',
            //         //       titleColor: Colors.orange,
            //         //       descriptions: widget.configResponse.aboutApp,
            //         //       secfunctionCall: () {
            //         //         //showRewardAd();
            //         //         Navigator.pop(context);
            //         //       },
            //         //     );
            //         //   },
            //         // );
            //       },
            //     )),
          ),

          //!Scroll to Top
          if (showScrollToTopButton)
            Positioned(
              bottom: 20.0,
              left: MediaQuery.of(context).size.height * 0.08,
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_upward_outlined),
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
        SubscriptionPages(
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

// class BookOpeningPageRoute extends PageRouteBuilder {
//   final Widget page;

//   BookOpeningPageRoute({required this.page})
//       : super(
//           transitionDuration: const Duration(seconds: 1),
//           pageBuilder: (
//             BuildContext context,
//             Animation<double> animation,
//             Animation<double> secondaryAnimation,
//           ) =>
//               page,
//           transitionsBuilder: (
//             BuildContext context,
//             Animation<double> animation,
//             Animation<double> secondaryAnimation,
//             Widget child,
//           ) {
//             var begin = Matrix4.identity()
//               ..setEntry(3, 2, 0.002)
//               ..rotateY(-0.5); // Adjust the angle if needed

//             var end = Matrix4.identity()
//               ..setEntry(3, 2, 0.002)
//               ..rotateY(0);

//             var tween = Matrix4Tween(begin: begin, end: end);

//             return AnimatedBuilder(
//               animation: animation,
//               builder: (context, child) {
//                 return Transform(
//                   transform: tween.evaluate(animation),
//                   alignment: Alignment.center,
//                   child: child,
//                 );
//               },
//               child: child,
//             );
//           },
//         );
// }
