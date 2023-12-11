import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../../model/booklistModel.dart';
import '../../model/configModel.dart';
import '../../utils/Constants/AllStrings.dart';
import '../../services/apiEndpoints.dart';
import '../../widget/choice.dart';
import '../BookMenu/BookListMenu.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Dio dio = Dio();
  ConfigApiResponseModel? configResponses;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
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
    try {
      Response response =
          await dio.get('${APIEndpoints.baseUrl}/menu/book_list.json');

      if (response.statusCode == 200) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.data);

        saveToLocalStorageBookList(response.data);

        // ignore: use_build_context_synchronously
        if (configResponses == null) {
          await fetchConfigData();

          Get.offAll(
              BookListPage(
                booksList: apiResponse,
                configResponse: configResponses!,
              ),
              transition: Transition.fade,
              duration: const Duration(seconds: 2));
        } else {
          Get.offAll(
              BookListPage(
                booksList: apiResponse,
                configResponse: configResponses!,
              ),
              transition: Transition.fade,
              duration: const Duration(seconds: 2));
        }
      } else {
        debugPrint('Something Went Wrong Try Again');
      }
    } catch (e) {
      debugPrint('Something Went Wrong $e');
    }
  }

  //! get Config Ids
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

       

        debugPrint('Something Went Wrong Try Again');
      }
    } catch (e) {
      debugPrint('Something Went Wrong $e');
    }
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
      body: Center(
        child: Lottie.asset(
          'assets/book.json',
          fit: BoxFit.cover,
          repeat: true,
        ),
      ),
    );
  }
}
