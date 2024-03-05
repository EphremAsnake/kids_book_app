import 'dart:io';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:resize/resize.dart';
import 'package:starsview/starsview.dart';
import 'package:storyapp/utils/Constants/AllStrings.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/backgroundMusicAudioController.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../controller/subscriptionController.dart';
import '../../model/booklistModel.dart';
import '../../model/configModel.dart';
import '../../utils/Constants/colors.dart';
import '../../utils/Constants/dimention.dart';
import '../../widget/choice.dart';
import '../BookMenu/BookListMenu.dart';
import '../parentalgate/parentalgate.dart';
import 'status/subscriptionstatus.dart';

class SubscriptionPage extends StatefulWidget {
  final String monthly;
  final String yearly;
  final String termofuseUrl;
  final String privacyPolicyUrl;
  final String generalSubscriptionText;
  final Color backgroundcolor;
  final String monthlyProductId;
  final String yearlyProductId;
  final ApiResponse booksList;
  final ConfigApiResponseModel configResponse;

  const SubscriptionPage({
    super.key,
    required this.monthly,
    required this.yearly,
    required this.termofuseUrl,
    required this.privacyPolicyUrl,
    required this.generalSubscriptionText,
    required this.backgroundcolor,
    required this.monthlyProductId,
    required this.yearlyProductId,
    required this.booksList,
    required this.configResponse,
  });

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  late List<String> _productIds;
  bool gotproducts = false;
  List<ProductDetails> _products = [];
  SubscriptionController subscriptionController =
      Get.put(SubscriptionController());
  final SubscriptionStatus subscriptionStatus = Get.put(SubscriptionStatus());
  //!check Sub

  late AudioController audioController;

  @override
  void initState() {
    super.initState();
    audioController = Get.find<AudioController>();
    _productIds = [widget.monthlyProductId, widget.yearlyProductId];
    checkInternetConnection();
  }

  @override
  void dispose() {
    super.dispose();
    subscriptionController.hideProgress();
  }

