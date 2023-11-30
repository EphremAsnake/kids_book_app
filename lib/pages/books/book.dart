import 'package:audioplayers/audioplayers.dart';
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

class _BooksPageState extends State<BookPage> {
  final AudioPlayer _audiobookPlayer = AudioPlayer();
  bool isPlaying = false;
  bool wasPlayingBeforeInterruption = false; // New flag to track previous state
  List<String> audioUrls = [];
  int _counter = 0;
  bool inlastPage = false;
  bool _listen = false;

  List<String> images = [];
  List<String> audiourls = [];

  late AudioController audioController;
  bool isAudioPlaying = false;
  bool isListening = false;

  Color nextbuttonColor = Colors.transparent;
  Color previousbuttonColor = Colors.transparent;
  bool hasLastScreenDisplayed = false;

  @override
  void initState() {
    super.initState();

    isListening = isPlaying;

    audioController = Get.find<AudioController>();

    audioController.audioVolumeDown();
    isAudioPlaying = audioController.isPlaying;

    for (StoryPageModel page in widget.response.pages) {
      images.add('${APIEndpoints.booksUrl}${widget.indexValue}/${page.image}');
      audiourls
          .add('${APIEndpoints.booksUrl}${widget.indexValue}/${page.audio}');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show the SecondScreen as a modal when the BooksPage is fully built and visible
      showCupertinoModalPopup(
        context: context,
        builder: (context) => ChoiceScreen(
          read: () {
            //listenaudioController.clearplayer();
            setState(() {
              isListening = false;
            });
            Navigator.of(context).pop();
          },
          listen: () {
            startAudio(audiourls[_counter]);
            //listenaudioController.startAudio(audiourls);
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

  void _incrementCounter() {
    // if (_counter == images.length - 1 && _listen) {
    //   lastScreen();
    // }
    if (_counter < images.length - 1) {
      setState(() {
        _counter = _counter + 1;
      });
      // setState(() {
      //   _counter = listenaudioController.counter;
      // });
      if (_listen) {
        _audiobookPlayer.stop();
        startAudio(audiourls[_counter]);
      }
    } else if (!_listen) {
      lastScreen();
    }
  }

  void _deccrementCounter() {
    if (_counter > 0) {
      setState(() {
        _counter = _counter - 1;
      });
      // setState(() {
      //   _counter = listenaudioController.counter;
      // });
      if (_listen) {
        _audiobookPlayer.stop;
        startAudio(audiourls[_counter]);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _audiobookPlayer.dispose();

    audioController.audioVolumeUp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: widget.response.backgroundColor.toColor(),
        body: WillPopScope(
          onWillPop: () async {
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
                        ImageFade(
                          width: MediaQuery.of(context).size.width * 0.85,
                          // whenever the image changes, it will be loaded, and then faded in:
                          image: NetworkImage(images[_counter]),

                          // slow-ish fade for loaded images:
                          duration: const Duration(milliseconds: 900),

                          // if the image is loaded synchronously (ex. from memory), fade in faster:
                          syncDuration: const Duration(milliseconds: 500),

                          // supports most properties of Image:
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                          scale: 2,

                          // shown behind everything:
                          placeholder: Container(
                            color: const Color(0xFFCFCDCA),
                            alignment: Alignment.center,
                            child: const Icon(Icons.photo,
                                color: Colors.white30, size: 128.0),
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

                          // displayed when an error occurs:
                          errorBuilder: (context, error) => Container(
                            color: const Color(0xFF6F6D6A),
                            alignment: Alignment.center,
                            child: const Icon(Icons.warning,
                                color: Colors.black26, size: 128.0),
                          ),
                        ),
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
                                  onPressed: () {},
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
                                            : Icons.headphones,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        toggleAudio();
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

  void incrementCounter() {
    setState(() {
      _counter = _counter + 1;
    });
  }

  void decrementCounter() {
    setState(() {
      _counter = _counter - 1;
    });
  }

  void setListenMode(bool value) {
    _listen = value;
    updateAudioPlayback();
  }

  void updateAudioPlayback() {
    if (_listen) {
      _audiobookPlayer.onPlayerStateChanged.listen(
        (it) async {
          switch (it) {
            case PlayerState.stopped:
              // if (_counter == images.length - 1) {
              //   lastScreen();
              // } else {
              //   //lastScreen();
              // }
              print(
                'Player stopped!'
                'toast-player-stopped-index',
              );
              break;
            case PlayerState.completed:
              if (_counter == audiourls.length - 1) {
                // setState(() {
                //   isListening = false;
                // });
                await Future.delayed(const Duration(seconds: 14));

                lastScreen();
              } else {
                _incrementCounter(); // Move to the next audio
              }
              break;
            default:
              break;
          }
        },
      );
    } else {
      _audiobookPlayer.stop(); // Stop audio if not in listen mode
    }
  }

  void toggleAudio() async {
    if (isPlaying) {
      await _audiobookPlayer.pause();
    } else {
      await _audiobookPlayer.seek(Duration.zero);
      await _audiobookPlayer.resume();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _playAudioAtIndex(String url) async {
    //if (index < audioUrls.length) {
    await Future.delayed(const Duration(seconds: 3));
    await _audiobookPlayer.play(UrlSource(url));
    setState(() {
      isPlaying = true;
    });
    //}
  }

  // Function to start playing the list of audio URLs
  void startAudio(String url) {
    //audioUrls = List<String>.from(urls);
    _playAudioAtIndex(url);
    setListenMode(true);
  }
}
