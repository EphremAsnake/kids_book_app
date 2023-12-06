import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:open_store/open_store.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:resize/resize.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storyapp/utils/colorConvet.dart';
import 'package:transparent_image/transparent_image.dart';
import '../controller/adController.dart';
import '../controller/backgroundMusicAudioController.dart';
import '../model/booklistModel.dart';
import '../model/configModel.dart';
import '../model/storyPage.dart';
import '../services/apiEndpoints.dart';
import '../utils/adhelper.dart';
import '../utils/admanager.dart';
import '../widget/about.dart';
import '../widget/choice.dart';
import '../widget/dialog.dart';
import 'books/book.dart';
import '../backup/books.dart';
import 'package:get/get.dart' hide Response;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'books/choices/choice.dart';

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
  // InterstitialAd? _interstitialAd;
  late List<Future<bool>> lockStatusList;

  //bool isPlaying = false;

  Dio dio = Dio();
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  List<StoryPageApiResponse?> storypageresponses = [];

  bool musicForAd = false;
  Color buttonColor = Colors.white;
  Logger logger = Logger();
  //!ad
  late AdController adController;
  @override
  void initState() {
    super.initState();
    print(widget.booksList.backgroundColor.toColor());
    if (widget.fromlocal == null) {
      // loadRewarded();
      // _loadInterstitialAd();
    }
    initcalls();
    fetchAdIds();
  }

  //!usage
  Future<void> fetchAdIds() async {
    //! Simulating async fetching of ad IDs
    await Future.delayed(const Duration(seconds: 1));

    String? rewardedAdId = AdHelper.getRewardedAdUnitId();
    String? interstitialAdId = AdHelper.getInterstitalAdUnitId();

    //! Initialize AdController with fetched ad IDs
    adController = Get.put(AdController(
      rewardedAdUnitId: rewardedAdId,
      interstitialAdUnitId: interstitialAdId,
    ));

    adController.loadInterstitialAdAfterError();
    adController.loadRewardedAdAfterError();
  }

  void initcalls() {
    for (int i = 0; i < widget.booksList.books.length; i++) {
      fetchDataForBookPage(i);
    }

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
              title: 'Oops! No Internet!',
              titleColor: const Color(0xffED1E54),
              descriptions:
                  'It seems we lost our magical connection! 🌟📶\nCheck your internet and try again.',
              text: 'OK',
              functionCall: () {
                Navigator.pop(context);
                checkInternetConnection();
              },
              closeicon: true,
            );
          });
    } else {
      // loadRewarded();
      // _loadInterstitialAd();
      initcalls();
    }
  }

  // RewardedAd? rewardedAd;
  // bool isRewardedAdLoaded = false;

  // void loadRewarded() {
  //   if (rewardedAd != null) {
  //   } else {
  //     RewardedAd.load(
  //       adUnitId: AdHelper.getRewardedAdUnitId(),
  //       request: const AdRequest(),
  //       rewardedAdLoadCallback: RewardedAdLoadCallback(
  //         onAdLoaded: (ad) {
  //           debugPrint("Ad Loaded");
  //           setState(() {
  //             rewardedAd = ad;
  //             isRewardedAdLoaded = true;
  //           });
  //         },
  //         onAdFailedToLoad: (error) {
  //           if (_interstitialAd == null) {
  //             showDialogs(context);
  //           }
  //         },
  //       ),
  //     );
  //   }
  // }

  // Future<void> _loadInterstitialAd() async {
  //   if (_interstitialAd != null) {
  //   } else {
  //     InterstitialAd.load(
  //       adUnitId: AdHelper.getInterstitalAdUnitId(),
  //       request: const AdRequest(),
  //       adLoadCallback: InterstitialAdLoadCallback(
  //         onAdLoaded: (ad) {
  //           ad.fullScreenContentCallback = FullScreenContentCallback(
  //             onAdDismissedFullScreenContent: (ad) {
  //               setState(() {
  //                 _interstitialAd = null;
  //               });
  //               _loadInterstitialAd();
  //             },
  //           );
  //           _interstitialAd = ad;
  //         },
  //         onAdFailedToLoad: (err) {
  //           print('Failed to load an interstitial ad: ${err.message}');
  //         },
  //       ),
  //     );
  //   }
  // }

  // Future<void> _showInterstitialAd() async {
  //   if (_interstitialAd == null) {
  //     await _loadInterstitialAd();
  //   }

  //   if (_interstitialAd != null) {
  //     await _interstitialAd?.show();
  //   }
  // }

  bool showScrollToTopButton = false;
  void showDialogss(BuildContext context) {
    checkInternetConnection();
    if (_connectivityResult != ConnectivityResult.none) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ChoiceDialogBox(
              title: 'Oops!',
              titleColor: const Color(0xffED1E54),
              descriptions: 'We couldn\'t load the fun ad. Let\'s try again!',
              text: 'OK',
              functionCall: () {
                adController.loadInterstitialAdAfterError();
                adController.loadRewardedAdAfterError();

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

  Future<bool> getLockStatus(String bookTitle) async {
    bool isWatched = await BookPreferences.getBookWatched(bookTitle);
    int openedCount = await BookPreferences.getBookOpenedCount(bookTitle);
    int rewardedCountLimit =
        widget.configResponse.admobRewardedAd!.rewardedCount ?? 3;
    // if (widget.configResponse.admobRewardedAd?.rewardedCount != null &&
    //     rewardedCountLimit > 1) {
    //   rewardedCountLimit =
    //       widget.configResponse.admobRewardedAd!.rewardedCount! - 1;
    // }
    if (isWatched && openedCount <= rewardedCountLimit) {
      return true;
    } else {
      return false;
    }
    //int bookWatchedCount = await NewAdManager.getBookWatchedCount(bookTitle);
  }

  Future<void> fetchDataForBookPage(int index) async {
    if (index >= 0 && index < widget.booksList.books.length) {
      try {
        Response sResponse =
            await dio.get('${APIEndpoints.booksUrl}$index/book.json');

        if (sResponse.statusCode == 200) {
          StoryPageApiResponse storyPageresponse =
              StoryPageApiResponse.fromJson(sResponse.data);

          if (index >= storypageresponses.length) {
            storypageresponses.addAll(List.generate(
                index + 1 - storypageresponses.length, (_) => null));
          }
          storypageresponses[index] = storyPageresponse;
        } else {
          print('Something Went Wrong Try Again');
        }
      } catch (e) {
        //! Handle errors if any
      }
    }
  }

  void navigateToNextPage(int index) {
    if (index >= 0 &&
        index < storypageresponses.length &&
        storypageresponses[index] != null) {
      //! Check if the response for the selected index exists
      // showCupertinoModalPopup(context: context, builder:
      //             (context) => SecondScreen()
      //         );

      Navigator.of(context).push(
        BookOpeningPageRoute(
          page: BookPage(
            response: storypageresponses[index]!,
            indexValue: index,
            backgroundMusic: widget.booksList.backgroundMusic,
            booksList: widget.booksList,
            configResponse: widget.configResponse,
          ),
        ),
      );
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => BooksPage(
      //       response: storypageresponses[index]!,
      //       indexValue: index,
      //       backgroundMusic: widget.booksList.backgroundMusic,
      //     ),
      //   ),
      // );
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ChoiceDialogBox(
                title: 'Oops!',
                titleColor: const Color(0xffED1E54),
                descriptions: 'Looks like something got mixed up in the storybook adventure. Let’s try again!',
                text: 'OK',
                functionCall: () {
                  if (index >= 0 &&
                      index < storypageresponses.length &&
                      storypageresponses[index] != null) {
                    Navigator.pop(context);
                  } else {
                    for (int i = 0; i < widget.booksList.books.length; i++) {
                      fetchDataForBookPage(i);
                    }
                  }
                },
                closeicon: true
                //img: 'assets/dialog_error.svg',
                );
          });
      //! Handle scenarios where the response for the selected index is not available
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.booksList.backgroundColor.toColor(),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),

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
                                  int rewardedCountLimit = widget.configResponse
                                          .admobRewardedAd!.rewardedCount ??
                                      3;
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 500),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: InkWell(
                                            onTap: () async {
                                              final connectivityResult =
                                                  await (Connectivity()
                                                      .checkConnectivity());

                                              if (connectivityResult ==
                                                  ConnectivityResult.none) {
                                                // ignore: use_build_context_synchronously
                                                showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (BuildContext context) {
                                                      return ChoiceDialogBox(
                                                        title:
                                                            'Oops! No Internet!',
                                                        titleColor: const Color(
                                                            0xffED1E54),
                                                        descriptions:
                                                            'It seems we lost our magical connection! 🌟📶\nCheck your internet and try again.',
                                                        text: 'OK',
                                                        functionCall: () {
                                                          Navigator.pop(
                                                              context);
                                                          checkInternetConnection();
                                                        },
                                                        closeicon: true,
                                                      );
                                                    });
                                              } else {
                                                if (index == 0) {
                                                  //!Navigate to Story Page for First index Without Ad
                                                  navigateToNextPage(index);
                                                } else if (book.status ==
                                                    'unlocked') {
                                                  //!check if show interstitialad is true
                                                  if (widget
                                                      .configResponse
                                                      .admobInterstitialAd!
                                                      .show!) {
                                                    adController
                                                        .showInterstitialAd(
                                                            () async {
                                                      adController
                                                          .loadInterstitialAdAfterError();
                                                      adController
                                                          .loadRewardedAdAfterError();
                                                      navigateToNextPage(index);
                                                    });
                                                    //await _showInterstitialAd();
                                                  } else {
                                                    //!Interstitial ad show Set to False Navigate to Story Page
                                                    navigateToNextPage(index);
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
                                                    if (widget
                                                        .configResponse
                                                        .admobInterstitialAd!
                                                        .show!) {
                                                      //!Check If Interstitial Ad is available
                                                      if (adController
                                                          .interstitialAdLoaded
                                                          .value) {
                                                        adController
                                                            .showInterstitialAd(
                                                                () async {
                                                          adController
                                                              .loadInterstitialAdAfterError();
                                                          adController
                                                              .loadRewardedAdAfterError();

                                                          //!Increment Count of Book Opened
                                                          await BookPreferences
                                                              .incrementBookOpened(
                                                                  book.title);

                                                          //!Navigate To Story Page
                                                          navigateToNextPage(
                                                              index);
                                                        });
                                                      } else {
                                                        //!try to load Interstitial Ad Again
                                                        await adController
                                                            .loadInterstitialAdAfterError();

                                                        //!try to show again
                                                        if (adController
                                                            .interstitialAdLoaded
                                                            .value) {
                                                          adController
                                                              .showInterstitialAd(
                                                                  () async {
                                                            adController
                                                                .loadInterstitialAdAfterError();
                                                            adController
                                                                .loadRewardedAdAfterError();

                                                            //!Increment Count of Book Opened
                                                            await BookPreferences
                                                                .incrementBookOpened(
                                                                    book.title);

                                                            //!Navigate To Story Page
                                                            navigateToNextPage(
                                                                index);
                                                          });
                                                        } else {
                                                          //!We tried to load and show interstial ad 2 times but got nothing so just open the story and Increment the book Opened Count
                                                          await BookPreferences
                                                              .incrementBookOpened(
                                                                  book.title);
                                                          //!Navigate to Story Page
                                                          navigateToNextPage(
                                                              index);
                                                        }
                                                      }
                                                    } else {
                                                      //! show interstitial ad set to False
                                                      //!Navigate To Story Page
                                                      navigateToNextPage(index);
                                                    }

                                                    //!
                                                    // ScaffoldMessenger.of(context)
                                                    //     .showSnackBar(SnackBar(
                                                    //   content: Text(
                                                    //       '${book.title}  $openedCount   $isWatched'),
                                                    // ));
                                                    //!
                                                  } else {
                                                    //!show reward ad if available for locked books
                                                    adController
                                                        .loadInterstitialAdAfterError();
                                                    adController
                                                        .loadRewardedAdAfterError();
                                                    // ignore: use_build_context_synchronously
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (BuildContext
                                                          context) {
                                                        return ChoiceDialogBox(
                                                          title:
                                                              'Unlock Your Story',
                                                          titleColor:
                                                              Colors.orange,
                                                          descriptions:
                                                              'Watch a short ad to unlock this story for $rewardedCountLimit sessions',
                                                          text: 'Watch Ad',
                                                          functionCall:
                                                              () async {
                                                            //showRewardAd();
                                                            // //!log
                                                            // logger.e('watch ad pressed');
                                                            Navigator.pop(
                                                                context);
                                                            if (adController
                                                                .rewardedAdLoaded
                                                                .value) {
                                                              if (audioController
                                                                  .isPlaying) {
                                                                setState(() {
                                                                  musicForAd =
                                                                      true;
                                                                });
                                                                audioController
                                                                    .toggleAudio();
                                                              }
                                                              // //!log
                                                              // logger.e(
                                                              //     'adController.rewardedAdLoaded.value: ${adController.rewardedAdLoaded.value} \n');
                                                              // adController
                                                              //     .showRewardedAd();
                                                              adController
                                                                  .showRewardedAd(
                                                                      () async {
                                                                if (musicForAd) {
                                                                  audioController
                                                                      .toggleAudio();
                                                                  setState(() {
                                                                    musicForAd =
                                                                        false;
                                                                  });
                                                                }

                                                                //!---! Chnage State of the book to Reward Ad watched and Book Opened

                                                                await BookPreferences
                                                                    .setBookWatched(
                                                                        book.title,
                                                                        true);
                                                                await BookPreferences
                                                                    .incrementBookOpened(
                                                                        book.title);
                                                                adController
                                                                    .loadInterstitialAdAfterError();
                                                                adController
                                                                    .loadRewardedAdAfterError();
                                                                //! Call setState to trigger a rebuild of the GridView item
                                                                setState(() {});
                                                              }, () async {
                                                                adController
                                                                    .loadInterstitialAdAfterError();
                                                                adController
                                                                    .loadRewardedAdAfterError();
                                                                navigateToNextPage(
                                                                    index);
                                                              });
                                                              // rewardedAd!
                                                              //         .fullScreenContentCallback =
                                                              //     FullScreenContentCallback(
                                                              //   onAdFailedToShowFullScreenContent:
                                                              //       (ad, error) {
                                                              //     ad.dispose();
                                                              //     loadRewarded();
                                                              //   },
                                                              //   onAdDismissedFullScreenContent:
                                                              //       (ad) {
                                                              //     ad.dispose();
                                                              //     loadRewarded();
                                                              //     navigateToNextPage(
                                                              //         index);
                                                              //  },
                                                              //);
                                                            }
                                                            //  else if (_interstitialAd !=
                                                            //     null) {
                                                            //   await _showInterstitialAd();
                                                            //   await BookPreferences
                                                            //       .incrementBookOpened(
                                                            //           book.title);
                                                            //   navigateToNextPage(index);
                                                            else {
                                                              logger.e(
                                                                  'false value for: ${adController.rewardedAdLoaded.value} \n');
                                                              showDialogss(
                                                                  context);
                                                            }
                                                          },
                                                          secfunctionCall: () {
                                                            //showRewardAd();
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        );
                                                      },
                                                    );
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
                  if (widget.booksList.bookListEndText != null)
                    SliverToBoxAdapter(
                      child: Center(
                          child: Text(
                        widget.booksList.bookListEndText!,
                        maxLines: 1,
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
          if (widget.configResponse.houseAd!.show != null &&
              widget.configResponse.houseAd!.show!)
            Align(
              alignment: Alignment.topCenter,
              child: InkWell(
                onTap: () {
                  //if (widget.configResponse.houseAd!.typeApp!) {
                  if (Platform.isAndroid) {
                    openUrlAndroid(widget.configResponse.houseAd!.androidUrl!);
                  } else {
                    openAppStore(widget.configResponse.houseAd!.iosUrl!);
                  }
                  //  }
                },
                child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.3,
                    height: 25.w,
                    decoration: BoxDecoration(
                        color: widget.configResponse.houseAd!.buttonColor!
                            .toColor(opacity: 0.95),
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12))),
                    child: Center(
                        child: Text(
                      widget.configResponse.houseAd!.buttonText!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 8.sp,
                          height: 1.2,
                          color: widget.configResponse.houseAd!.buttonTextColor!
                              .toColor()),
                    ))),
              ),
            ),
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

      final String appPackageName = url;

      final String playstoreurl = 'market://details?id=$appPackageName';

      if (await canLaunch(playstoreurl)) {
        await launch(playstoreurl);
      } else {
        final String playstoreurlweb =
            'https://play.google.com/store/apps/details?id=$appPackageName';
        await launch(playstoreurlweb);
        //throw 'Could not launch Url.';
      }
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
        //androidAppBundleId: 'com.google.android.googlequicksearchbox',
      );
    }

    // final String appStoreUrl = 'itms-apps://itunes.apple.com/app/id$appId';

    // if (await canLaunch(appStoreUrl)) {
    //   await launch(appStoreUrl);
    // } else {
    //   throw 'Could not launch App Store';
    // }
  }

  Widget buildBookCard(BookList book, bool bookState) {
    // int rewardedCountLimit =
    //     widget.configResponse.admobRewardedAd!.rewardedCount ?? 3;
    return SizedBox(
      height: 150,
      child: Card(
        elevation: 2,
        color: Colors.transparent,
        child: Stack(
          children: [
            // Placeholder with shimmer effect
            //const ShimmerEffect(),
            // FadeInImage for loading the network image
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
              // FadeInImage.memoryNetwork(
              //   placeholder: kTransparentImage,
              //   image:
              //       '${APIEndpoints.baseUrl}/${book.thumbnail}', // Provide the URL from your book object
              //   fit: BoxFit.cover,
              //   width: double.infinity,
              //   height: double.infinity,
              // ),
            ),
            // Overlay for the title
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

            if (book.status == "locked" && !bookState)
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

// // Shimmer Effect Widget for Placeholder
// class ShimmerEffect extends StatelessWidget {
//   const ShimmerEffect({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         color: Colors.grey[300],
//         width: double.infinity,
//         height: double.infinity,
//         child: Shimmer.fromColors(
//           loop: 5,
//           direction: ShimmerDirection.ltr,
//           enabled: true,
//           baseColor: Colors.white,
//           highlightColor: Colors.grey[100]!,
//           child: const SizedBox(
//             width: double.infinity,
//             height: double.infinity,
//           ),
//         ),
//       ),
//     );
//   }
// }

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
