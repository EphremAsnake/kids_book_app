import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storybook/utils/colorConvet.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:audioplayers/audioplayers.dart';
import '../model/booklistModel.dart';
import '../model/storyPage.dart';
import '../services/apiEndpoints.dart';
import '../widget/choice.dart';
import '../widget/dialog.dart';
import 'books/books.dart';

class BookListPage extends StatefulWidget {
  final ApiResponse booksList;
  const BookListPage({Key? key, required this.booksList}) : super(key: key);

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isPlaying = false;

  Dio dio = Dio();

  List<StoryPageApiResponse?> storypageresponses = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    toggleAudio();
    for (int i = 0; i < widget.booksList.books.length; i++) {
      fetchDataForBookPage(i);
    }

    _scrollController.addListener(() {
      setState(() {
        showScrollToTopButton = _scrollController.offset > 0;
      });
    });
  }

  bool showScrollToTopButton = false;

  // Play or stop audio based on current state
  void toggleAudio() async {
    // print('${APIEndpoints().listurl}${widget.booksList.backgroundMusic}');
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(
          '${APIEndpoints().listurl}${widget.booksList.backgroundMusic}'));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      //! Pause audio when the app is paused or in the background
      _audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      //! Resume audio if needed when the app is resumed
      if (isPlaying) {
        _audioPlayer.resume();
      }
    }
  }

  Future<void> fetchDataForBookPage(int index) async {
    if (index >= 0 && index < widget.booksList.books.length) {
      try {
        Response sResponse =
            await dio.get('${APIEndpoints().book}$index/book.json');

        if (sResponse.statusCode == 200) {
          StoryPageApiResponse storyPageresponse =
              StoryPageApiResponse.fromJson(sResponse.data);

          if (index >= storypageresponses.length) {
            storypageresponses.addAll(List.generate(
                index + 1 - storypageresponses.length, (_) => null));
          }
          storypageresponses[index] = storyPageresponse;
        } else {
          print('Something Went Wrong Try Again');
        }
      } catch (e) {
        //! Handle errors if any
      }
    }
  }

  void navigateToNextPage(int index) {
    if (index >= 0 &&
        index < storypageresponses.length &&
        storypageresponses[index] != null) {
      //! Check if the response for the selected index exists
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BooksPage(
            response: storypageresponses[index]!,
            indexValue: index,
          ),
        ),
      );
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CustomDialogBox(
              title: 'Something Went Wrong',
              titleColor: const Color(0xffED1E54),
              descriptions: 'Something went wrong please try again.',
              text: 'OK',
              functionCall: () {
                Navigator.pop(context);
              },
              img: 'assets/dialog_error.svg',
            );
          });
      //! Handle scenarios where the response for the selected index is not available
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.booksList.backgroundColor.toColor(),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 20.0, // Set the top padding here to create space
              left: MediaQuery.of(context).size.height * 0.25,
              right: MediaQuery.of(context).size.height * 0.25,
            ),
            child: AnimationLimiter(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                controller: _scrollController,
                itemCount: widget.booksList.books.length,
                itemBuilder: (BuildContext context, int index) {
                  BookList book = widget.booksList.books[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: InkWell(
                          onTap: () {
                            if (index == 0) {
                              navigateToNextPage(index);
                            } else {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return ChoiceDialogBox(
                                    title: 'Access Stories',
                                    titleColor: Colors.orange,
                                    descriptions:
                                        'To unlock these stories, please watch a short ad.',
                                    text: 'Watch Ad',
                                    sectext: 'Close',
                                    functionCall: () {
                                      
                                      //showRewardAd();
                                      //Navigator.pop(context);
                                    },
                                    secfunctionCall: () {
                                      
                                      //showRewardAd();
                                      Navigator.pop(context);
                                    },
                                    img: 'assets/dialog_Info.svg',
                                  );
                                },
                              );
                            }
                          },
                          child: buildBookCard(book),
                        ),
                      ),
                    ),
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 30,
                  crossAxisCount: 3,
                ),
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
                icon: Icon(isPlaying
                    ? Icons.music_note_outlined
                    : Icons.music_off_outlined),
                onPressed: () {
                  toggleAudio();
                },
              ),
            ),
          ),
          if (showScrollToTopButton)
            Positioned(
              bottom: 20.0,
              left: MediaQuery.of(context).size.height * 0.08,
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.height * 0.06,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_upward_outlined),
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildBookCard(BookList book) {
    return SizedBox(
      height: 150,
      child: Card(
        elevation: 2,
        color: Colors.white,
        child: Stack(
          children: [
            // Placeholder with shimmer effect
            ShimmerEffect(),
            // FadeInImage for loading the network image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image:
                    '${APIEndpoints().url}${book.thumbnail}', // Provide the URL from your book object
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // Overlay for the title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12))),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    book.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            if (book.status == "locked")
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  width: double.infinity,
                  height: double.infinity,
                  child: const Icon(Icons.lock, color: Colors.white, size: 30),
                ),
              )
          ],
        ),
      ),
    );
  }
}

// Shimmer Effect Widget for Placeholder
class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.grey[300],
        width: double.infinity,
        height: double.infinity,
        child: Shimmer.fromColors(
          loop: 5,
          direction: ShimmerDirection.ltr,
          enabled: true,
          baseColor: Colors.white,
          highlightColor: Colors.grey[100]!,
          child: const SizedBox(
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
