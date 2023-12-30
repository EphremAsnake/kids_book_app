import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:logger/logger.dart';
import 'package:resize/resize.dart';
import 'package:storyapp/utils/colorConvet.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/backgroundMusicAudioController.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:badges/badges.dart' as badges;
import '../../controller/subscriptionController.dart';
import '../../model/booklistModel.dart';
import '../../model/configModel.dart';
import '../BookMenu/BookListMenu.dart';
import 'status/subscriptionstatus.dart';

class SubscriptionPage extends StatefulWidget {
  final String monthly;
  final String yearly;
  final String termofuseUrl;
  final String privacyPolicyUrl;
  final String generalSubscriptionText;
  final String backgroundcolor;
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

  // final List<String> _productIds = <String>[
  //   'month_subscription',
  //   'yearly_subscription',
  // ];
  Future<void> loadSubscriptionStatus() async {
    final Map<String, bool> subscriptionStatus =
        await SubscriptionStatus.getSubscriptionStatus();
    setState(() {
      isSubscribedMonthly = subscriptionStatus[monthlySubscriptionKey] ?? false;
      isSubscribedYearly = subscriptionStatus[yearlySubscriptionKey] ?? false;
    });
  }

  late List<String> _productIds;
  bool _isAvailable = false;
  String? _notice;
  bool gotproducts = false;
  List<ProductDetails> _products = [];
  int _selectedValue = 1;
  SubscriptionController subscriptionController =
      Get.put(SubscriptionController());

  //!check Sub
  bool isSubscribedMonthly = false;
  bool isSubscribedYearly = false;
  @override
  void initState() {
    super.initState();
    _productIds = [widget.monthlyProductId, widget.yearlyProductId];
    loadSubscriptionStatus();
    initStoreInfo();
  }

