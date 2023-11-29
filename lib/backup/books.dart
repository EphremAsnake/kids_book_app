// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
// import 'package:get/get.dart';
// import 'package:image_fade/image_fade.dart';
// import 'package:resize/resize.dart';
// import 'package:storyapp/controller/listenBookAudioController.dart';
// import 'package:storyapp/utils/colorConvet.dart';
// import '../../model/storyPage.dart';
// import '../../services/apiEndpoints.dart';
// import '../controller/backgroundMusicAudioController.dart';
// import '../model/booklistModel.dart';
// import '../model/configModel.dart';
// import '../widget/animatedTextWidget.dart';
// import '../widget/dialog.dart';
// import '../pages/bookList.dart';
// import '../pages/books/choices/choice.dart';

// class BooksPage extends StatefulWidget {
//   final StoryPageApiResponse response;
//   final int indexValue;
//   final String backgroundMusic;

//   final ApiResponse booksList;
//   final ConfigApiResponseModel configResponse;
//   const BooksPage(
//       {super.key,
//       required this.response,
//       required this.indexValue,
//       required this.backgroundMusic,
//       required this.booksList,
//       required this.configResponse});

//   @override
//   _BooksPageState createState() => _BooksPageState();
// }

// class _BooksPageState extends State<BooksPage> {
//   List<String> images = [];
//   List<String> audiourls = [];

//   late int _counter;
//   bool _imageLoaded = false;

//   late AudioController audioController;
//   late BookAudioController listenaudioController;
//   bool isAudioPlaying = false;
//   bool isListening = false;

//   Color nextbuttonColor = Colors.transparent;
//   Color previousbuttonColor = Colors.transparent;

//   @override
//   void initState() {
//     super.initState();

//     // _pageController.addListener(() {
//     //   setState(() {
//     //     _currentPage = _pageController.page!.round();
//     //   });
//     // });

//     listenaudioController = Get.find<BookAudioController>();
//     isListening = listenaudioController.isPlaying;

//     audioController = Get.find<AudioController>();

//     _counter = 0;
//     audioController.audioVolumeDown();
//     isAudioPlaying = audioController.isPlaying;

//     for (StoryPageModel page in widget.response.pages) {
//       images.add('${APIEndpoints.booksUrl}${widget.indexValue}/${page.image}');
//       audiourls
//           .add('${APIEndpoints.booksUrl}${widget.indexValue}/${page.audio}');
//     }
//     // for (StoryPageModel page in widget.response.pages) {
//     //   audiourls
//     //       .add('${APIEndpoints.booksUrl}${widget.indexValue}/${page.audio}');
//     // }

//     //_counter = 0;

//     //listenaudioController.startAudio(audiourls);

//     //!${APIEndpoints.booksUrl}${_counter+1}/${widget.response.pages[_counter].audio}

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Show the SecondScreen as a modal when the BooksPage is fully built and visible
//       showCupertinoModalPopup(
//         context: context,
//         builder: (context) => ChoiceScreen(
//           read: () {
//             listenaudioController.clearplayer();
//             Navigator.of(context).pop();
//           },
//           listen: () {
//             listenaudioController.startAudio(audiourls);
//             //listenaudioController.startAudio('${APIEndpoints.booksUrl}${widget.response.pages[_counter].audio}');
//             Navigator.of(context).pop();
//           },
//           booksList: widget.booksList,
//           configResponse: widget.configResponse,
//         ),
//       );
//     });
//   }

//   void _incrementCounter() {
//     if (_counter < images.length - 1) {
//       listenaudioController.incrementCounter();
//       setState(() {
//         _counter = listenaudioController.counter;
//       });
//       if (listenaudioController.listen) {
//         listenaudioController.startAudio(audiourls);
//       }
//     }
//     // setState(() {
//     //   if (_clear || _error) {
//     //     _clear = _error = false;
//     //   } else {
//     //     _counter = (_counter + 1) % images.length;
//     //   }
//     // });
//   }

//   void _deccrementCounter() {
//     if (_counter > 0) {
//       listenaudioController.decrementCounter();
//       setState(() {
//         _counter = listenaudioController.counter;
//       });
//       if (listenaudioController.listen) {
//         listenaudioController.startAudio(audiourls);
//       }
//     }

//     // setState(() {
//     //   if (_clear || _error) {
//     //     _clear = _error = false;
//     //   } else {
//     //     _counter = (_counter - 1) % images.length;
//     //   }
//     // });
//   }

//   // void _clearImage() {
//   //   setState(() {
//   //     _clear = true;
//   //     _error = false;
//   //   });
//   // }

//   // void _testError() {
//   //   setState(() => _error = true);
//   // }

//   @override
//   void dispose() {
//     super.dispose();
//     //listenaudioController.clearplayer();

//     //listenaudioController.clearCounter;
//     //listenaudioController.dispose();

//     audioController.audioVolumeUp();
//   }

//   @override
//   Widget build(BuildContext context) {
//     //String? url;
//     // if (_error) {
//     //   url = 'error.jpg';
//     // } else if (!_clear) {
//     //url = images[_counter];
//     //}

