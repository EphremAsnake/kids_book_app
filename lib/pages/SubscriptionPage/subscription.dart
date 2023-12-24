import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resize/resize.dart';
import 'package:storyapp/utils/colorConvet.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/backgroundMusicAudioController.dart';
import '../../model/booklistModel.dart';
import '../../model/configModel.dart';
import '../BookMenu/BookListMenu.dart';

class SubscriptionPage extends StatefulWidget {
  final String monthly;
  final String yearly;
  final String termofuseUrl;
  final String privacyPolicyUrl;
  final String generalSubscriptionText;
  final String backgroundcolor;

  const SubscriptionPage({
    super.key,
    required this.monthly,
    required this.yearly,
    required this.termofuseUrl,
    required this.privacyPolicyUrl,
    required this.generalSubscriptionText,
    required this.backgroundcolor,
  });

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  Color bColor = Colors.black.withOpacity(0.3);
  AudioController backgroundaudioController = Get.put(AudioController());

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(12);
    final double containerHeight = MediaQuery.of(context).size.height * 0.3;
    final double containerWidth = MediaQuery.of(context).size.width * 0.2;

    return Scaffold(
      backgroundColor: widget.backgroundcolor.toColor(),
      body: Stack(
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
          SizedBox(
            height: MediaQuery.sizeOf(context).height,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    
                    Text(
                      widget.generalSubscriptionText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: borderRadius,
                          child: Material(
                            borderRadius: borderRadius,
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {},
                              child: Container(
                                height: containerHeight,
                                width: containerWidth,
                                decoration: BoxDecoration(
                                  borderRadius: borderRadius,
                                  color: bColor,
                                ),
                                child: Center(
                                    child: Text(widget.monthly,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.bold))),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        ClipRRect(
                          borderRadius: borderRadius,
                          child: Material(
                            borderRadius: borderRadius,
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {},
                              child: Container(
                                height: containerHeight,
                                width: containerWidth,
                                decoration: BoxDecoration(
                                  borderRadius: borderRadius,
                                  color: bColor,
                                ),
                                child: Center(
                                    child: Text(widget.yearly,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.bold))),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Restore Purchase',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
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
                  ],
                ),
              ),
            ),
          ),
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
                  Get.back();
                },
              ),
            ),
          ),
        ],
      ),
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
