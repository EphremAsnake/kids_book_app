class StoryPageModel {
  final String text;
  final String image;
  final String audio;

  StoryPageModel({
    required this.text,
    required this.image,
    required this.audio,
  });

  factory StoryPageModel.fromJson(Map<String, dynamic> json) {
    return StoryPageModel(
      text: json['text'] ?? '',
      image: json['image'] ?? '',
      audio: json['audio'] ?? '',
    );
  }
}

class StoryPageApiResponse {
  final List<StoryPageModel> pages;

  StoryPageApiResponse({
    required this.pages,
  });

  factory StoryPageApiResponse.fromJson(Map<String, dynamic> json) {
    List<StoryPageModel> pages = [];
    if (json['pages'] != null) {
      pages = List<StoryPageModel>.from(
        json['pages'].map(
          (page) => StoryPageModel.fromJson(page),
        ),
      );
    }

    return StoryPageApiResponse(
      pages: pages,
    );
  }
}