//     // String title = _error
//     //     ? 'error'
//     //     : _clear
//     //         ? 'placeholder'
//     //         : 'image #$_counter from Wikimedia';

//     return Scaffold(
//         backgroundColor: widget.response.backgroundColor.toColor(),
//         //appBar: AppBar(title: Text('Showing ' + title)),
//         body: GetBuilder<BookAudioController>(builder: (bookAudioController) {
//           // Update the local _counter when the BookAudioController's counter changes
//           _counter = bookAudioController.counter;
//           return WillPopScope(
//             onWillPop: () async {
//               bool shouldPop = await showDialog(
//                   context: context,
//                   barrierDismissible: false,
//                   builder: (BuildContext context) {
//                     return ExitDialogBox(
//                       title: 'Leave Story?',
//                       titleColor: Colors.orange,
//                       descriptions:
//                           'Do you want to leave this story and go back to home?',
//                       text: 'Leave',
//                       text2: 'Stay',
//                       functionCall: () async {
                       
//                         listenaudioController.resetAudioController();

//                         Navigator.pushAndRemoveUntil(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => BookListPage(
//                               booksList: widget.booksList,
//                               configResponse: widget.configResponse,
//                             ),
//                           ),
//                           (route) => false, // Remove all routes in the stack
//                         );

//                         //Navigator.pop(context);
//                       },
//                       secfunctionCall: () {
//                         Navigator.pop(context);
//                       },
//                     );
//                   });

//               return shouldPop;
//             },
//             child: SwipeDetector(
//               onSwipeRight: (offset) {
//                 _deccrementCounter();
//               },
//               onSwipeLeft: (offset) {
//                 _incrementCounter();
//               },
//               child: Center(
//                 child: Stack(
//                   children: <Widget>[
//                     Center(
//                       child: Stack(
//                         children: [
//                           ImageFade(
//                             width: MediaQuery.of(context).size.width * 0.85,
//                             // whenever the image changes, it will be loaded, and then faded in:
//                             image: NetworkImage(images[_counter]),

//                             // slow-ish fade for loaded images:
//                             duration: const Duration(milliseconds: 900),

//                             // if the image is loaded synchronously (ex. from memory), fade in faster:
//                             syncDuration: const Duration(milliseconds: 500),

//                             // supports most properties of Image:
//                             alignment: Alignment.center,
//                             fit: BoxFit.cover,
//                             scale: 2,

//                             // shown behind everything:
//                             placeholder: Container(
//                               color: const Color(0xFFCFCDCA),
//                               alignment: Alignment.center,
//                               child: const Icon(Icons.photo,
//                                   color: Colors.white30, size: 128.0),
//                             ),

//                             // shows progress while loading an image:
//                             // loadingBuilder: (context, progress, chunkEvent) {
//                             //   if (progress == 1.0) {
//                             //     setState(() {
//                             //       _imageLoaded = true;
//                             //     });
//                             //   }
//                             //   return CircularProgressIndicator(value: progress);
//                             // },
//                             loadingBuilder: (context, progress, chunkEvent) {
//                               // if (progress != 0.0) {
//                               //   setState(() {
//                               //     _imageLoaded = true;
//                               //   });
//                               // }
//                               return Center(
//                                   child: CircularProgressIndicator(
//                                       value: progress));
//                             },

