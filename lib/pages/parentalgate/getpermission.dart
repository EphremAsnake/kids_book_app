import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starsview/starsview.dart';
import 'package:storyapp/utils/Constants/AllStrings.dart';

import '../../controller/subscriptionController.dart';
import '../../utils/Constants/colors.dart';
import '../../utils/Constants/dimention.dart';

// Custom widget to get parent permission
class GetParentPermission extends StatefulWidget {
  final Color bgColor;
  void Function()? onClose;
  GetParentPermission({super.key, required this.bgColor, this.onClose});

  @override
  State<GetParentPermission> createState() => _GetParentPermissionState();
}

// State class for GetParentPermission widget
class _GetParentPermissionState extends State<GetParentPermission> {
  // List of words representing numbers from 0 to 9
  List<String> oneToNine = [
    "Zero",
    "One",
    "Two",
    "Three",
    "Four",
    "Five",
    "Six",
    "Seven",
    "Eight",
    "Nine"
  ];

  // Lists to manage the current challenge and user input
  List<int> number = [];
  List<String> numberWord = [];
  List<int?> ansNumber = [];
  int currentIndex = 0;

  // Method to check if the user input matches the challenge
  checkSuccess() {
    if (currentIndex == 2) {
      if (listEquals(number, ansNumber)) {
        // If input matches, pop the screen with a success flag
        Navigator.pop(context, true);
      } else {
        // If input does not match, reset the challenge
        setNumber();
      }
    } else {
      currentIndex++;
    }
  }

  // Method to set a new random number challenge
  setNumber() {
    currentIndex = 0;
    number = [];
    numberWord = [];
    ansNumber = [];
    for (int i = 0; i < 3; i++) {
      int num = Random().nextInt(9);
      number.add(num);
      numberWord.add(oneToNine[num]);
      ansNumber.add(null);
    }
    if (mounted) setState(() {});
  }

  // Initialize the state by setting a new challenge
  @override
  void initState() {
    setNumber();
    super.initState();
  }

  // Build the UI for the GetParentPermission widget
  SubscriptionController subscriptionController =
      Get.put(SubscriptionController());
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        subscriptionController.hideProgress();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
          backgroundColor: widget.bgColor,
          body: Container(
            width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height*0.7,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              gradient: const LinearGradient(
                
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryColor, AppColors.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                //!Background Image
      
                // const StarsView(
                //   fps: 60,
                // ),
                 Container(
                      decoration: BoxDecoration(
      
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                Row(
                  children: [
                    const Spacer(),
      
                    SizedBox(
                      //height: 80,
                      width: MediaQuery.of(context).size.width / 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Spacer(),
                          if (MediaQuery.of(context).size.height > 800)
                            const SizedBox(),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Text(
                                      Strings.askYourParents,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Customfont',
                                        color: Colors.white,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Spacer(),
                          // const SizedBox(
                          //   height: 40,
                          // ),
                          Text(
                            numberWord.join(" , "),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < 3; i++)
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            (ansNumber[i] ?? '').toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              height: 2,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            height: 2.5,
                                            width: 30,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )
                            ],
                          ),
                           Spacer(), Spacer(),
                          const SizedBox(),
                          if (MediaQuery.of(context).size.height > 800)
                            const SizedBox(),
                        ],
                      ),
                    ),
                    // Right Column
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(),
                        // Buttons for user input
                        for (int i = 0; i < 3; i++)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (int j = 1; j < 4; j++)
                                IgnorePointer(
                                  ignoring: currentIndex > 3,
                                  child: CustomButton(
                                    child: Text(
                                      "${(i * 3) + j}",
                                      style: const TextStyle(
                                        color: AppColors.iconColor,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        ansNumber[currentIndex] = (i * 3) + j;
                                        checkSuccess();
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
      
                        // Buttons for '0' and 'back'
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IgnorePointer(
                              ignoring: currentIndex > 3,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 14.0),
                                child: CustomButton(
                                  child: const Text(
                                    "0",
                                    style: TextStyle(
                                      color: AppColors.iconColor,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      ansNumber[currentIndex] = 0;
                                      checkSuccess();
                                    });
                                  },
                                ),
                              ),
                            ),
                            IgnorePointer(
                              ignoring: currentIndex > 3,
                              child: CustomButton(
                                width: 90,
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: AppColors.iconColor,
                                ),
                                onTap: () {
                                  setState(() {
                                    if (currentIndex > 0) {
                                      currentIndex--;
                                      ansNumber[currentIndex] = null;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(10)),
                      color: AppColors.backgroundColor,
                    ),
                    child: IconButton(
                      iconSize: IconSizes.medium,
                      onPressed: () {
                        if (widget.onClose != null) {
                          widget.onClose!();
                        }
                        Navigator.pop(context, false);
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

// Custom button widget
class CustomButton extends StatefulWidget {
  final Widget child;
  final double buttonSize;
  final double? width;
  final Function() onTap;

  const CustomButton({
    super.key,
    this.buttonSize = 45,
    required this.child,
    required this.onTap,
    this.width,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(7),
        height: widget.buttonSize,
        width: widget.width ?? widget.buttonSize,
        decoration: BoxDecoration(
          color: _isPressed ? Colors.black.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.iconColor, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 0, 53, 97),
              blurRadius: 0.5,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
