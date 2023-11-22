// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
// import 'package:image_fade/image_fade.dart';
// import 'package:storybook/utils/colorConvet.dart';
// import '../../../model/storyPage.dart';
// import '../../../services/apiEndpoints.dart';

// class ImageSlider extends StatefulWidget {
//   final StoryPageApiResponse response;
//   final int indexValue;
//   const ImageSlider(
//       {super.key, required this.response, required this.indexValue});

//   @override
//   _ImageSliderState createState() => _ImageSliderState();
// }

// class _ImageSliderState extends State<ImageSlider> {
//   List<String> images = [];

//   int _counter = 0;
//   bool _imageLoaded = false;

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
//     for (StoryPageModel page in widget.response.pages) {
//       images.add('${APIEndpoints().book}${widget.indexValue}/${page.image}');
//     }
//   }

//   void _incrementCounter() {
//     if (_counter < images.length - 1) {
//       setState(() {
//         _counter++;
//       });
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
//       setState(() {
//         _counter--;
//       });
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
//       backgroundColor: widget.response.backgroundColor.toColor(),
//       //appBar: AppBar(title: Text('Showing ' + title)),
//       body: SwipeDetector(
//         onSwipeRight: (offset) {
//           _deccrementCounter();
//         },
//         onSwipeLeft: (offset) {
//           _incrementCounter();
//         },
//         child: Center(
//           child: Stack(
//             children: <Widget>[
//               Center(
//                 child: Stack(
//                   children: [
//                     ImageFade(
//                       width: MediaQuery.of(context).size.width * 0.85,
//                       // whenever the image changes, it will be loaded, and then faded in:
//                       image: NetworkImage(images[_counter]),

//                       // slow-ish fade for loaded images:
//                       duration: const Duration(milliseconds: 900),

//                       // if the image is loaded synchronously (ex. from memory), fade in faster:
//                       syncDuration: const Duration(milliseconds: 500),

//                       // supports most properties of Image:
//                       alignment: Alignment.center,
//                       fit: BoxFit.cover,
//                       scale: 2,

//                       // shown behind everything:
//                       placeholder: Container(
//                         color: const Color(0xFFCFCDCA),
//                         alignment: Alignment.center,
//                         child: const Icon(Icons.photo,
//                             color: Colors.white30, size: 128.0),
//                       ),

//                       // shows progress while loading an image:
//                       // loadingBuilder: (context, progress, chunkEvent) {
//                       //   if (progress == 1.0) {
//                       //     setState(() {
//                       //       _imageLoaded = true;
//                       //     });
//                       //   }
//                       //   return CircularProgressIndicator(value: progress);
//                       // },
//                       loadingBuilder: (context, progress, chunkEvent) {
//                         // if (progress != 0.0) {
//                         //   setState(() {
//                         //     _imageLoaded = true;
//                         //   });
//                         // }
//                         return Center(
//                             child: CircularProgressIndicator(value: progress));
//                       },

//                       // displayed when an error occurs:
//                       errorBuilder: (context, error) => Container(
//                         color: const Color(0xFF6F6D6A),
//                         alignment: Alignment.center,
//                         child: const Icon(Icons.warning,
//                             color: Colors.black26, size: 128.0),
//                       ),
//                     ),
//                     Positioned(
//                       top: MediaQuery.of(context).size.height * 0.03,
//                       left: MediaQuery.of(context).size.height * 0.037,
//                       child: CircleAvatar(
//                         radius: MediaQuery.of(context).size.height * 0.06,
//                         backgroundColor: Colors.white,
//                         child: IconButton(
//                           icon: const Icon(Icons.home_outlined,
//                               color: Colors.blue),
//                           onPressed: () {},
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       top: MediaQuery.of(context).size.height * 0.03,
//                       right: MediaQuery.of(context).size.height * 0.037,
//                       child: CircleAvatar(
//                         radius: MediaQuery.of(context).size.height * 0.06,
//                         backgroundColor: Colors.white,
//                         child: IconButton(
//                           icon: const Icon(Icons.music_note_outlined,
//                               color: Colors.blue),
//                           onPressed: () {},
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       top: MediaQuery.of(context).size.height * 0.17,
//                       left: MediaQuery.of(context).size.height * 0.021,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 10),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           '${_counter + 1}/${widget.response.pages.length}',
//                           style: const TextStyle(
//                             color: Colors.blue,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       left: 0,
//                       right: 0,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white54.withOpacity(0.8),
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(12),
//                             topRight: Radius.circular(12),
//                           ),
//                         ),
//                         height: MediaQuery.of(context).size.height * 0.2,
//                         // margin: EdgeInsets.symmetric(
//                         //   horizontal: MediaQuery.of(context).size.width * 0.0075,
//                         // ),
//                         child: Center(
//                           child: Text(
//                             widget.response.pages[_counter].text,
//                             overflow: TextOverflow.visible,
//                             maxLines: 3,
//                             style: const TextStyle(
//                               color: Colors.black,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               Positioned(
//                 bottom: MediaQuery.of(context).size.height * 0.03,
//                 left: MediaQuery.of(context).size.width * 0.035,
//                 child: InkWell(
//                   onTap: () {
//                     setState(() {
//                       previousbuttonColor = Colors.blue; // Change color to blue
//                     });

//                     Future.delayed(const Duration(milliseconds: 10), () {
//                       setState(() {
//                         previousbuttonColor = Colors
//                             .transparent; // Revert color after 500 milliseconds (0.5 seconds)
//                       });
//                     });

//                     _deccrementCounter();
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: previousbuttonColor,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     padding: const EdgeInsets.all(8.0),
//                     child: SvgPicture.asset(
//                       'assets/previous.svg',
//                       height: 55,
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: MediaQuery.of(context).size.height * 0.03,
//                 right: MediaQuery.of(context).size.width * 0.035,
//                 child: InkWell(
//                   onTap: () {
//                     setState(() {
//                       nextbuttonColor = Colors.blue; // Change color to blue
//                     });

//                     Future.delayed(const Duration(milliseconds: 500), () {
//                       setState(() {
//                         nextbuttonColor = Colors
//                             .transparent; // Revert color after 500 milliseconds (0.5 seconds)
//                       });
//                     });

//                     _incrementCounter();
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: nextbuttonColor,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     padding: const EdgeInsets.all(8.0),
//                     child: SvgPicture.asset(
//                       'assets/next.svg',
//                       height: 55,
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),

//       // floatingActionButton: Row(
//       //   mainAxisAlignment: MainAxisAlignment.end,
//       //   children: [
//       //     FloatingActionButton(
//       //       onPressed: _incrementCounter,
//       //       tooltip: 'Next',
//       //       child: const Icon(Icons.navigate_next),
//       //     ),
//       //     const SizedBox(width: 10.0),
//       //     FloatingActionButton(
//       //       onPressed: _clearImage,
//       //       tooltip: 'Clear',
//       //       child: const Icon(Icons.clear),
//       //     ),
//       //     const SizedBox(width: 10.0),
//       //     FloatingActionButton(
//       //       onPressed: _testError,
//       //       tooltip: 'Error',
//       //       child: const Icon(Icons.warning),
//       //     ),
//       //   ],
//       // ),
//     );
//   }
// }
