import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:get/get.dart';
import 'package:image_fade/image_fade.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:resize/resize.dart';
import 'package:storyapp/utils/colorConvet.dart';
import '../../../model/storyPage.dart';
import '../../../services/apiEndpoints.dart';
import '../../controller/backgroundMusicAudioController.dart';
import '../../model/booklistModel.dart';
import '../../model/configModel.dart';
import '../../widget/animatedTextWidget.dart';
import '../../widget/dialog.dart';
import '../bookList.dart';
import 'choices/choice.dart';
import 'lastpage/lastpage.dart';

class BookPage extends StatefulWidget {
  final StoryPageApiResponse response;
  final int indexValue;
  final String backgroundMusic;

  final ApiResponse booksList;
  final ConfigApiResponseModel configResponse;
  const BookPage(
      {super.key,
      required this.response,
      required this.indexValue,
      required this.backgroundMusic,
      required this.booksList,
      required this.configResponse});

  @override
  // ignore: library_private_types_in_public_api
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BookPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  //final AudioPlayer _audiobookPlayer = AudioPlayer();
  AudioPlayer bookplayer = AudioPlayer();
  bool isPlaying = false;
  bool wasPlayingBeforeInterruption =
      false; //! New flag to track previous state
  List<String> audioUrls = [];
  int _counter = 0;
  bool inlastPage = false;
  bool _listen = false;
  late AnimationController _controller;
  List<String> images = [];
  List<String> bookAudioUrls = [];

  late AudioController audioController;
  bool isAudioPlaying = false;
  //bool isListening = false;
  Color trybuttonColor = const Color(0xffED1E54);

  Color nextbuttonColor = Colors.transparent;
  Color previousbuttonColor = Colors.transparent;
  bool hasLastScreenDisplayed = false;
  bool buttonsVisiblity = true;
  // final playlist = ConcatenatingAudioSource(
  //   // Start loading next item just before reaching it
  //   useLazyPreparation: true,
  //   // Customise the shuffle algorithm
  //   shuffleOrder: DefaultShuffleOrder(),
  //   // Specify the playlist items
  //   children: [],
  // );

  bool isIncrementing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //isPlaying = bookplayer.playerState == PlayerState.playing;

