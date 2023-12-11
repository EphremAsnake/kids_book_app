class BookList {
  final String folder;
  final String title;
  final String thumbnail;

  BookList({
    required this.folder,
    required this.title,
    required this.thumbnail,
  });

  factory BookList.fromJson(Map<String, dynamic> json) {
    return BookList(
      folder: json['folder'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}

class ApiResponse {
  final List<BookList> books;
  final String backgroundMusic;
  final String backgroundColor;
  final String? bookListEndText;

  final Map<String, dynamic>? houseAd;

  ApiResponse({
    required this.books,
    required this.backgroundMusic,
    required this.backgroundColor,
    this.houseAd,
    this.bookListEndText,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      books: (json['books'] as List<dynamic>? ?? [])
          .map((bookJson) => BookList.fromJson(bookJson))
          .toList(),
      backgroundMusic: json['background_music'] ?? '',
      backgroundColor:
          json['background_menu_color'] ?? '', // Match the JSON key here
      houseAd: json['house_ad'],
      bookListEndText: json['bookListEndText'],
    );
  }
}
