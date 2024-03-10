import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';
import 'package:open_store/open_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starsview/starsview.dart';
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
import '../../controller/subscription.dart';
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
import 'custom/reveal.route.dart';

class BookListPage extends StatefulWidget {
  ApiResponse booksList;
  final ConfigApiResponseModel configResponse;
  final bool? fromlocal;
  final bool? isbackgroundsilent;
  BookListPage(
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

  Future<void> restorepurchase() async {
    await InAppPurchase.instance.restorePurchases();
  }

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final SubscriptionPriceController priceController =
      Get.put(SubscriptionPriceController());
  late List<String> _monthlyproductIds;
  late List<String> _yearlyproductIds;
  bool gotproducts = false;
  List<ProductDetails> _monthproducts = [];
  List<ProductDetails> _yearproducts = [];

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

    // //!
    // _monthlyproductIds = [
    //   Platform.isAndroid
    //       ? widget.configResponse.androidSettings.subscriptionSettings
    //           .monthSubscriptionProductID!
    //       : widget.configResponse.iosSettings.subscriptionSettings
    //           .monthSubscriptionProductID!,
    // ];
    // _yearlyproductIds = [
    //   Platform.isAndroid
    //       ? widget.configResponse.androidSettings.subscriptionSettings
    //           .yearSubscriptionProductID!
    //       : widget.configResponse.iosSettings.subscriptionSettings
    //           .yearSubscriptionProductID!
    // ];

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

    initcalls();
    //   Logger logger = Logger();
    //   if (priceController.yearlyPrice.value != '' ||
    //       priceController.monthlyPrice.value != '') {
    //     logger.e('init store called');
    //     initStoreInfo();
    //   } else {
    //     logger.e('else of');
    //   }
  }
  // //!
  // Future<void> initStoreInfo() async {
  //   await _inAppPurchase.isAvailable();

  //   ProductDetailsResponse monthproductDetailsResponse =
  //       await _inAppPurchase.queryProductDetails(_monthlyproductIds.toSet());

  //   setState(() {
  //     _monthproducts = monthproductDetailsResponse.productDetails;
  //     //gotproducts = true;
  //   });

  //   ProductDetailsResponse yearproductDetailsResponse =
  //       await _inAppPurchase.queryProductDetails(_yearlyproductIds.toSet());

  //   setState(() {
  //     _yearproducts = yearproductDetailsResponse.productDetails;
  //     gotproducts = true;
  //   });

  //   if (_yearproducts.isNotEmpty) {
  //     priceController.saveYearlyPrice(
  //       _yearproducts[0].price,
  //     );
  //   }
  //   if (_monthproducts.isNotEmpty) {
  //     priceController.saveMonthlyPrice(
  //       _monthproducts[0].price,
  //     );
  //   }
  // }

  void initcalls() {
    audioController = Get.put(AudioController());
    audioController.audioVolumeUp();
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
    return false;
  }

  void goToStoryPage(String folder) {
    if (folderName == folder) {
      audioController.audioVolumeDown();
      Navigator.pushReplacement(
        context,
        RevealRoute(
          page: BookPage(
            response: singlestoryPageResponse!,
            folder: folder,
            backgroundMusic: widget.booksList.backgroundMusic,
            booksList: widget.booksList,
            configResponse: widget.configResponse,
          ),
          maxRadius: 900,
          centerAlignment: Alignment.center,
        ),
      );
    } else {
      getSelectedStory(folder, goto: true);
    }
  }