    audioController = Get.find<AudioController>();
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 3000), // Adjust the duration as needed
    );
    audioController.audioVolumeDown();
    isAudioPlaying = audioController.isPlaying;

    for (StoryPageModel page in widget.response.pages) {
      images.add('${APIEndpoints.booksUrl}${widget.indexValue}/${page.image}');
      bookAudioUrls
          .add('${APIEndpoints.booksUrl}${widget.indexValue}/${page.audio}');

      // playlist.add(AudioSource.uri(Uri.parse(
      //     '${APIEndpoints.booksUrl}${widget.indexValue}/${page.audio}')));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show the SecondScreen as a modal when the BooksPage is fully built and visible
      showCupertinoModalPopup(
        context: context,
        builder: (context) => ChoiceScreen(
          read: () {
            //listenaudioController.clearplayer();
            // setState(() {
            //   isListening = false;
            // });
            setState(() {
              _listen = false;
            });
            Navigator.of(context).pop();
          },
          listen: () async {
            // await bookplayer.setAudioSource(playlist,
            //     initialIndex: 0, initialPosition: Duration.zero);
            //listenaudioController.startAudio(audiourls);
            // ignore: use_build_context_synchronously
            startPlaying();
            Navigator.of(context).pop();
          },
          booksList: widget.booksList,
          configResponse: widget.configResponse,
        ),
      );
    });
  }

  bool isLastPage() {
    return _counter == images.length - 1;
  }

  void lastScreen() {
    if (!hasLastScreenDisplayed) {
      setState(() {
        hasLastScreenDisplayed = true;
      });

      showCupertinoModalPopup(
        context: context,
        builder: (context) => LastScreen(
          replay: () {
            //listenaudioController.clearplayer();
            setState(() {
              hasLastScreenDisplayed = false;
            });
            // Get.to(BookPage(
            //   response: widget.response,
            //   indexValue: widget.indexValue,
            //   backgroundMusic: widget.backgroundMusic,
            //   booksList: widget.booksList,
            //   configResponse: widget.configResponse,
            // ));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => BookPage(
                        response: widget.response,
                        indexValue: widget.indexValue,
                        backgroundMusic: widget.backgroundMusic,
                        booksList: widget.booksList,
                        configResponse: widget.configResponse,
                      )),
            );
            //Navigator.of(context).pop();
          },
          booksList: widget.booksList,
          configResponse: widget.configResponse,
          close: () {
            setState(() {
              hasLastScreenDisplayed = false;
            });
            Navigator.of(context).pop();
          },
          // ratingdialog: () {
          //   _showRatingDialog(context);
          // },
        ),
      );
    }
  }

  Future<void> startPlaying() async {
    bookplayer.setUrl(bookAudioUrls[_counter]);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isPlaying = true;
      _listen = true;
      isIncrementing = true;
    });
    bookplayer.play();
    bookplayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.ready) {
        setState(() {
          isIncrementing = false;
        });
      }
      if (playerState.processingState == ProcessingState.completed) {
        _incrementCounter();
      }
    });
  }

  Future<void> _incrementCounter() async {
    if (_listen && isIncrementing) {
      return; //! Prevent multiple simultaneous increment calls
    }
    if (_listen && !isLastPage()) {
      isIncrementing = true;
    }

    // if (_counter == images.length - 1 && _listen) {
    //   lastScreen();
    // }

    bookplayer.stop();
    setState(() {
      isPlaying = false;
    });
    if (_counter < images.length - 1) {
      setState(() {
        _counter++;
        _controller.forward(from: 0);
      });
      // setState(() {
      //   _counter = listenaudioController.counter;
      // });
      if (_listen) {
        bookplayer.setUrl(bookAudioUrls[_counter]);
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          isPlaying = true;
          //isIncrementing = false;
        });
        bookplayer.play();
        bookplayer.playerStateStream.listen((playerState) {
          if (playerState.processingState == ProcessingState.ready) {
            setState(() {
              isIncrementing = false;
              //isPlaying = false;
            });
            //_incrementCounter();
          }
        });
      }
    } else {
      lastScreen();
    }
  }

  Future<void> _deccrementCounter() async {
    if (_listen && isIncrementing) {
      return; // Prevent multiple simultaneous increment calls
    }
    if (_listen && !isLastPage()) {
      isIncrementing = true;
    }

    bookplayer.stop();
    setState(() {
      isPlaying = false;
    });
    if (_counter > 0) {
      setState(() {
        _counter--;
      });
      // setState(() {
      //   _counter = listenaudioController.counter;
      // });
      if (_listen) {
        bookplayer.setUrl(bookAudioUrls[_counter]);
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          isPlaying = true;
          //isIncrementing = false;
        });
        bookplayer.play();
        bookplayer.playerStateStream.listen((playerState) {
          if (playerState.processingState == ProcessingState.ready) {
            setState(() {
              isIncrementing = false;
              // isPlaying = false;
            });
            //_incrementCounter();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    if (bookplayer.playing) {
      bookplayer.stop(); //! Stop the audio player when leaving the page
    }
    bookplayer.dispose();

    audioController.audioVolumeUp();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App resumed from the background
      // Check if audio was playing before going to the background
      if (wasPlayingBeforeInterruption) {
        bookplayer.seek(Duration.zero);
        bookplayer.play();
        setState(() {
          isPlaying = true;
        });
        wasPlayingBeforeInterruption = false;
      }
    } else if (state == AppLifecycleState.paused) {
      // App went to the background
      // Check if audio is playing and store its state
      wasPlayingBeforeInterruption = bookplayer.playing;
      if (bookplayer.playing) {
        bookplayer.pause();
        setState(() {
          isPlaying = false;
        });
      }

      // Pause or stop audio playback here if needed
      // Example: bookplayer.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: widget.response.backgroundColor.toColor(),
        body: WillPopScope(
          onWillPop: () async {
            if (_listen) {
              togglePlayback();
            }
            bool shouldPop = await exitDialog(context);

            return shouldPop;
          },
          child: SwipeDetector(
            onSwipeRight: (offset) {
              _deccrementCounter();
            },
            onSwipeLeft: (offset) {
              _incrementCounter();
            },

            //!Hide Buttons
            // onSwipeUp: (offset) {
            //   setState(() {
            //     buttonsVisiblity = false;
            //   });
            // },
            // onSwipeDown: (offset) {
            //   setState(() {
            //     buttonsVisiblity = true;
            //   }
            //   );
            // },
            child: Center(
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Stack(
                      children: [
                        //!StoryImage
                        ImageFade(
                            width: MediaQuery.of(context).size.width * 0.85,
                            //! whenever the image changes, it will be loaded, and then faded in:
                            image: CachedNetworkImageProvider(images[_counter]),

                            //! slow-ish fade for loaded images:
                            duration: const Duration(milliseconds: 900),

                            //! if the image is loaded synchronously ,
                            syncDuration: const Duration(milliseconds: 900),
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                            scale: 2,

                            // shown behind everything:
                            placeholder: Container(
                              color: Colors.white.withOpacity(0.7),
                              alignment: Alignment.center,
                              child: const Icon(Icons.photo,
                                  color: Colors.transparent, size: 128.0),
                            ),

                            // shows progress while loading an image:
                            // loadingBuilder: (context, progress, chunkEvent) {
                            //   if (progress == 1.0) {
                            //     setState(() {
                            //       _imageLoaded = true;
                            //     });
                            //   }
                            //   return CircularProgressIndicator(value: progress);
                            // },
                            // loadingBuilder: (context, progress, chunkEvent) {
                            //   // if (progress != 0.0) {
                            //   //   setState(() {
                            //   //     _imageLoaded = true;
                            //   //   });
                            //   // }
                            //   return Center(
                            //       child:
                            //           CircularProgressIndicator(value: progress));
                            // },

                            //! displayed when an error occurs:
                            errorBuilder: (context, error) {
                              //togglePlayback();
                              bookplayer.stop;
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Oops couldn\'t load story',
                                      style: TextStyle(
                                          fontSize: 8.sp, color: Colors.blue),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                      onPressed: () {
                                        //_incrementCounter();
                                        _deccrementCounter();
                                      },
                                      child: Text(
                                        'Try Again',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8.sp),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),

                        //!Home and Page Counter
                        Visibility(
                          visible: buttonsVisiblity,
                          child: Positioned(
                            top: MediaQuery.of(context).size.height * 0.03,
                            left: MediaQuery.of(context).size.height * 0.037,
                            child: Column(
                              children: [
                                //!Home Button
                                CircleAvatar(
                                  radius:
                                      MediaQuery.of(context).size.height * 0.06,
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    icon: const Icon(Icons.home_outlined,
                                        color: Colors.blue),
                                    onPressed: () {
                                      if (audioController.isPlaying) {
                                        Get.offAll(
                                            BookListPage(
                                              booksList: widget.booksList,
                                              configResponse:
                                                  widget.configResponse,
                                            ),
                                            transition: Transition.fadeIn,
                                            duration:
                                                const Duration(seconds: 2));

                                        // Navigator.pushAndRemoveUntil(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => BookListPage(
                                        //       booksList: widget.booksList,
                                        //       configResponse:
                                        //           widget.configResponse,
                                        //     ),
                                        //   ),
                                        //   (route) => false,
                                        // );
                                      } else {
                                        Get.offAll(
                                            BookListPage(
                                              booksList: widget.booksList,
                                              configResponse:
                                                  widget.configResponse,
                                              isbackgroundsilent: true,
                                            ),
                                            transition: Transition.fadeIn,
                                            duration:
                                                const Duration(seconds: 2));

                                        // Navigator.pushAndRemoveUntil(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => BookListPage(
                                        //       booksList: widget.booksList,
                                        //       configResponse:
                                        //           widget.configResponse,
                                        //       isbackgroundsilent: true,
                                        //     ),
                                        //   ),
                                        //   (route) => false,
                                        // );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),

                                //!Page Counter
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_counter + 1}/${widget.response.pages.length}',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        //!Background Music And Strory Play
                        Visibility(
                          visible: buttonsVisiblity,
                          child: Positioned(
                            top: MediaQuery.of(context).size.height * 0.03,
                            right: MediaQuery.of(context).size.height * 0.037,
                            child: Column(
                              children: [
                                //!Background Music
                                CircleAvatar(
                                    radius: MediaQuery.of(context).size.height *
                                        0.06,
                                    backgroundColor: Colors.white,
                                    child: GetBuilder<AudioController>(
                                        builder: (audioController) {
                                      return IconButton(
                                        icon: GetBuilder<AudioController>(
                                          builder: (audioController) {
                                            return Icon(
                                              audioController.isPlaying
                                                  ? Icons.music_note_outlined
                                                  : Icons.music_off_outlined,
                                              color: Colors.blue,
                                            );
                                          },
                                        ),
                                        onPressed: () {
                                          AudioController audioController =
                                              Get.find<AudioController>();
                                          audioController.toggleAudio();
                                        },
                                      );
                                    })),
                                const SizedBox(
                                  height: 10,
                                ),

                                //!Story Play
                                if (_listen)
                                  CircleAvatar(
                                      radius:
                                          MediaQuery.of(context).size.height *
                                              0.06,
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        icon: Icon(
                                          isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow_outlined,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          togglePlayback();
                                        },
                                      )),
                              ],
                            ),
                          ),
                        ),

                        //!Story Text
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            height: MediaQuery.of(context).size.height * 0.2,
                            // margin: EdgeInsets.symmetric(
                            //   horizontal: MediaQuery.of(context).size.width * 0.0075,
                            // ),
                            child: Center(
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.035,
                                  ),
                                  child: AnimatedTextWidget(
                                    text: widget.response.pages[_counter].text,
                                  )),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  //!Previous Button
                  Visibility(
                    visible: buttonsVisiblity,
                    child: Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.03,
                      left: MediaQuery.of(context).size.width * 0.035,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            previousbuttonColor = Colors.blue;
                          });

                          Future.delayed(const Duration(milliseconds: 500), () {
                            setState(() {
                              previousbuttonColor = Colors.transparent;
                            });
                          });

                          _deccrementCounter();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: previousbuttonColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(3.0),
                          child: SvgPicture.asset(
                            'assets/previous.svg',
                            height: 55,
                          ),
                        ),
                      ),
                    ),
                  ),

                  //!Next Button
                  Visibility(
                    visible: buttonsVisiblity,
                    child: Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.03,
                      right: MediaQuery.of(context).size.width * 0.035,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            nextbuttonColor = Colors.blue;
                          });

                          Future.delayed(const Duration(milliseconds: 500), () {
                            setState(() {
                              nextbuttonColor = Colors.transparent;
                            });
                          });

                          _incrementCounter();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: nextbuttonColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(3.0),
                          child: SvgPicture.asset(
                            'assets/next.svg',
                            height: 55,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Future<dynamic> exitDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ExitDialogBox(
            title: 'Leave Story?',
            titleColor: Colors.orange,
            descriptions:
                'Do you want to leave this story and go back to home?',
            text: 'Leave',
            text2: 'Stay',
            functionCall: () async {
              //listenaudioController.resetAudioController();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => BookListPage(
                    booksList: widget.booksList,
                    configResponse: widget.configResponse,
                  ),
                ),
                (route) => false, // Remove all routes in the stack
              );

              //Navigator.pop(context);
            },
            secfunctionCall: () {
              if (_listen) {
                togglePlayback();
              }

              Navigator.pop(context);
            },
          );
        });
  }

  // void incrementCounter() {
  //   setState(() {
  //     _counter = _counter + 1;
  //   });
  // }

  // void decrementCounter() {
  //   setState(() {
  //     _counter = _counter - 1;
  //   });
  // }

  // void setListenMode(bool value) {
  //   _listen = value;
  //   updateAudioPlayback();
  // }

  // void updateAudioPlayback() {
  //   if (_listen) {
  //     _audiobookPlayer
  //       ..listen(
  //         (it) async {
  //           switch (it) {
  //             case PlayerState.stopped:
  //               // if (_counter == images.length - 1) {
  //               //   lastScreen();
  //               // } else {
  //               //   //lastScreen();
  //               // }
  //               print(
  //                 'Player stopped!'
  //                 'toast-player-stopped-index',
  //               );
  //               break;
  //             case PlayerState.completed:
  //               if (_counter == audiourls.length - 1) {
  //                 // setState(() {
  //                 //   isListening = false;
  //                 // });
  //                 await Future.delayed(const Duration(seconds: 14));

  //                 lastScreen();
  //               } else {
  //                 print('Completed Done');
  //                 _incrementCounter(); // Move to the next audio
  //               }
  //               break;
  //             default:
  //               break;
  //           }
  //         },
  //       );
  //   } else {
  //     _audiobookPlayer.stop(); // Stop audio if not in listen mode
  //   }
  // }

  void togglePlayback() {
    if (bookplayer.playing) {
      bookplayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      bookplayer.seek(Duration.zero);
      bookplayer.play();
      setState(() {
        isPlaying = true;
      });
    }
  }

  // void _playAudioAtIndex(String url) async {
  //   //if (index < audioUrls.length) {
  //   await Future.delayed(const Duration(seconds: 3));
  //   await _audiobookPlayer.play(UrlSource(url));
  //   setState(() {
  //     isPlaying = true;
  //   });
  //   //}
  // }

  // // Function to start playing the list of audio URLs
  // void startAudio(String url) {
  //   //audioUrls = List<String>.from(urls);
  //   _playAudioAtIndex(url);
  //   setListenMode(true);
  // }
}