  @override
  void dispose() {
    super.dispose();
    subscriptionController.hideProgress();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    setState(() {
      _isAvailable = isAvailable;
    });

    if (!_isAvailable) {
      setState(() {
        _notice = 'no upgrade at this time';
      });

      return;
    }

    setState(() {
      _notice = 'there is connection';
    });

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
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      isDismissible: true,
      titleText: const Text(
        'Success',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
      maxWidth: 400,
      messageText: const Text(
        'Cache cleared',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(12);
    final double containerHeight = MediaQuery.of(context).size.height * 0.3;
    final double containerWidth = MediaQuery.of(context).size.width * 0.2;

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
          backgroundColor: widget.backgroundcolor.toColor(),
          body: Obx(() {
            // isSubscribedMonthly =
            //     subscriptionController.isUserSubscribedMonthly;
            // isSubscribedYearly = subscriptionController.isUserSubscribedYearly;

            return Stack(
              alignment: Alignment.center,
              children: [
                // //!Background Image
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
                BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    )),
                _products.isNotEmpty
                    ? SizedBox(
                        height: MediaQuery.sizeOf(context).height,
                        child: NestedScrollView(
                          physics: const BouncingScrollPhysics(),
                          headerSliverBuilder:
                              (BuildContext context, bool innerBoxIsScrolled) {
                            return <Widget>[
                              // SliverAppBar or other sliver widgets can be placed here
                              // if you need an app bar or similar content
                            ];
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

                                Text(
                                  isSubscribedMonthly
                                      ? 'You are Subscribed to monthly package'
                                      : isSubscribedYearly
                                          ? 'You are Subscribed to yearly package'
                                          : widget.generalSubscriptionText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                // Text(
                                //   isSubscribedMonthly
                                //       ? 'You are Subscribed to monthly package'
                                //       : isSubscribedYearly
                                //           ? 'You are Subscribed to yearly package'
                                //           : 'You are not Subscribed',
                                //   textAlign: TextAlign.center,
                                //   style: TextStyle(
                                //     fontSize: 10.sp,
                                //     color: Colors.white,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),

                                // if (_notice != null)
                                //   Text(
                                //     '$_notice ${_products.length}',
                                //     textAlign: TextAlign.center,
                                //     style: TextStyle(
                                //       fontSize: 10.sp,
                                //       color: Colors.white,
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //   ),
                                const SizedBox(height: 20.0),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   crossAxisAlignment: CrossAxisAlignment.center,
                                //   children: [
                                //     ClipRRect(
                                //       borderRadius: borderRadius,
                                //       child: Material(
                                //         borderRadius: borderRadius,
                                //         color: Colors.transparent,
                                //         child: InkWell(
                                //           onTap: () async {
                                //             final PurchaseParam monthlyPurchaseParam =
                                //                 PurchaseParam(
                                //                     productDetails: _products[0]);
                                //             InAppPurchase.instance.buyNonConsumable(
                                //                 purchaseParam: monthlyPurchaseParam);
                                //           },
                                //           child: Container(
                                //             height: containerHeight,
                                //             width: containerWidth,
                                //             decoration: BoxDecoration(
                                //               borderRadius: borderRadius,
                                //               color: bColor,
                                //             ),
                                //             child: Center(
                                //                 child: Text(
                                //                     '${_products[0].price}${widget.monthly}',
                                //                     textAlign: TextAlign.center,
                                //                     style: TextStyle(
                                //                         color: Colors.white,
                                //                         fontSize: 9.sp,
                                //                         fontWeight:
                                //                             FontWeight.bold))),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //     const SizedBox(width: 10.0),
                                //     ClipRRect(
                                //       borderRadius: borderRadius,
                                //       child: Material(
                                //         borderRadius: borderRadius,
                                //         color: Colors.transparent,
                                //         child: InkWell(
                                //           onTap: () {
                                //             final PurchaseParam yearlyPurchaseParam =
                                //                 PurchaseParam(
                                //                     productDetails: _products[1]);
                                //             InAppPurchase.instance.buyNonConsumable(
                                //                 purchaseParam: yearlyPurchaseParam);
                                //           },
                                //           child: Container(
                                //             height: containerHeight,
                                //             width: containerWidth,
                                //             decoration: BoxDecoration(
                                //               borderRadius: borderRadius,
                                //               color: bColor,
                                //             ),
                                //             child: Center(
                                //                 child: Text(
                                //                     '${_products[1].price}${widget.yearly}',
                                //                     textAlign: TextAlign.center,
                                //                     style: TextStyle(
                                //                         color: Colors.white,
                                //                         fontSize: 9.sp,
                                //                         fontWeight:
                                //                             FontWeight.bold))),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        subscriptionController.showProgress();
                                        late PurchaseParam monthlyPurchaseParam;
                                        if (Platform.isAndroid) {
                                          monthlyPurchaseParam =
                                              GooglePlayPurchaseParam(
                                                  productDetails: _products[0],
                                                  changeSubscriptionParam:
                                                      null);
                                        } else {
                                          monthlyPurchaseParam = PurchaseParam(
                                            productDetails: _products[0],
                                          );
                                        }

                                        InAppPurchase.instance.buyNonConsumable(
                                          purchaseParam: monthlyPurchaseParam,
                                        );
                                      },
                                      child: Container(
                                        height: 55,
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.5,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFFD2894E),
                                              Color(0xFFC66C40)
                                            ],
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                '1 MONTH',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  // fontSize: 9.sp,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                _products.isNotEmpty
                                                    ? '${_products[0].price}${widget.monthly}'
                                                    : '\$10.0/month',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  // fontSize: 9.sp,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20.0),
                                    InkWell(
                                      onTap: () {
                                        subscriptionController.showProgress();
                                        late PurchaseParam yearlyPurchaseParam;

                                        if (Platform.isAndroid) {
                                          yearlyPurchaseParam =
                                              GooglePlayPurchaseParam(
                                                  productDetails: _products[1],
                                                  changeSubscriptionParam:
                                                      null);
                                        } else {
                                          yearlyPurchaseParam = PurchaseParam(
                                            productDetails: _products[1],
                                          );
                                        }

                                        InAppPurchase.instance.buyNonConsumable(
                                          purchaseParam: yearlyPurchaseParam,
                                        );
                                      },
                                      child: Container(
                                        height: 55,
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.5,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFFD2894E),
                                              Color(0xFFC66C40)
                                            ],
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    '1 YEAR',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      // fontSize: 9.sp,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Container(
                                                      decoration: BoxDecoration(
                                                          color: const Color
                                                              .fromARGB(255,
                                                              240, 193, 91),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: const Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    3.0),
                                                        child: Text('Save 50%'),
                                                      )),
                                                ],
                                              ),
                                              Text(
                                                _products.isNotEmpty
                                                    ? '${_products[1].price}${widget.yearly}'
                                                    : '\$20.0/year',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  // fontSize: 9.sp,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Column(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   crossAxisAlignment: CrossAxisAlignment.center,
                                //   children: [
                                //     ListView.builder(
                                //         shrinkWrap: true,
                                //         physics:
                                //             const NeverScrollableScrollPhysics(),
                                //         itemCount: _products.length,
                                //         itemBuilder: ((context, index) {
                                //           String text = index == 0
                                //               ? widget.monthly
                                //               : widget.yearly;
                                //           return Center(
                                //             child: ListTile(
                                //               title: Text(
                                //                 '${_products[index].price} $text',
                                //                 style: TextStyle(
                                //                   fontSize: 10.sp,
                                //                   color: Colors.white,
                                //                   fontWeight: FontWeight.bold,
                                //                 ),
                                //               ),
                                //               leading: Transform.scale(
                                //                 scale: 2,
                                //                 child: MSHCheckbox(
                                //                   value:
                                //                       index == _selectedValue,
                                //                   colorConfig: MSHColorConfig
                                //                       .fromCheckedUncheckedDisabled(
                                //                     checkedColor: Colors.blue,
                                //                   ),
                                //                   style:
                                //                       MSHCheckboxStyle.stroke,
                                //                   onChanged: (value) {
                                //                     setState(() {
                                //                       _selectedValue = index;
                                //                     });
                                //                   },
                                //                   // activeColor: Colors
                                //                   //     .green, // Change the color as needed
                                //                 ),
                                //               ),
                                //             ),
                                //           );
                                //         })),
                                //     const SizedBox(height: 20.0),
                                //     ElevatedButton(
                                //       onPressed: () {
                                //         // Perform purchase based on the selected value (_selectedValue)
                                //         if (_selectedValue == 0) {
                                //           late PurchaseParam
                                //               monthlyPurchaseParam;
                                //           if (Platform.isAndroid) {
                                //             monthlyPurchaseParam =
                                //                 GooglePlayPurchaseParam(
                                //                     productDetails:
                                //                         _products[0],
                                //                     changeSubscriptionParam:
                                //                         null);
                                //           } else {
                                //             monthlyPurchaseParam =
                                //                 PurchaseParam(
                                //               productDetails: _products[0],
                                //             );
                                //           }

                                //           InAppPurchase.instance
                                //               .buyNonConsumable(
                                //             purchaseParam: monthlyPurchaseParam,
                                //           );
                                //         } else if (_selectedValue == 1) {
                                //           late PurchaseParam
                                //               yearlyPurchaseParam;

                                //           if (Platform.isAndroid) {
                                //             yearlyPurchaseParam =
                                //                 GooglePlayPurchaseParam(
                                //                     productDetails:
                                //                         _products[1],
                                //                     changeSubscriptionParam:
                                //                         null);
                                //           } else {
                                //             yearlyPurchaseParam = PurchaseParam(
                                //               productDetails: _products[1],
                                //             );
                                //           }

                                //           InAppPurchase.instance
                                //               .buyNonConsumable(
                                //             purchaseParam: yearlyPurchaseParam,
                                //           );
                                //         }
                                //       },
                                //       child: Text('Purchase'),
                                //     ),
                                //   ],
                                // ),

                                const SizedBox(height: 20.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        InAppPurchase.instance
                                            .restorePurchases();
                                      },
                                      child: const Text(
                                        'Restore Purchase',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        clearCachedFiles();
                                      },
                                      child: const Text(
                                        'Clear Saved Stories',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                //const SizedBox(height: 10.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  //crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        _launchURL(widget.termofuseUrl);
                                      },
                                      child: const Text(
                                        'Terms of Use',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _launchURL(widget.privacyPolicyUrl);
                                      },
                                      child: const Text(
                                        'Privacy Policy',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                // Text(_products[0].description),
                                // Text(_products[1].price),

                                // ListView.builder(
                                //     shrinkWrap: true,
                                //     physics:
                                //         const NeverScrollableScrollPhysics(),
                                //     itemCount: _products.length,
                                //     itemBuilder: ((context, index) {
                                //       return ListTile(
                                //         title:
                                //             Text(_products[index].description),
                                //         trailing: Text(_products[index].price),
                                //       );
                                //     })),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),

                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Visibility(
                        visible: subscriptionController.isLoading.value,
                        child:
                            const Center(child: CircularProgressIndicator()))),
                // Positioned(
                //   bottom: 20,
                //   left: 0,
                //   right: 0,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     //crossAxisAlignment: CrossAxisAlignment.end,
                //     children: [
                //       TextButton(
                //         onPressed: () {
                //           _launchURL(widget.termofuseUrl);
                //         },
                //         child: const Text(
                //           'Terms of Use',
                //           style: TextStyle(color: Colors.white),
                //         ),
                //       ),
                //       TextButton(
                //         onPressed: () {
                //           _launchURL(widget.privacyPolicyUrl);
                //         },
                //         child: const Text(
                //           'Privacy Policy',
                //           style: TextStyle(color: Colors.white),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                Positioned(
                  top: 20.0,
                  right: MediaQuery.of(context).size.height * 0.08,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.home_outlined, color: Colors.blue),
                      onPressed: () {
                        Get.offAll(
                            BookListPage(
                              booksList: widget.booksList,
                              configResponse: widget.configResponse,
                            ),
                            transition: Transition.fadeIn,
                            duration: const Duration(seconds: 2));
                      },
                    ),
                  ),
                ),
              ],
            );
          })),
    );
  }

  // Function to open URLs
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
