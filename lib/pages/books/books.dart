import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storybook/utils/colorConvet.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../model/storyPage.dart';
import '../../services/apiEndpoints.dart';

class BooksPage extends StatefulWidget {
  final StoryPageApiResponse response;
  final int indexValue;
  const BooksPage(
      {super.key, required this.response, required this.indexValue});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  //StoryPageApiResponse response = StoryPageApiResponse.fromJson(jsonResponse);
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<String> images = [];

  Color nextbuttonColor = Colors.transparent;
  Color previousbuttonColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
    for (StoryPageModel page in widget.response.pages) {
      images.add('${APIEndpoints().book}${widget.indexValue}/${page.image}');
    }
  }

  void nextPage() {
    if (_currentPage < images.length - 1) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //StoryPageModel story = widget.response.pages[0];
    // images = [
    //   '${APIEndpoints().book}0/${widget.response.pages[0].image}',
    //   '${APIEndpoints().book}0/${widget.response.pages[1].image}',
    //   '${APIEndpoints().book}0/${widget.response.pages[2].image}',
    //   'https://images.pexels.com/photos/7573942/pexels-photo-7573942.jpeg?auto=compress&cs=tinysrgb&w=1600',
    //   'https://images.pexels.com/photos/3390587/pexels-photo-3390587.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load'
    // ];
    return Scaffold(
        backgroundColor: widget.response.backgroundColor.toColor(),
        body: Stack(children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: double.infinity,
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.03,
                          left: MediaQuery.of(context).size.height * 0.037,
                          child: CircleAvatar(
                            radius: MediaQuery.of(context).size.height * 0.06,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.home_outlined,
                                  color: Colors.blue),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.03,
                          right: MediaQuery.of(context).size.height * 0.037,
                          child: CircleAvatar(
                            radius: MediaQuery.of(context).size.height * 0.06,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.music_note_outlined,
                                  color: Colors.blue),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.17,
                          left: MediaQuery.of(context).size.height * 0.021,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentPage + 1}/${widget.response.pages.length}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white54.withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      height: MediaQuery.of(context).size.height * 0.2,
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.075,
                      ),
                      child: Center(
                        child: Text(
                          widget.response.pages[index].text,
                          overflow: TextOverflow.visible,
                          maxLines: 3,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.03,
            left: MediaQuery.of(context).size.width * 0.035,
            child: InkWell(
              onTap: () {
                setState(() {
                  previousbuttonColor = Colors.blue; // Change color to blue
                });

                Future.delayed(const Duration(milliseconds: 500), () {
                  setState(() {
                    previousbuttonColor = Colors
                        .transparent; // Revert color after 500 milliseconds (0.5 seconds)
                  });
                });

                previousPage();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: previousbuttonColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8.0),
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
                  nextbuttonColor = Colors.blue; // Change color to blue
                });

                Future.delayed(const Duration(milliseconds: 500), () {
                  setState(() {
                    nextbuttonColor = Colors
                        .transparent; // Revert color after 500 milliseconds (0.5 seconds)
                  });
                });

                nextPage();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: nextbuttonColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  'assets/next.svg',
                  height: 55,
                ),
              ),
            ),
          )
        ]));
  }
}

Widget buildBookCard(StoryPageModel stories, int indexVal) {
  return Card(
    elevation: 2,
    color: Colors.white,
    child: Stack(
      children: [
        // Placeholder with shimmer effect
        const ShimmerEffect(),
        // FadeInImage for loading the network image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image:
                '${APIEndpoints().book}$indexVal/${stories.image}', // Provide the URL from your book object
            fit: BoxFit.contain,
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
            color: Colors.black.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                stories.text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        // if (book.status == "locked")
        //   ClipRRect(
        //     borderRadius: BorderRadius.circular(12),
        //     child: Container(
        //       color: Colors.black.withOpacity(0.5),
        //       width: double.infinity,
        //       height: double.infinity,
        //       child: const Icon(Icons.lock, color: Colors.white, size: 30),
        //     ),
        //   )
      ],
    ),
  );
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
          baseColor: Colors.grey[300]!,
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