//                             // displayed when an error occurs:
//                             errorBuilder: (context, error) => Container(
//                               color: const Color(0xFF6F6D6A),
//                               alignment: Alignment.center,
//                               child: const Icon(Icons.warning,
//                                   color: Colors.black26, size: 128.0),
//                             ),
//                           ),
//                           Positioned(
//                             top: MediaQuery.of(context).size.height * 0.03,
//                             left: MediaQuery.of(context).size.height * 0.037,
//                             child: Column(
//                               children: [
//                                 CircleAvatar(
//                                   radius:
//                                       MediaQuery.of(context).size.height * 0.06,
//                                   backgroundColor: Colors.white,
//                                   child: IconButton(
//                                     icon: const Icon(Icons.home_outlined,
//                                         color: Colors.blue),
//                                     onPressed: () {},
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10, vertical: 10),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Text(
//                                     '${_counter + 1}/${widget.response.pages.length}',
//                                     style: const TextStyle(
//                                       color: Colors.blue,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Positioned(
//                             top: MediaQuery.of(context).size.height * 0.03,
//                             right: MediaQuery.of(context).size.height * 0.037,
//                             child: Column(
//                               children: [
//                                 CircleAvatar(
//                                     radius: MediaQuery.of(context).size.height *
//                                         0.06,
//                                     backgroundColor: Colors.white,
//                                     child: GetBuilder<AudioController>(
//                                         builder: (audioController) {
//                                       return IconButton(
//                                         icon: GetBuilder<AudioController>(
//                                           builder: (audioController) {
//                                             return Icon(
//                                               audioController.isPlaying
//                                                   ? Icons.music_note_outlined
//                                                   : Icons.music_off_outlined,
//                                               color: Colors.blue,
//                                             );
//                                           },
//                                         ),
//                                         onPressed: () {
//                                           AudioController audioController =
//                                               Get.find<AudioController>();
//                                           audioController.toggleAudio();
//                                         },
//                                       );
//                                     })),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 if (listenaudioController.listen)
//                                   CircleAvatar(
//                                       radius:
//                                           MediaQuery.of(context).size.height *
//                                               0.06,
//                                       backgroundColor: Colors.white,
//                                       child: GetBuilder<BookAudioController>(
//                                           builder: (listenaudioController) {
//                                         return IconButton(
//                                           icon: GetBuilder<BookAudioController>(
//                                             builder: (listenaudioController) {
//                                               return Icon(
//                                                 listenaudioController.isPlaying
//                                                     ? Icons.pause
//                                                     : Icons.headphones,
//                                                 color: Colors.blue,
//                                               );
//                                             },
//                                           ),
//                                           onPressed: () {
//                                             // AudioController audioController =
//                                             //     Get.find<AudioController>();

//                                             listenaudioController.toggleAudio();
//                                           },
//                                         );
//                                       })),
//                               ],
//                             ),
//                           ),
//                           // Positioned(
//                           //   top: MediaQuery.of(context).size.height * 0.17,
//                           //   left: MediaQuery.of(context).size.height * 0.021,
//                           //   child: Container(
//                           //     padding: const EdgeInsets.symmetric(
//                           //         horizontal: 10, vertical: 10),
//                           //     decoration: BoxDecoration(
//                           //       color: Colors.white,
//                           //       borderRadius: BorderRadius.circular(20),
//                           //     ),
//                           //     child: Text(
//                           //       '${_counter + 1}/${widget.response.pages.length}',
//                           //       style: const TextStyle(
//                           //         color: Colors.blue,
//                           //         fontSize: 16,
//                           //         fontWeight: FontWeight.bold,
//                           //       ),
//                           //     ),
//                           //   ),
//                           // ),
//                           Positioned(
//                             bottom: 0,
//                             left: 0,
//                             right: 0,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.95),
//                                 borderRadius: const BorderRadius.only(
//                                   topLeft: Radius.circular(12),
//                                   topRight: Radius.circular(12),
//                                 ),
//                               ),
//                               height: MediaQuery.of(context).size.height * 0.2,
//                               // margin: EdgeInsets.symmetric(
//                               //   horizontal: MediaQuery.of(context).size.width * 0.0075,
//                               // ),
//                               child: Center(
//                                 child: Padding(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal:
//                                           MediaQuery.of(context).size.width *
//                                               0.035,
//                                     ),
//                                     child: AnimatedTextWidget(
//                                       text:
//                                           widget.response.pages[_counter].text,
//                                     )),
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     Positioned(
//                       bottom: MediaQuery.of(context).size.height * 0.03,
//                       left: MediaQuery.of(context).size.width * 0.035,
//                       //MediaQuery.of(context).size.width * 0.035,
//                       child: InkWell(
//                         onTap: () {
//                           setState(() {
//                             previousbuttonColor = Colors.blue;
//                           });

//                           Future.delayed(const Duration(milliseconds: 500), () {
//                             setState(() {
//                               previousbuttonColor = Colors.transparent;
//                             });
//                           });

//                           _deccrementCounter();
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: previousbuttonColor,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: const EdgeInsets.all(3.0),
//                           child: SvgPicture.asset(
//                             'assets/previous.svg',
//                             height: 55,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: MediaQuery.of(context).size.height * 0.03,
//                       right: MediaQuery.of(context).size.width * 0.035,
//                       child: InkWell(
//                         onTap: () {
//                           setState(() {
//                             nextbuttonColor =
//                                 Colors.blue; // Change color to blue
//                           });

//                           Future.delayed(const Duration(milliseconds: 500), () {
//                             setState(() {
//                               nextbuttonColor = Colors
//                                   .transparent; // Revert color after 500 milliseconds (0.5 seconds)
//                             });
//                           });

//                           _incrementCounter();
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: nextbuttonColor,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: const EdgeInsets.all(3.0),
//                           child: SvgPicture.asset(
//                             'assets/next.svg',
//                             height: 55,
//                           ),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           );

//           // floatingActionButton: Row(
//           //   mainAxisAlignment: MainAxisAlignment.end,
//           //   children: [
//           //     FloatingActionButton(
//           //       onPressed: _incrementCounter,
//           //       tooltip: 'Next',
//           //       child: const Icon(Icons.navigate_next),
//           //     ),
//           //     const SizedBox(width: 10.0),
//           //     FloatingActionButton(
//           //       onPressed: _clearImage,
//           //       tooltip: 'Clear',
//           //       child: const Icon(Icons.clear),
//           //     ),
//           //     const SizedBox(width: 10.0),
//           //     FloatingActionButton(
//           //       onPressed: _testError,
//           //       tooltip: 'Error',
//           //       child: const Icon(Icons.warning),
//           //     ),
//           //   ],
//           // ),
//         }));
//   }
// }
