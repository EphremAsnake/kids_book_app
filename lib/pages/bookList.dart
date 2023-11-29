import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:resize/resize.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storyapp/utils/colorConvet.dart';
import 'package:transparent_image/transparent_image.dart';
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
  const BookListPage(
      {Key? key, required this.booksList, required this.configResponse})
      : super(key: key);

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final ScrollController _scrollController = ScrollController();

  late AudioController audioController;
  InterstitialAd? _interstitialAd;
  late List<Future<int>> adCounts;

  //bool isPlaying = false;

  Dio dio = Dio();

  List<StoryPageApiResponse?> storypageresponses = [];

  bool musicForAd = false;
  Color buttonColor = Colors.white;

  @override
  void initState() {
    super.initState();

    loadRewarded();
    _loadInterstitialAd();

    audioController = Get.put(AudioController());
    audioController.startAudio(widget.booksList.backgroundMusic);
    for (int i = 0; i < widget.booksList.books.length; i++) {
      fetchDataForBookPage(i);
    }
    adCounts = List<Future<int>>.generate(
      widget.booksList.books.length,
      (index) => getCount(widget.booksList.books[index].title),
    );

    _scrollController.addListener(() {
      setState(() {
        showScrollToTopButton = _scrollController.offset > 0;
      });
    });
  }

  RewardedAd? rewardedAd;
  bool isRewardedAdLoaded = false;

  void loadRewarded() {
    RewardedAd.load(
      adUnitId: AdHelper.getRewardedAdUnitId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint("Ad Loaded");
          setState(() {
            rewardedAd = ad;
            isRewardedAdLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          if (_interstitialAd == null) {
            showDialogs(context);
          }
        },
      ),
    );
  }

  Future<void> _loadInterstitialAd() async {
    InterstitialAd.load(
      adUnitId: AdHelper.getInterstitalAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                _interstitialAd = null;
              });
              _loadInterstitialAd();
            },
          );
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  Future<void> _showInterstitialAd() async {
    if (_interstitialAd == null) {
      await _loadInterstitialAd();
    }

    if (_interstitialAd != null) {
      await _interstitialAd?.show();
    }
  }

  bool showScrollToTopButton = false;
  void showDialogs(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ChoiceDialogBox(
            title: 'Ad Loading Error',
            titleColor: const Color(0xffED1E54),
            descriptions: 'Oops! We couldn\'t load the ad. Please try again.',
            text: 'OK',
            functionCall: () {
              Navigator.pop(context);
            },
            closeicon: true,
            //img: 'assets/dialog_error.svg',
          );
        });
  }
  // // Play or stop audio based on current state
  // void toggleAudio() async {
  //   // print('${APIEndpoints().listurl}${widget.booksList.backgroundMusic}');
  //   if (isPlaying) {
  //     await _audioPlayer.pause();
  //   } else {
  //     await _audioPlayer.play(UrlSource(
  //         '${APIEndpoints().listurl}${widget.booksList.backgroundMusic}'));
  //   }
  //   setState(() {
  //     isPlaying = !isPlaying;
  //   });
  // }

  @override
  void dispose() {
    //_audioPlayer.dispose();

    // _rewardedAd?.dispose();
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.paused ||
  //       state == AppLifecycleState.inactive) {
  //     //! Pause audio when the app is paused or in the background
  //     //_audioPlayer.pause();
  //   } else if (state == AppLifecycleState.resumed) {
  //     //! Resume audio if needed when the app is resumed
  //     if (isPlaying) {
  //       //_audioPlayer.resume();
  //     }
  //   }
  // }
  Future<int> getCount(String bookTitle) async {
    int adShownCount = await AdManager.getAdShownCount(bookTitle);
    return adShownCount;
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
                title: 'Something Went Wrong',
                titleColor: const Color(0xffED1E54),
                descriptions: 'Something went wrong please try again.',
                text: 'OK',
                functionCall: () {
                  Navigator.pop(context);
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
          Padding(
            padding: EdgeInsets.only(
              top: 20.0,
              left: MediaQuery.of(context).size.height * 0.25,
              right: MediaQuery.of(context).size.height * 0.25,
            ),
            child: AnimationLimiter(
              child: GridView.builder(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.3),
                physics: const BouncingScrollPhysics(),
                controller: _scrollController,
                itemCount: widget.booksList.books.length,
                itemBuilder: (BuildContext context, int index) {
                  BookList book = widget.booksList.books[index];
                  Future<int> adCountFuture = getCount(book.title);
                  int rewardedCountLimit =
                      widget.configResponse.admobRewardedAd!.rewardedCount ?? 3;
                  //int adShownCount = 0;
                  return FutureBuilder<int>(
                      future: adCounts[index],
                      builder: (context, snapshot) {
                        int adShownCount = snapshot.data ?? 0;
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: InkWell(
                                  onTap: () async {
                                    if (index == 0) {
                                      navigateToNextPage(index);
                                    } else {
                                      adShownCount =
                                          await AdManager.getAdShownCount(
                                              book.title);
                                      if (adShownCount >= rewardedCountLimit) {
                                        await _showInterstitialAd();
                                        navigateToNextPage(index);
                                      } else {
                                        // ignore: use_build_context_synchronously
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return ChoiceDialogBox(
                                              title: 'Unlock Your Story',
                                              titleColor: Colors.orange,
                                              descriptions:
                                                  'Watch a short ad to unlock this story for 3 sessions',
                                              text: 'Watch Ad',
                                              functionCall: () async {
                                                //showRewardAd();
                                                Navigator.pop(context);
                                                if (isRewardedAdLoaded) {
                                                  if (audioController
                                                      .isPlaying) {
                                                    setState(() {
                                                      musicForAd = true;
                                                    });
                                                    audioController
                                                        .toggleAudio();
                                                  }
                                                  rewardedAd!.show(
                                                    onUserEarnedReward:
                                                        (adWithoutView,
                                                            reward) async {
                                                      if (musicForAd) {
                                                        audioController
                                                            .toggleAudio();
                                                        setState(() {
                                                          musicForAd = false;
                                                        });
                                                      }
                                                      rewardedAd = null;
                                                      loadRewarded();
                                                      await AdManager
                                                          .incrementAdShownCount(
                                                              book.title);

                                                      //! Chnage the state of the book if reward ad shown equals rewardedCountLimit
                                                      int adScount =
                                                          await AdManager
                                                              .getAdShownCount(
                                                                  book.title);
                                                      if (adScount >=
                                                          rewardedCountLimit) {
                                                        book.status =
                                                            "unlocked";
                                                      }

                                                      //! Call setState to trigger a rebuild of the GridView item
                                                      setState(() {});
                                                      navigateToNextPage(index);
                                                    },
                                                  );
                                                } else if (_interstitialAd !=
                                                    null) {
                                                  await _showInterstitialAd();
                                                  navigateToNextPage(index);
                                                } else {
                                                  showDialogs(context);
                                                }
                                              },
                                              secfunctionCall: () {
                                                //showRewardAd();
                                                Navigator.pop(context);
                                              },
                                            );
                                          },
                                        );
                                      }
                                    }
                                  },
                                  child: buildBookCard(book, adShownCount)),
                            ),
                          ),
                        );
                      });
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 30,
                  crossAxisCount: 3,
                ),
              ),
            ),
          ),
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
          if (widget.configResponse.houseAd!.show != null &&
              widget.configResponse.houseAd!.show!)
            Align(
              alignment: Alignment.topCenter,
              child: Positioned(
                top: 0.0,
                //left: 0,
                //right: 0,
                child: InkWell(
                  onTap: () {
                    if (widget.configResponse.houseAd!.typeApp!) {
                      if (Platform.isAndroid) {
                        openUrl(widget.configResponse.houseAd!.androidUrl!);
                      } else {
                        openUrl(widget.configResponse.houseAd!.iosUrl!);
                      }
                    }
                  },
                  child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      height: 25.w,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12))),
                      child: Center(
                          child: Text(
                        widget.configResponse.houseAd!.buttonText!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 8.sp),
                      ))),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void openUrl(String url) async {
    // final String appPackageName =
    //     'com.example.dagi';

    // final String url =
    //     'https://play.google.com/store/apps/details?id=$appPackageName';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch Url.';
    }
  }

  Widget buildBookCard(BookList book, int adShownCount) {
    int rewardedCountLimit =
        widget.configResponse.admobRewardedAd!.rewardedCount ?? 3;
    return SizedBox(
      height: 150,
      child: Card(
        elevation: 2,
        color: Colors.white,
        child: Stack(
          children: [
            // Placeholder with shimmer effect
            const ShimmerEffect(),
            // FadeInImage for loading the network image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image:
                    '${APIEndpoints.baseUrl}/${book.thumbnail}', // Provide the URL from your book object
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
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

            if (book.status == "locked" && adShownCount < rewardedCountLimit)
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

// Shimmer Effect Widget for Placeholder
class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.grey[300],
        width: double.infinity,
        height: double.infinity,
        child: Shimmer.fromColors(
          loop: 5,
          direction: ShimmerDirection.ltr,
          enabled: true,
          baseColor: Colors.white,
          highlightColor: Colors.grey[100]!,
          child: const SizedBox(
            width: double.infinity,
            height: double.infinity,
          ),
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
