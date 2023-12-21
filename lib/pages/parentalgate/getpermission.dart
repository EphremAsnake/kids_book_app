import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Custom widget to get parent permission
class GetParentPermission extends StatefulWidget {
  final Color bgColor;
  const GetParentPermission({super.key, required this.bgColor});

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   automaticallyImplyLeading: false,
        //   actions: [
        //     IconButton(
        //         onPressed: () {
        //           // Close the screen with a failure flag
        //           Navigator.pop(context, false);
        //         },
        //         icon: const Icon(
        //           Icons.close_rounded,
        //           color: Colors.blue,
        //           size: 30,
        //         ))
        //   ],
        // ),
        backgroundColor: widget.bgColor,
        body: SafeArea(
          child: Stack(
            children: [
              //!Background Image
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
              // Left side of the landscape layout
              Padding(
                padding: const EdgeInsets.only(top:56.0),
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      // Left Column
                      SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width / 2.1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Parent permission message and current challenge
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // CustomButton(
                                //   buttonSize: 50,
                                //   onTap: () {
                                //     // Speak a message to ask for parent's permission
                                //   },
                                //   child: const Icon(Icons.volume_up_rounded),
                                // ),
                                Column(
                                  children: [
                                    Text(
                                      "   Ask your parents",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "To continue, tap:",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            // Display the current challenge
                            Text(
                              numberWord.join(" , "),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            // Display user input placeholders
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
                          ],
                        ),
                      ),
                      // Right Column
                      SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width / 2.1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
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
                                            color: Colors.blue,
                                            fontSize: 20,
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
                              children: [
                                IgnorePointer(
                                  ignoring: currentIndex > 3,
                                  child: CustomButton(
                                    child: const Text(
                                      "0",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20,
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
                                IgnorePointer(
                                  ignoring: currentIndex > 3,
                                  child: CustomButton(
                                    width: 120,
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.blue,
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
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 20.0,
                  right: MediaQuery.of(context).size.height * 0.08,
                  child: CircleAvatar(
                      radius: MediaQuery.of(context).size.height * 0.06,
                      backgroundColor: Colors.white,
                      child: IconButton(
                          onPressed: () {
                            // Close the screen with a failure flag
                            Navigator.pop(context, false);
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.blue,
                            size: 30,
                          )))),
            ],
          ),
        ));
  }
  // //! Portrait layout
  // return SafeArea(
  //   child: Stack(
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.symmetric(
  //           vertical: 30,
  //         ),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: [
  //             // Top part of portrait layout
  //             Expanded(
  //               flex: 1,
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   // Parent permission message and current challenge
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       CustomButton(
  //                         buttonSize: 50,
  //                         onTap: () {},
  //                         child: const Icon(Icons.volume_up_rounded),
  //                       ),
  //                       const Column(
  //                         children: [
  //                           Text(
  //                             "   Ask your parents",
  //                             style: TextStyle(
  //                               color: Colors.blue,
  //                               fontSize: 20,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                           Text(
  //                             "To continue, tap:",
  //                             style: TextStyle(
  //                               color: Colors.blue,
  //                               fontSize: 12,
  //                             ),
  //                           ),
  //                         ],
  //                       )
  //                     ],
  //                   ),
  //                   // Display the current challenge
  //                   Text(
  //                     numberWord.join(" , "),
  //                     style: const TextStyle(
  //                       color: Colors.blue,
  //                       fontSize: 18,
  //                     ),
  //                   ),
  //                   // Display user input placeholders
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       for (int i = 0; i < 4; i++)
  //                         Column(
  //                           children: [
  //                             Padding(
  //                               padding: const EdgeInsets.symmetric(
  //                                 horizontal: 10,
  //                               ),
  //                               child: Column(
  //                                 children: [
  //                                   Text(
  //                                     (ansNumber[i] ?? '').toString(),
  //                                     style: const TextStyle(
  //                                       color: Colors.blue,
  //                                       fontSize: 20,
  //                                       height: 2,
  //                                       fontWeight: FontWeight.bold,
  //                                     ),
  //                                   ),
  //                                   Container(
  //                                     height: 2.5,
  //                                     width: 30,
  //                                     color: Colors.blue,
  //                                   )
  //                                 ],
  //                               ),
  //                             )
  //                           ],
  //                         )
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             // Bottom part of portrait layout
  //             Expanded(
  //               flex: 1,
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   // Buttons for user input
  //                   for (int i = 0; i < 3; i++)
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       children: [
  //                         for (int j = 1; j < 4; j++)
  //                           IgnorePointer(
  //                             ignoring: currentIndex > 3,
  //                             child: CustomButton(
  //                               child: Text(
  //                                 "${(i * 3) + j}",
  //                                 style: const TextStyle(
  //                                   color: Colors.blue,
  //                                   fontSize: 20,
  //                                   fontWeight: FontWeight.bold,
  //                                 ),
  //                               ),
  //                               onTap: () {
  //                                 setState(() {
  //                                   ansNumber[currentIndex] = (i * 3) + j;
  //                                   checkSuccess();
  //                                 });
  //                               },
  //                             ),
  //                           ),
  //                       ],
  //                     ),
  //                   // Buttons for '0' and 'back'
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                     children: [
  //                       IgnorePointer(
  //                         ignoring: currentIndex > 3,
  //                         child: CustomButton(
  //                           child: const Text(
  //                             "0",
  //                             style: TextStyle(
  //                               color: Colors.blue,
  //                               fontSize: 20,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                           onTap: () {
  //                             setState(() {
  //                               ansNumber[currentIndex] = 0;
  //                               checkSuccess();
  //                             });
  //                           },
  //                         ),
  //                       ),
  //                       IgnorePointer(
  //                         ignoring: currentIndex > 3,
  //                         child: CustomButton(
  //                           width: 120,
  //                           child: const Icon(
  //                             Icons.arrow_back,
  //                             color: Colors.blue,
  //                           ),
  //                           onTap: () {
  //                             setState(() {
  //                               if (currentIndex > 0) {
  //                                 currentIndex--;
  //                                 ansNumber[currentIndex] = null;
  //                               }
  //                             });
  //                           },
  //                         ),
  //                       ),
  //                     ],
  //                   )
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   ),
  // );
}
//             return const Center(
//               child: Text('Rotate the Screen to see the parental gate'),
//             );
//           },
//         ));
//   }
// }

// Custom button widget
class CustomButton extends StatelessWidget {
  final Widget child;
  final double buttonSize;
  final double? width;
  final Function() onTap;

  const CustomButton({
    super.key,
    this.buttonSize = 60,
    required this.child,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: buttonSize,
        width: width ?? buttonSize,
        decoration: BoxDecoration(
          color: const Color(0xfff7f5ec),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 0, 53, 97),
              blurRadius: 0.5,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: child,
      ),
    );
  }
}
