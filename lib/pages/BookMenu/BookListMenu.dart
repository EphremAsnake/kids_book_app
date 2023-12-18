import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_store/open_store.dart';
import 'package:storyapp/utils/Constants/AllStrings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:resize/resize.dart';
import 'package:storyapp/utils/colorConvet.dart';
import '../../controller/adcontroller.dart';
import '../../controller/backgroundMusicAudioController.dart';
import '../../model/booklistModel.dart';
import '../../model/configModel.dart';
import '../../model/storyPage.dart';
import '../../services/apiEndpoints.dart';
import '../../utils/adHelper.dart';
import '../../utils/adManager.dart';
import '../../widget/aboutdialog.dart';
import '../../widget/choice.dart';
import '../../widget/dialog.dart';
import '../StoryPage/StoryPage.dart';
import 'package:get/get.dart' hide Response;

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

  late AudioController audioController;
  //!ad
  late AdController adController;
  Dio dio = Dio();
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  List<StoryPageApiResponse?> storypageresponses = [];
  StoryPageApiResponse? singlestoryPageResponse;
  String folderName = '';

  bool musicForAd = false;
  Color buttonColor = Colors.white;
  bool loadingStory = false;
  late List<Future<bool>> lockStatusList;

  @override
  void initState() {
    super.initState();
    initcalls();
    fetchAdIds();
  }

  //!fetch ad UnitId
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
  }

  Future<void> getSelectedStory(String path) async {
    setState(() {
      loadingStory = true;
    });
    try {
      Response sResponse =
          await dio.get('${APIEndpoints.baseUrl}/$path/book.json');
      //logger.e('${APIEndpoints.baseUrl}/$folder/book.json');
      if (sResponse.statusCode == 200) {
        setState(() {
          loadingStory = false;
        });
        StoryPageApiResponse storyPageresponse =
            StoryPageApiResponse.fromJson(sResponse.data);
        singlestoryPageResponse = storyPageresponse;
        folderName = path;

        Get.offAll(
            BookPage(
              response: singlestoryPageResponse!,
              folder: path,
              backgroundMusic: widget.booksList.backgroundMusic,
              booksList: widget.booksList,
              configResponse: widget.configResponse,
            ),
            transition: Transition.circularReveal,
            duration: const Duration(seconds: 2));
        // // ignore: use_build_context_synchronously
        // Navigator.of(context).push(
        //   BookOpeningPageRoute(
        //     page: BookPage(
        //       response: singlestoryPageResponse!,
        //       folder: folder,
        //       backgroundMusic: widget.booksList.backgroundMusic,
        //       booksList: widget.booksList,
        //       configResponse: widget.configResponse,
        //     ),
        //   ),
        // );

        // ignore: use_build_context_synchronously
        //showDialogss(context);
      }
    } catch (e) {
      debugPrint('$e');

      setState(() {
        loadingStory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.booksList.backgroundColor.toColor(),
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
                                widget.configResponse.houseAd!.show!
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
                                  bool bookstatus = snapshot.data ?? false;
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
                                                            checkInternetConnection();
                                                          },
                                                          closeicon: true,
                                                        );
                                                      });
                                                } else {
                                                  //!Navigate to Selected Story Page
                                                  if (index == 0) {
                                                    getSelectedStory(book.path);
                                                  } else if (book.locked ==
                                                      false) {
                                                    //!to show interstitial ad
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
                                                        getSelectedStory(
                                                            book.path);
                                                      }, () {});
                                                    } else {
                                                      //!Interstitial ad show Set to False Navigate to Story Page
                                                      getSelectedStory(
                                                          book.path);
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

                                                      setState(() {});
                                                    }

                                                    //! For Locked Books
                                                    //!check if reward ad has been seen and if user has sessions left if so open story page

                                                    if (isWatched &&
                                                        openedCount <=
                                                            rewardedCountLimit) {
                                                      //!to show interstitial ad
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
                                                          await BookPreferences
                                                              .incrementBookOpened(
                                                                  book.title);
                                                          getSelectedStory(
                                                              book.path);
                                                        }, () {});
                                                      } else {
                                                        //!Interstitial ad show Set to False Navigate to Story Page
                                                        await BookPreferences
                                                            .incrementBookOpened(
                                                                book.title);
                                                        getSelectedStory(
                                                            book.path);
                                                      }
                                                    } else {
                                                      final isAndroid =
                                                          Platform.isAndroid;
                                                      final isIOS =
                                                          Platform.isIOS;

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

                                                      //! Display the appropriate message for in-app purchase based on the platform
                                                      if (isAndroid || isIOS) {
                                                        // ignore: use_build_context_synchronously
                                                        showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return CustomDialogBox(
                                                                  title:
                                                                      'Unlock Books',
                                                                  titleColor:
                                                                      Colors
                                                                          .orange,
                                                                  descriptions: unlockMessage
                                                                          .isNotEmpty
                                                                      ? unlockMessage
                                                                      : subscriptionMessage,
                                                                  text:
                                                                      'Purchase',
                                                                  text2: Strings
                                                                      .watchAd,
                                                                  functionCall:
                                                                      () async {},
                                                                  secfunctionCall:
                                                                      () async {
                                                                    Navigator.pop(
                                                                        context);

                                                                    //!to show interstitial ad
                                                                    // if ((Platform
                                                                    //             .isAndroid &&
                                                                    //         widget
                                                                    //                 .configResponse
                                                                    //                 .androidSettings
                                                                    //                 .admobSettings
                                                                    //                 .admobInterstitialAd
                                                                    //                 ?.showInterstitial ==
                                                                    //             true) ||
                                                                    //     (Platform
                                                                    //             .isIOS &&
                                                                    //         widget
                                                                    //                 .configResponse
                                                                    //                 .iosSettings
                                                                    //                 .admobSettings
                                                                    //                 .admobInterstitialAd
                                                                    //                 ?.showInterstitial ==
                                                                    //             true)) {
                                                                    //   adController
                                                                    //       .showInterstitialAd(
                                                                    //           () async {
                                                                    //     getSelectedStory(
                                                                    //         book.path);
                                                                    //   }, () {});
                                                                    // } else {
                                                                    //   //!Interstitial ad show Set to False Navigate to Story Page
                                                                    //   getSelectedStory(
                                                                    //       book.path);
                                                                    // }

                                                                    //!Reward Ad
                                                                    if (adController
                                                                        .rewardedAdLoaded
                                                                        .value) {
                                                                      adController.showRewardedAd(
                                                                          //! onUserEarnedReward  Reward
                                                                          () async {
                                                                        if (musicForAd) {
                                                                          audioController
                                                                              .toggleAudio();
                                                                          setState(
                                                                              () {
                                                                            musicForAd =
                                                                                false;
                                                                          });
                                                                        }

                                                                        //!---! Chnage State of the book to Reward Ad watched and Book Opened

                                                                        await BookPreferences.setBookWatched(
                                                                            book.title,
                                                                            true);
                                                                        await BookPreferences.incrementBookOpened(
                                                                            book.title);

                                                                        //! Call setState to trigger a rebuild of the GridView item
                                                                        setState(
                                                                            () {});
                                                                      },
                                                                          //!onContentClosed   Reward
                                                                          () async {
                                                                        getSelectedStory(
                                                                            book.path);
                                                                      });
                                                                    } else {
                                                                      //!reward ad failed to load so try interstitial

                                                                      // ignore: use_build_context_synchronously
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          barrierDismissible:
                                                                              false,
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            return ChoiceDialogBox(
                                                                              title: Strings.oops,
                                                                              titleColor: Colors.orange,
                                                                              descriptions: Strings.storyTryagain,
                                                                              text: Strings.ok,
                                                                              functionCall: () {
                                                                                Navigator.pop(context);
                                                                                adController.loadRewardAd();
                                                                              },
                                                                              closeicon: true,
                                                                            );
                                                                          });

                                                                      // //!check interstitial ad show true or not
                                                                      // if ((Platform.isAndroid &&
                                                                      //         widget.configResponse.androidSettings.admobSettings.admobInterstitialAd?.showInterstitial ==
                                                                      //             true) ||
                                                                      //     (Platform.isIOS &&
                                                                      //         widget.configResponse.iosSettings.admobSettings.admobInterstitialAd?.showInterstitial ==
                                                                      //             true)) {
                                                                      //   adController
                                                                      //       .showInterstitialAd(
                                                                      //           () async {
                                                                      //     getSelectedStory(
                                                                      //         book.path);
                                                                      //   }, () {});
                                                                      // } else {
                                                                      //   //!Interstitial ad show Set to False Navigate to Story Page
                                                                      //   getSelectedStory(
                                                                      //       book.path);
                                                                      // }
                                                                    }
                                                                  });
                                                            });
                                                      }
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
                radius: MediaQuery.of(context).size.height * 0.06,
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

          //!About
          Positioned(
            bottom: 20.0,
            right: MediaQuery.of(context).size.height * 0.08,
            child: CircleAvatar(
                radius: MediaQuery.of(context).size.height * 0.06,
                backgroundColor: buttonColor,
                child: IconButton(
                  icon: const Icon(Icons.privacy_tip_outlined),
                  onPressed: () {
                    setState(() {
                      buttonColor = Colors.blue;
                    });

                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {
                        buttonColor = Colors.white;
                      });
                    });
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AboutDialogBox(
                          //title: 'Unlock Your Story',
                          titleColor: Colors.orange,
                          descriptions: widget.configResponse.aboutApp,
                          secfunctionCall: () {
                            //showRewardAd();
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                )),
          ),

          //!Scroll to Top
          if (showScrollToTopButton)
            Positioned(
              bottom: 20.0,
              left: MediaQuery.of(context).size.height * 0.08,
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.height * 0.06,
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
                    openUrlAndroid(
                        widget.configResponse.androidSettings.houseAd!.urlId!);
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
                    openUrlAndroid(
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

class BookOpeningPageRoute extends PageRouteBuilder {
  final Widget page;

  BookOpeningPageRoute({required this.page})
      : super(
          transitionDuration: const Duration(seconds: 1),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            var begin = Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(-0.5); // Adjust the angle if needed

            var end = Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(0);

            var tween = Matrix4Tween(begin: begin, end: end);

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform(
                  transform: tween.evaluate(animation),
                  alignment: Alignment.center,
                  child: child,
                );
              },
              child: child,
            );
          },
        );
}
