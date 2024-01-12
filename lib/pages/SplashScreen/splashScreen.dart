import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../../model/booklistModel.dart';
import '../../model/configModel.dart';
import '../../utils/Constants/AllStrings.dart';
import '../../services/apiEndpoints.dart';
import '../../widget/choice.dart';
import '../BookMenu/BookListMenu.dart';
import '../SubscriptionPage/iap_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Dio dio = Dio();
  ConfigApiResponseModel? configResponses;
  late AnimationController animationController;
  late Animation<double> animation;
  late AnimationController _controller;
  late Animation<double> _animation;
  // startTime() async {
  //   var duration = const Duration(seconds: 5);

  //   return Timer(duration, checkFirstSeenAndNavigate);
  // }
  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    inimethods();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  void inimethods() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut);

    animation.addListener(() => setState(() {}));
    animationController.forward();

    //startTime();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 10800),
        vsync: this,
        value: 0,
        lowerBound: 0,
        upperBound: 1);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();
  }

  void saveToLocalStorageBookList(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = json.encode(data);

    //! Convert to JSON string
    await prefs.setString('booklist_response_data', jsonData);
  }

  Future<String> getFromStorageBookList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('booklist_response_data');
    //print(storedData);
    return storedData ?? "";
  }

  void saveToLocalStorageConfig(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = json.encode(data); // Convert to JSON string
    await prefs.setString('config_data', jsonData);
  }

  Future<String> getFromStorageConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('config_data');
    return storedData ?? "";
  }

  Future<void> checkInternetConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {});

    String storedBookList = await getFromStorageBookList();
    String storedConfigData = await getFromStorageBookList();
    if (connectivityResult == ConnectivityResult.none && storedBookList == "") {
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
    } else if (connectivityResult == ConnectivityResult.none &&
        storedBookList != "" &&
        storedConfigData != "") {
      useLocalDataBoth();
    } else {
      await fetchConfigData().then((_) {
        fetchData();
      });
    }
  }

  void fetchData() async {
    //!Config Data
    String storedConfigData = await getFromStorageConfig();
    Map<String, dynamic> parsedConfigData = json.decode(storedConfigData);
    ConfigApiResponseModel storedConfigResponse =
        ConfigApiResponseModel.fromJson(parsedConfigData);

    final String fallbackUrl = Platform.isAndroid
        ? storedConfigResponse.androidSettings.fallbackServerUrl ?? ''
        : storedConfigResponse.iosSettings.fallbackServerUrl ?? '';
    try {
      Response response =
          await dio.get('${APIEndpoints.baseUrl}/menu/book_list.json');

      if (response.statusCode == 200) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.data);

        saveToLocalStorageBookList(response.data);

        // ignore: use_build_context_synchronously
        if (configResponses == null) {
          await fetchConfigData();

          checkAvailabiltyFunction(configResponses!);
          Get.offAll(
              BookListPage(
                booksList: apiResponse,
                configResponse: configResponses!,
              ),
              transition: Transition.fade,
              duration: const Duration(seconds: 2));
        } else {
          checkAvailabiltyFunction(configResponses!);
          Get.offAll(
              BookListPage(
                booksList: apiResponse,
                configResponse: configResponses!,
              ),
              transition: Transition.fade,
              duration: const Duration(seconds: 2));
        }
      } else {
        debugPrint(
            'Something Went Wrong with main server Trying with fallback server');
        await tryFallbackUrl(fallbackUrl);
      }
    } catch (e) {
      debugPrint(
          'Something Went Wrong with main server trying with fallback server $e');
      await tryFallbackUrl(fallbackUrl);
    }
  }

  Future<void> tryFallbackUrl(String fallbackUrl) async {
    String storedBookList = await getFromStorageBookList();
    String storedConfigData = await getFromStorageBookList();
    try {
      Response response = await dio.get('$fallbackUrl/menu/book_list.json');

      if (response.statusCode == 200) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.data);

        saveToLocalStorageBookList(response.data);

        // ignore: use_build_context_synchronously
        if (configResponses == null) {
          await fetchConfigData();

          checkAvailabiltyFunction(configResponses!);
          Get.offAll(
              BookListPage(
                booksList: apiResponse,
                configResponse: configResponses!,
              ),
              transition: Transition.fade,
              duration: const Duration(seconds: 2));
        } else {
          checkAvailabiltyFunction(configResponses!);
          Get.offAll(
              BookListPage(
                booksList: apiResponse,
                configResponse: configResponses!,
              ),
              transition: Transition.fade,
              duration: const Duration(seconds: 2));
        }
      } else {
        debugPrint('Something Went Wrong Try using local storage');
        if (storedBookList != "" && storedConfigData != "") {
          useLocalDataBoth();
        }
      }
    } catch (e) {
      debugPrint('Something Went Wrong $e');
    }
  }

  //! get admob Ids
  Future fetchConfigData() async {
    try {
      Response response = await dio.get(APIEndpoints.configsUrl);

      if (response.statusCode == 200) {
        ConfigApiResponseModel configResponse =
            ConfigApiResponseModel.fromJson(response.data);

        //!Saving To Local Config Data
        saveToLocalStorageConfig(response.data);

        setState(() {
          configResponses = configResponse;
        });

        //! Set the ad unit IDs in AdHelper

        debugPrint('Something Went Wrong Try Again');
      }
    } catch (e) {
      debugPrint('Something Went Wrong $e');
    }
  }

  Future<void> checkAvailabiltyFunction(
      ConfigApiResponseModel consfigresponse) async {
    await InAppPurchase.instance.restorePurchases();
    //!Check Subscription Availability
    IAPService(
            monthlyProductId: Platform.isAndroid
                ? consfigresponse.androidSettings.subscriptionSettings
                    .monthSubscriptionProductID!
                : consfigresponse.iosSettings.subscriptionSettings
                    .monthSubscriptionProductID!,
            yearlyProductId: Platform.isAndroid
                ? consfigresponse.androidSettings.subscriptionSettings
                    .yearSubscriptionProductID!
                : consfigresponse.iosSettings.subscriptionSettings
                    .yearSubscriptionProductID!)
        .checkSubscriptionAvailabilty();
  }

  void useLocalDataBoth() async {
    //!BookList
    String storedBookList = await getFromStorageBookList();
    Map<String, dynamic> parsedBookListData = json.decode(storedBookList);
    ApiResponse storedBookListResponse =
        ApiResponse.fromJson(parsedBookListData);

    //!Config Data
    String storedConfigData = await getFromStorageConfig();
    Map<String, dynamic> parsedConfigData = json.decode(storedConfigData);
    ConfigApiResponseModel storedConfigResponse =
        ConfigApiResponseModel.fromJson(parsedConfigData);

    //! Set the ad unit IDs in AdHelper

    checkAvailabiltyFunction(storedConfigResponse);

    Get.offAll(
        BookListPage(
            booksList: storedBookListResponse,
            configResponse: storedConfigResponse,
            fromlocal: true),
        transition: Transition.zoom,
        duration: const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff4bebfa),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 5,),
          Center(
            child: Container(
              width: animation.value * 450,
              height: animation.value * 150,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/appicon.png"),
                    fit: BoxFit.contain),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(bottom:10.0),
            child: SizedBox(height: 10,width: 10, child: CircularProgressIndicator()),
          ),
          // Center(
          //   child: Container(
          //     width: animation.value * 450,
          //     height: animation.value * 100,
          //     child: Center(
          //       child: Lottie.asset(
          //         'assets/book.json',
          //         fit: BoxFit.cover,
          //         repeat: true,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