  Future<void> checkInternetConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {});
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
                initStoreInfo();
                //checkInternetConnection();
              },
              closeicon: true,
            );
          });
    } else {
      initStoreInfo();
    }
  }

  Future<void> initStoreInfo() async {
    await _inAppPurchase.isAvailable();

    ProductDetailsResponse productDetailsResponse =
        await _inAppPurchase.queryProductDetails(_productIds.toSet());

    setState(() {
      _products = productDetailsResponse.productDetails;
      gotproducts = true;
    });
  }

  Color bColor = Colors.black.withOpacity(0.3);
  AudioController backgroundaudioController = Get.put(AudioController());

  Future<void> clearCachedFiles() async {
    DefaultCacheManager cacheManager = DefaultCacheManager();
    await cacheManager.emptyCache();
    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      isDismissible: true,
      titleText: const Text(
        'Success',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      ),
      maxWidth: 400,
      messageText: const Text(
        'Cache cleared',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(
            BookListPage(
              booksList: widget.booksList,
              configResponse: widget.configResponse,
            ),
            transition: Transition.fadeIn,
            duration: const Duration(seconds: 2));
        return false;
      },
      child: Scaffold(
          backgroundColor: widget.backgroundcolor,
          body: Obx(() {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primaryColor, AppColors.secondaryColor],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  //!Background Star Animation
                  const StarsView(
                    fps: 60,
                  ),

                  //!blury background
                  BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                      )),

                  _products.isNotEmpty
                      ? SizedBox(
                          height: MediaQuery.sizeOf(context).height,
                          child: NestedScrollView(
                            physics: const BouncingScrollPhysics(),
                            headerSliverBuilder: (BuildContext context,
                                bool innerBoxIsScrolled) {
                              return <Widget>[];
                            },
                            body: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Obx(() => Text(
                                        subscriptionStatus.isMonthly.value
                                            ? Strings
                                                .youareSubscribedtoMonthlypackage
                                            : subscriptionStatus.isYearly.value
                                                ? Strings
                                                    .youareSubscribedtoYearlypackage
                                                : widget
                                                    .generalSubscriptionText,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Customfont',
                                          fontSize: 9.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: _products.length,
                                          itemBuilder: ((context, index) {
                                            return SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.5,
                                              child: subTypeContainer(
                                                  context,
                                                  _products[index].price,
                                                  _products[index].id ==
                                                          widget
                                                              .monthlyProductId
                                                      ? '1 MONTH'
                                                      : '1 YEAR',
                                                  _products[index].id ==
                                                          widget
                                                              .monthlyProductId
                                                      ? widget.monthly
                                                      : widget.yearly,
                                                  index,
                                                  isYear: _products[index].id ==
                                                          widget
                                                              .monthlyProductId
                                                      ? null
                                                      : true),
                                            );
                                          })),
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Permission.getPermission(
                                            onClose: () {
                                              subscriptionController
                                                  .hideProgress();
                                            },
                                            context: context,
                                            onSuccess: () {
                                              debugPrint("True");
                                              InAppPurchase.instance
                                                  .restorePurchases();
                                            },
                                            onFail: () {
                                              debugPrint("false");
                                            },
                                            backgroundColor:
                                                AppColors.primaryColor,
                                          );
                                        },
                                        child: const Text(
                                          Strings.restorePurchase,
                                          style: TextStyle(
                                            fontFamily: 'Customfont',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          clearCachedFiles();
                                        },
                                        child: const Text(
                                          Strings.clearCache,
                                          style: TextStyle(
                                            fontFamily: 'Customfont',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Permission.getPermission(
                                            onClose: () {
                                              subscriptionController
                                                  .hideProgress();
                                            },
                                            context: context,
                                            onSuccess: () {
                                              debugPrint("True");
                                              _launchURL(widget.termofuseUrl);
                                            },
                                            onFail: () {
                                              debugPrint("false");
                                            },
                                            backgroundColor:
                                                AppColors.primaryColor,
                                          );
                                        },
                                        child: const Text(
                                          Strings.termsofUse,
                                          style: TextStyle(
                                            fontFamily: 'Customfont',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Permission.getPermission(
                                            onClose: () {
                                              subscriptionController
                                                  .hideProgress();
                                            },
                                            context: context,
                                            onSuccess: () {
                                              debugPrint("True");
                                              _launchURL(
                                                  widget.privacyPolicyUrl);
                                            },
                                            onFail: () {
                                              debugPrint("false");
                                            },
                                            backgroundColor:
                                                AppColors.primaryColor,
                                          );
                                        },
                                        child: const Text(
                                          Strings.privacyPolicy,
                                          style: TextStyle(
                                            fontFamily: 'Customfont',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),

                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Visibility(
                          visible: subscriptionController.isLoading.value,
                          child: Center(
                              child: CircularProgressIndicator(
                            color: Colors.white.withOpacity(0.5),
                          )))),

                  Positioned(
                    top: 20.0,
                    right: MediaQuery.of(context).size.height * 0.08,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.backgroundColor,
                      child: IconButton(
                        iconSize: IconSizes.medium,
                        icon: const Icon(Icons.home_outlined,
                            color: AppColors.iconColor),
                        onPressed: () {
                          if (audioController.isPlaying) {
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
                      ),
                    ),
                  ),
                ],
              ),
            );
          })),
    );
  }

  Center subTypeContainer(BuildContext context, String price,
      String leadingName, String perText, int index,
      {bool? isYear}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: () {
              subscriptionController.showProgress();
              Permission.getPermission(
                onClose: () {
                  subscriptionController.hideProgress();
                },
                context: context,
                onSuccess: () {
                  debugPrint("True");
                  late PurchaseParam purchaseParam;
                  if (Platform.isAndroid) {
                    purchaseParam = GooglePlayPurchaseParam(
                        productDetails: _products[index],
                        changeSubscriptionParam: null);
                  } else {
                    purchaseParam = PurchaseParam(
                      productDetails: _products[index],
                    );
                  }

                  InAppPurchase.instance.buyNonConsumable(
                    purchaseParam: purchaseParam,
                  );
                },
                onFail: () {
                  debugPrint("false");
                },
                backgroundColor: AppColors.primaryColor,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                height: 55,
                width: MediaQuery.sizeOf(context).width * 0.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFC66C40), Colors.transparent],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$price$perText',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Customfont',
                          fontSize: 8.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      if (isYear != null)
                        Container(
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 240, 193, 91),
                                borderRadius: BorderRadius.circular(5)),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3.0),
                              child: Text(Strings.save50),
                            )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // //! Function to open URLs
  Future<void> _launchURL(String _url) async {
    if (!await launchUrl(Uri.parse(_url))) {
      throw Exception('Could not launch $_url');
    }
  }
}
