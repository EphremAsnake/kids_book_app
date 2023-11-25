import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../model/booklistModel.dart';
import '../model/configModel.dart';
import '../services/apiEndpoints.dart';
import '../utils/adhelper.dart';
import '../widget/choice.dart';
import '../widget/dialog.dart';
import 'bookList.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Dio dio = Dio();
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  ConfigApiResponseModel? configResponses;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    //fetchData();
  }

  void saveToLocalStorage(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = json.encode(data); // Convert to JSON string
    await prefs.setString('booklist_response_data', jsonData);
  }

  Future<String> getFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('booklist_response_data');
    //print(storedData);
    return storedData ?? "";
  }

  Future<void> checkInternetConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _connectivityResult = connectivityResult;
    });

    String storedData = await getFromStorage();
    if (connectivityResult == ConnectivityResult.none && storedData == "") {
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ChoiceDialogBox(
              title: 'No internet connection',
              titleColor: const Color(0xffED1E54),
              descriptions:
                  'Please check your internet connection and try again.',
              text: 'OK',
              functionCall: () {
                Navigator.pop(context);
                checkInternetConnection();
              },
              closeicon: true,
              //img: 'assets/dialog_error.svg',
            );
          });
    } else if (connectivityResult == ConnectivityResult.none &&
        storedData != "") {
      //useLocalData();
    } else {
      await fetchConfigData().then((_) {
        fetchData();
      });
    }
  }

  void fetchData() async {
    try {
      Response response =
          await dio.get('${APIEndpoints.baseUrl}menu/book_list.json');

      // Map<String, dynamic> parsedJson = jsonDecode(response.data);

      if (response.statusCode == 200) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.data);

        //saveToLocalStorage(response.data);

        // ignore: use_build_context_synchronously
        if (configResponses == null) {
          await fetchConfigData();
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BookListPage(
                      booksList: apiResponse,
                      configResponse: configResponses!,
                    )),
          );
        } else {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BookListPage(
                      booksList: apiResponse,
                      configResponse: configResponses!,
                    )),
          );
        }
      } else {
        print('Something Went Wrong Try Again');
      }
    } catch (e) {
      print('Something Went Wrong $e');
      //useLocalData();
    }
  }

  //! get admob Ids
  Future fetchConfigData() async {
    try {
      Response response = await dio.get(APIEndpoints.configsUrl);

      // Map<String, dynamic> parsedJson = jsonDecode(response.data);

      if (response.statusCode == 200) {
        ConfigApiResponseModel configResponse =
            ConfigApiResponseModel.fromJson(response.data);

        setState(() {
          configResponses = configResponse;
        });
        //! Set the ad unit IDs in AdHelper
        AdHelper.setAdUnits(
          interstitialId: Platform.isAndroid
              ? configResponse.admobInterstitialAd?.android
              : configResponse.admobInterstitialAd?.ios,
          rewardedId: Platform.isAndroid
              ? configResponse.admobRewardedAd?.android
              : configResponse.admobRewardedAd?.ios,
        );

        //saveToLocalStorage(response.data);
      } else {
        debugPrint('Something Went Wrong Try Again');
      }
    } catch (e) {
      print('Something Went Wrong $e');
    }
  }

  // void useLocalData() async {
  //   String storedData = await getFromStorage();
  //   Map<String, dynamic> parsedData = json.decode(storedData);
  //   ApiResponse apiResponse = ApiResponse.fromJson(parsedData);

  //   // ignore: use_build_context_synchronously
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) => BookListPage(
  //               booksList: apiResponse,
  //             )),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //   statusBarColor: Colors.white, // Change this to your desired color
    // ));
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/book.json',
          fit: BoxFit.cover,
          width: MediaQuery.sizeOf(context).height * 0.5,
          height: MediaQuery.sizeOf(context).width * 0.25,
          repeat: true,
        ),
      ),
    );
  }
}
