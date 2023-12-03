import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:get/get.dart';
import 'package:image_fade/image_fade.dart';
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

class _BooksPageState extends State<BookPage> with WidgetsBindingObserver {
  //final AudioPlayer _audiobookPlayer = AudioPlayer();
  AudioPlayer bookplayer = AudioPlayer();
  bool isPlaying = false;
  bool wasPlayingBeforeInterruption =
      false; //! New flag to track previous state
  List<String> audioUrls = [];
  int _counter = 0;
  bool inlastPage = false;
  bool _listen = false;

  List<String> images = [];
  List<String> bookAudioUrls = [];

  late AudioController audioController;
  bool isAudioPlaying = false;
  //bool isListening = false;

  Color nextbuttonColor = Colors.transparent;
  Color previousbuttonColor = Colors.transparent;
  bool hasLastScreenDisplayed = false;

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
            // Navigator.of(context).pop();
          },
          booksList: widget.booksList,
          configResponse: widget.configResponse,
        ),
      );
    }
  }

  Future<void> startPlaying() async {
    bookplayer.setUrl(bookAudioUrls[_counter]);
    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      isPlaying = true;
      _listen = true;
    });
    bookplayer.play();
    bookplayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _incrementCounter();
      }
    });
  }

  Future<void> _incrementCounter() async {
    if (_listen && isIncrementing) {
      return; // Prevent multiple simultaneous increment calls
    }
    if (_listen) {
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
      });
      // setState(() {
      //   _counter = listenaudioController.counter;
      // });
      if (_listen) {
        bookplayer.setUrl(bookAudioUrls[_counter]);
        await Future.delayed(const Duration(seconds: 4));
        setState(() {
          isPlaying = true;
          isIncrementing = false;
        });
        bookplayer.play();
      }
    } else {
      lastScreen();
    }
  }

  Future<void> _deccrementCounter() async {
    if (_listen && isIncrementing) {
      return; // Prevent multiple simultaneous increment calls
    }
    if (_listen) {
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
        await Future.delayed(const Duration(seconds: 4));
        setState(() {
          isPlaying = true;
          isIncrementing = false;
        });
        bookplayer.play();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
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
            bool shouldPop = await showDialog(
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

            return shouldPop;
          },
          child: SwipeDetector(
            onSwipeRight: (offset) {
              _deccrementCounter();
            },
            onSwipeLeft: (offset) {
              _incrementCounter();
            },
            child: Center(
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Stack(
                      children: [
                        // AnimatedImageWidget(
                        //   childWidget: CachedNetworkImage(
                        //     width: MediaQuery.of(context).size.width * 0.85,
                        //     imageUrl: images[_counter],
                        //     placeholder: (context, url) =>
                        //         const CircularProgressIndicator(),
                        //     errorWidget: (context, url, error) =>
                        //         const Icon(Icons.error),
                        //     imageBuilder: (context, imageProvider) {
                        //       // Image loading is complete, do additional work here
                        //       // For example, you can perform some other tasks or display the image
                        //       // once it's loaded.
                        //       return Container(
                        //         decoration: BoxDecoration(
                        //           image: DecorationImage(
                        //             image: imageProvider,
                        //             fit: BoxFit.cover,
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        //   imageurl: images[_counter],
                        // ),
                        FadeInImage(
                          key: ValueKey<int>(_counter),
                          width: MediaQuery.of(context).size.width * 0.85,
                          placeholder: const AssetImage('assets/bg.png'),
                          image: CachedNetworkImageProvider(
                            images[_counter],
                          ),
                          fadeInDuration: const Duration(milliseconds: 2000),
                          fit: BoxFit.cover,
                        ),
                        // CachedNetworkImage(
                        //   width: MediaQuery.of(context).size.width * 0.85,
                        //   imageUrl: images[_counter],
                        //   placeholder: (context, url) =>
                        //       Container(width: MediaQuery.of(context).size.width * 0.85,color: Colors.white,),
                        //   errorWidget: (context, url, error) =>
                        //       const Icon(Icons.error),
                        //   imageBuilder: (context, imageProvider) {
                        //     // Image loading is complete, do additional work here
                        //     // For example, you can perform some other tasks or display the image
                        //     // once it's loaded.
                        //     return Container(
                        //       decoration: BoxDecoration(
                        //         image: DecorationImage(
                        //           image: imageProvider,
                        //           fit: BoxFit.cover,

                        //         ),
                        //       ),
                        //     );
                        //   },
                        // ),
                        // ImageFade(
                        //   width: MediaQuery.of(context).size.width * 0.85,
                        //   // whenever the image changes, it will be loaded, and then faded in:
                        //   image: NetworkImage(images[_counter]),

                        //   // slow-ish fade for loaded images:
                        //   duration: const Duration(milliseconds: 900),

                        //   // if the image is loaded synchronously (ex. from memory), fade in faster:
                        //   syncDuration: const Duration(milliseconds: 500),

                        //   // supports most properties of Image:
                        //   alignment: Alignment.center,
                        //   fit: BoxFit.cover,
                        //   scale: 2,

                        //   // shown behind everything:
                        //   placeholder: Container(
                        //     color: const Color(0xFFCFCDCA),
                        //     alignment: Alignment.center,
                        //     child: const Icon(Icons.photo,
                        //         color: Colors.white30, size: 128.0),
                        //   ),

                        //   // shows progress while loading an image:
                        //   // loadingBuilder: (context, progress, chunkEvent) {
                        //   //   if (progress == 1.0) {
                        //   //     setState(() {
                        //   //       _imageLoaded = true;
                        //   //     });
                        //   //   }
                        //   //   return CircularProgressIndicator(value: progress);
                        //   // },
                        //   // loadingBuilder: (context, progress, chunkEvent) {
                        //   //   // if (progress != 0.0) {
                        //   //   //   setState(() {
                        //   //   //     _imageLoaded = true;
                        //   //   //   });
                        //   //   // }
                        //   //   return Center(
                        //   //       child:
                        //   //           CircularProgressIndicator(value: progress));
                        //   // },

                        //   // displayed when an error occurs:
                        //   errorBuilder: (context, error) => Container(
                        //     color: const Color(0xFF6F6D6A),
                        //     alignment: Alignment.center,
                        //     child: const Icon(Icons.warning,
                        //         color: Colors.black26, size: 128.0),
                        //   ),
                        // ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.03,
                          left: MediaQuery.of(context).size.height * 0.037,
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius:
                                    MediaQuery.of(context).size.height * 0.06,
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: const Icon(Icons.home_outlined,
                                      color: Colors.blue),
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookListPage(
                                          booksList: widget.booksList,
                                          configResponse: widget.configResponse,
                                        ),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
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
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.03,
                          right: MediaQuery.of(context).size.height * 0.037,
                          child: Column(
                            children: [
                              CircleAvatar(
                                  radius:
                                      MediaQuery.of(context).size.height * 0.06,
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
                              if (_listen)
                                CircleAvatar(
                                    radius: MediaQuery.of(context).size.height *
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
                  Positioned(
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
                  Positioned(
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
                  )
                ],
              ),
            ),
          ),
        ));
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