  Future<String> getFromStorageStoryList(String folder) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('story_of_$folder');
    //print(storedData);
    return storedData ?? "";
  }

  void saveToLocalStorageStoryList(data, String folder) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = json.encode(data);

    //! Convert to JSON string
    await prefs.setString('story_of_$folder', jsonData);
  }

  Future<bool> arePageFilesCached(String imageUrl, String audioUrl) async {
    FileInfo? imageCachedFile =
        await DefaultCacheManager().getFileFromCache(imageUrl);
    FileInfo? audioCachedFile =
        await DefaultCacheManager().getFileFromCache(audioUrl);
    return imageCachedFile != null && audioCachedFile != null;
  }

  Future<bool> allFilesCached(
      StoryPageApiResponse response, String folder) async {
    for (int i = 0; i < response.pages.length; i++) {
      StoryPageModel page = response.pages[i];
      String imageUrl = '${APIEndpoints.baseUrl}/$folder/${page.image}';
      String audioUrl = '${APIEndpoints.baseUrl}/$folder/${page.audio}';

      if (!(await arePageFilesCached(imageUrl, audioUrl))) {
        //! Not Cached
        return false;
      }
    }
    //! All files are cached,
    return true;
  }

  Future<void> useFromLocal(String folder) async {
    String storedStoryList = await getFromStorageStoryList(folder);

    Map<String, dynamic> parsedBookListData = json.decode(storedStoryList);
    StoryPageApiResponse storyPageresponse =
        StoryPageApiResponse.fromJson(parsedBookListData);
    singlestoryPageResponse = storyPageresponse;
    folderName = folder;

    //!

    if (await allFilesCached(storyPageresponse, folder)) {
      audioController.audioVolumeDown();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        RevealRoute(
          page: BookPage(
            response: singlestoryPageResponse!,
            folder: folder,
            backgroundMusic: widget.booksList.backgroundMusic,
            booksList: widget.booksList,
            configResponse: widget.configResponse,
          ),
          maxRadius: 900,
          centerAlignment: Alignment.center,
        ),
      );
    } else {
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
              },
              closeicon: true,
            );
          });
    }
  }

  Future<void> getSelectedStory(String folder, {bool? goto}) async {
    setState(() {
      loadingStory = true;
    });
    String storedStoryList = await getFromStorageStoryList(folder);
    try {
      Response sResponse =
          await dio.get('${APIEndpoints.baseUrl}/$folder/book.json');
      if (sResponse.statusCode == 200) {
        setState(() {
          loadingStory = false;
        });
        StoryPageApiResponse storyPageresponse =
            StoryPageApiResponse.fromJson(sResponse.data);
        singlestoryPageResponse = storyPageresponse;
        folderName = folder;

        //!Save to Local or Caching
        saveToLocalStorageStoryList(sResponse.data, folder);

        if (goto != null) {
          audioController.audioVolumeDown();
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            RevealRoute(
              page: BookPage(
                response: singlestoryPageResponse!,
                folder: folder,
                backgroundMusic: widget.booksList.backgroundMusic,
                booksList: widget.booksList,
                configResponse: widget.configResponse,
              ),
              maxRadius: 900,
              centerAlignment: Alignment.center,
            ),
          );
        }
      } else {
        if (storedStoryList != "") {
          useFromLocal(folder);
        }

        setState(() {
          loadingStory = false;
        });

        // ignore: use_build_context_synchronously
        showDialogss(context);
      }
    } catch (e) {
      if (storedStoryList != "") {
        useFromLocal(folder);
      }
      setState(() {
        loadingStory = false;
      });
    }
  }

  bool _isMenuOpen = false;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionStatus>(builder: (subscriptionStatus) {
      return RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: onPulltoRefresh,
        child: Scaffold(
          backgroundColor: AppColors.primaryColor,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryColor, AppColors.secondaryColor],
              ),
            ),
            child: Stack(
              children: [
                const StarsView(
                  fps: 60,
                ),

                //!BookList GridView
                Padding(
                  padding: EdgeInsets.only(
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
                              top:
                                  widget.configResponse.houseAd!.show != null &&
                                          Platform.isAndroid
                                      ? widget.configResponse.androidSettings
                                              .houseAd!.show!
                                          ? 25.w
                                          : 20
                                      : widget.configResponse.iosSettings
                                              .houseAd!.show!
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

                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 500),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              onTap: () async {
                                                if (!loadingStory) {
                                                  final connectivityResult =
                                                      await (Connectivity()
                                                          .checkConnectivity());

                                                  if (connectivityResult ==
                                                      ConnectivityResult.none) {
                                                    String storedStoryList =
                                                        await getFromStorageStoryList(
                                                            book.path);
                                                    if (!book.locked ||
                                                        subscriptionStatus
                                                            .isMonthly.value ||
                                                        subscriptionStatus
                                                            .isYearly.value) {
                                                      if (storedStoryList !=
                                                          "") {
                                                        useFromLocal(book.path);
                                                      } else {
                                                        // ignore: use_build_context_synchronously
                                                        showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return ChoiceDialogBox(
                                                                title: Strings
                                                                    .noInternet,
                                                                titleColor:
                                                                    const Color(
                                                                        0xffED1E54),
                                                                descriptions:
                                                                    Strings
                                                                        .noInternetDescription,
                                                                text:
                                                                    Strings.ok,
                                                                functionCall:
                                                                    () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  //checkInternetConnection();
                                                                },
                                                                closeicon: true,
                                                              );
                                                            });
                                                      }
                                                    } else if (book.locked ==
                                                        true) {
                                                      // final isAndroid =
                                                      //     Platform.isAndroid;

                                                      // final unlockMessage = isAndroid
                                                      //     ? widget
                                                      //             .configResponse
                                                      //             .androidSettings
                                                      //             .unlockDialogText ??
                                                      //         ""
                                                      //     : widget
                                                      //             .configResponse
                                                      //             .iosSettings
                                                      //             .unlockDialogText ??
                                                      //         "";

                                                      // final subscriptionMessage = isAndroid
                                                      //     ? widget
                                                      //             .configResponse
                                                      //             .androidSettings
                                                      //             .subscriptionSettings
                                                      //             .generalSubscriptionText ??
                                                      //         ""
                                                      //     : widget
                                                      //             .configResponse
                                                      //             .iosSettings
                                                      //             .subscriptionSettings
                                                      //             .generalSubscriptionText ??
                                                      //         "";

                                                      openSubscriptionPage();
                                                      // ignore: use_build_context_synchronously
                                                      // showDialog(
                                                      //   context: context,
                                                      //   barrierDismissible:
                                                      //       false,
                                                      //   builder: (BuildContext
                                                      //       context) {
                                                      //     return CustomDialogBox(
                                                      //       title: Strings
                                                      //           .unloackStory,
                                                      //       titleColor:
                                                      //           Colors.orange,
                                                      //       descriptions: unlockMessage
                                                      //               .isNotEmpty
                                                      //           ? unlockMessage
                                                      //           : subscriptionMessage,
                                                      //       text: null,
                                                      //       text2: "Subscribe",
                                                      //       functionCall: () {},
                                                      //       secfunctionCall:
                                                      //           () {
                                                      //         Navigator.pop(
                                                      //             context);
                                                      //         if (Platform
                                                      //             .isAndroid) {
                                                      //           Permission
                                                      //               .getPermission(
                                                      //             context:
                                                      //                 context,
                                                      //             onSuccess:
                                                      //                 () {
                                                      //               debugPrint(
                                                      //                   "True");
                                                      //               openSubscriptionPage();
                                                      //             },
                                                      //             onFail: () {
                                                      //               debugPrint(
                                                      //                   "false");
                                                      //             },
                                                      //             backgroundColor:
                                                      //                 AppColors
                                                      //                     .primaryColor,
                                                      //           );
                                                      //           //: openSubscriptionPage();
                                                      //         } else if (Platform
                                                      //             .isIOS) {
                                                      //           Permission
                                                      //               .getPermission(
                                                      //             context:
                                                      //                 context,
                                                      //             onSuccess:
                                                      //                 () {
                                                      //               debugPrint(
                                                      //                   "True");
                                                      //               openSubscriptionPage();
                                                      //             },
                                                      //             onFail: () {
                                                      //               debugPrint(
                                                      //                   "false");
                                                      //             },
                                                      //             backgroundColor:
                                                      //                 AppColors
                                                      //                     .primaryColor,
                                                      //           );
                                                      //           //: openSubscriptionPage();
                                                      //         }
                                                      //       },
                                                      //     );
                                                      //   },
                                                      // );
                                                    }
                                                  } else {
                                                    getSelectedStory(book.path);
                                                    if (!book.locked ||
                                                        subscriptionStatus
                                                            .isMonthly.value ||
                                                        subscriptionStatus
                                                            .isYearly.value) {
                                                      //!Navigate to Story Page for First index Without Ad
                                                      getSelectedStory(
                                                          book.path,
                                                          goto: true);
                                                    } else if (book.locked ==
                                                        true) {
                                                      // final isAndroid =
                                                      //     Platform.isAndroid;

                                                      // final unlockMessage = isAndroid
                                                      //     ? widget
                                                      //             .configResponse
                                                      //             .androidSettings
                                                      //             .unlockDialogText ??
                                                      //         ""
                                                      //     : widget
                                                      //             .configResponse
                                                      //             .iosSettings
                                                      //             .unlockDialogText ??
                                                      //         "";

                                                      // final subscriptionMessage = isAndroid
                                                      //     ? widget
                                                      //             .configResponse
                                                      //             .androidSettings
                                                      //             .subscriptionSettings
                                                      //             .generalSubscriptionText ??
                                                      //         ""
                                                      //     : widget
                                                      //             .configResponse
                                                      //             .iosSettings
                                                      //             .subscriptionSettings
                                                      //             .generalSubscriptionText ??
                                                      //         "";

                                                      openSubscriptionPage();
                                                      // ignore: use_build_context_synchronously
                                                      // showDialog(
                                                      //   context: context,
                                                      //   barrierDismissible:
                                                      //       false,
                                                      //   builder: (BuildContext
                                                      //       context) {
                                                      //     return CustomDialogBox(
                                                      //       title: Strings
                                                      //           .unloackStory,
                                                      //       titleColor:
                                                      //           Colors.orange,
                                                      //       descriptions: unlockMessage
                                                      //               .isNotEmpty
                                                      //           ? unlockMessage
                                                      //           : subscriptionMessage,
                                                      //       text: null,
                                                      //       text2: "Subscribe",
                                                      //       functionCall: () {},
                                                      //       secfunctionCall:
                                                      //           () {
                                                      //         Navigator.pop(
                                                      //             context);
                                                      //         if (Platform
                                                      //             .isAndroid) {
                                                      //           Permission
                                                      //               .getPermission(
                                                      //             context:
                                                      //                 context,
                                                      //             onSuccess:
                                                      //                 () {
                                                      //               debugPrint(
                                                      //                   "True");
                                                      //               openSubscriptionPage();
                                                      //             },
                                                      //             onFail: () {
                                                      //               debugPrint(
                                                      //                   "false");
                                                      //             },
                                                      //             backgroundColor:
                                                      //                 AppColors
                                                      //                     .primaryColor,
                                                      //           );
                                                      //           //: openSubscriptionPage();
                                                      //         } else if (Platform
                                                      //             .isIOS) {
                                                      //           Permission
                                                      //               .getPermission(
                                                      //             context:
                                                      //                 context,
                                                      //             onSuccess:
                                                      //                 () {
                                                      //               debugPrint(
                                                      //                   "True");
                                                      //               openSubscriptionPage();
                                                      //             },
                                                      //             onFail: () {
                                                      //               debugPrint(
                                                      //                   "false");
                                                      //             },
                                                      //             backgroundColor:
                                                      //                 AppColors
                                                      //                     .primaryColor,
                                                      //           );
                                                      //           // : openSubscriptionPage();
                                                      //         }
                                                      //       },
                                                      //     );
                                                      //   },
                                                      // );
                                                    } else {}
                                                  }
                                                }
                                              },
                                              child: Obx(() => buildBookCard(
                                                  book,
                                                  subscriptionStatus
                                                      .isMonthly.value,
                                                  subscriptionStatus
                                                      .isYearly.value))),
                                        ),
                                      ),
                                    ),
                                  );
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
                              style: TextStyle(
                                  fontFamily: 'Customfont',
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold),
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
                      child: GetBuilder<AudioController>(
                          builder: (audioController) {
                        return IconButton(
                          iconSize: IconSizes.medium,
                          icon: Icon(
                            audioController.isPlaying
                                ? Icons.music_note_outlined
                                : Icons.music_off_outlined,
                            color: AppColors.iconColor,
                          ),
                          onPressed: () {
                            // debugPrint(
                            //     'month p: ${priceController.monthlyPrice}');
                            // debugPrint('year: ${priceController.yearlyPrice}');
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
                                    titleColor: AppColors.iconColor,
                                    descriptions: Platform.isAndroid
                                        ? widget.configResponse.androidSettings
                                            .aboutApp
                                        : widget.configResponse.iosSettings
                                            .aboutApp,
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
                                // Permission.getPermission(
                                //   context: context,
                                //   onSuccess: () {
                                //     openSubscriptionPage();
                                //   },
                                //   onFail: () {},
                                //   backgroundColor: AppColors.primaryColor,
                                // );
                                openSubscriptionPage();
                                //: openSubscriptionPage();
                              } else if (Platform.isIOS) {
                                openSubscriptionPage();
                                // Permission.getPermission(
                                //   context: context,
                                //   onSuccess: () {
                                //     openSubscriptionPage();
                                //   },
                                //   onFail: () {},
                                //   backgroundColor: AppColors.primaryColor,
                                // );
                                //: openSubscriptionPage();
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
                  if (widget.configResponse.androidSettings.houseAd!.show !=
                          null &&
                      widget.configResponse.androidSettings.houseAd!.show!)
                    Align(
                      alignment: Alignment.topCenter,
                      child: InkWell(
                        onTap: () {
                          bool? showparentalgate = Platform.isAndroid
                              ? widget
                                  .configResponse.androidSettings.parentalGate
                              : widget.configResponse.iosSettings.parentalGate;
                          if (showparentalgate ?? true) {
                            Permission.getPermission(
                              context: context,
                              onSuccess: () {
                                openUrlAndroid(widget.configResponse
                                    .androidSettings.houseAd!.urlId!);
                              },
                              onFail: () {},
                              backgroundColor: AppColors.primaryColor,
                            );
                          } else {
                            debugPrint("True");
                            openUrlAndroid(widget.configResponse.androidSettings
                                .houseAd!.urlId!);
                          }

                          // : openUrlAndroid(widget.configResponse
                          //     .androidSettings.houseAd!.urlId!);
                        },
                        child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.3,
                            height: 25.w,
                            decoration: BoxDecoration(
                                color: widget.configResponse.androidSettings
                                    .houseAd!.buttonColor!
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
                                  fontFamily: 'Customfont',
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
                          Permission.getPermission(
                            context: context,
                            onSuccess: () {
                              openAppStore(widget
                                  .configResponse.iosSettings.houseAd!.urlId!);
                            },
                            onFail: () {},
                            backgroundColor: AppColors.primaryColor,
                          );
                          // : openAppStore(widget
                          //     .configResponse.iosSettings.houseAd!.urlId!);
                        },
                        child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.3,
                            height: 25.w,
                            decoration: BoxDecoration(
                                color: widget.configResponse.iosSettings
                                    .houseAd!.buttonColor!
                                    .toColor(opacity: 0.95),
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12))),
                            child: Center(
                                child: Text(
                              widget.configResponse.iosSettings.houseAd!
                                  .buttonText!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Customfont',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8.sp,
                                  height: 1.2,
                                  color: widget.configResponse.iosSettings
                                      .houseAd!.buttonTextColor!
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
                          child: Center(
                            child: CircularProgressIndicator(
                                color: Colors.white.withOpacity(0.5)),
                          ),
                        ),
                      ))
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _launchURL(String _url) async {
    if (!await launchUrl(Uri.parse(_url))) {
      throw Exception('Could not launch $_url');
    }
  }

  void openUrlAndroid(String url) async {
    Uri uri = Uri.parse(url);

    if (uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https')) {
      //!The Url is a web link'
      _launchURL(url);
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
          backgroundcolor: AppColors.primaryColor,
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

  Future<void> cacheImages(String imageUrls) async {
    final cacheManager = DefaultCacheManager();

    await cacheManager.downloadFile(imageUrls);
  }

  Widget buildBookCard(
      BookList book, bool monthlysubStatus, bool yearlysubStatus) {
    cacheImages('${APIEndpoints.baseUrl}/${book.thumbnail}');
    return SizedBox(
      height: 150,
      child: Card(
        elevation: 2,
        color: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                fadeOutDuration: const Duration(milliseconds: 0),
                width: double.infinity,
                height: double.infinity,
                imageUrl: '${APIEndpoints.baseUrl}/${book.thumbnail}',
                placeholder: (context, url) =>
                    Container(color: Colors.transparent),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.transparent),
                fit: BoxFit.cover,
                cacheManager: DefaultCacheManager(),
              ),
            ),

            //! Overlay for the title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                // decoration: BoxDecoration(
                //     color: Colors.black.withOpacity(0.3),
                //     borderRadius: const BorderRadius.only(
                //         bottomLeft: Radius.circular(12),
                //         bottomRight: Radius.circular(12))),
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
                          fontFamily: 'Customfont',
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4.0,
                              offset: Offset(0.1, 0.1),
                            ),
                          ],
                          height: 1,
                          color: Colors.white,
                          fontSize: 6.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),

            if (book.locked && !(monthlysubStatus || yearlysubStatus))
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  width: double.infinity,
                  height: double.infinity,
                  child: const Icon(shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4.0,
                      offset: Offset(0.1, 0.1),
                    ),
                  ], Icons.lock, color: Colors.white, size: 30),
                ),
              )
          ],
        ),
      ),
    );
  }

  Future<void> onPulltoRefresh() async {
    try {
      Response response =
          await dio.get('${APIEndpoints.baseUrl}/menu/book_list.json');

      if (response.statusCode == 200) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.data);

        setState(() {
          widget.booksList = apiResponse;
        });
        debugPrint('Refreshed and list changed');
        saveToLocalStorageBookList(response.data);
      } else {}
    } catch (e) {
      debugPrint(
          'Something Went Wrong with main server trying with fallback server $e');
    }
  }

  void saveToLocalStorageBookList(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = json.encode(data);

    //! Convert to JSON string
    await prefs.setString('booklist_response_data', jsonData);
  }
}
