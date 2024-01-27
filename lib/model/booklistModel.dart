class BookList {
  final int id;
  final String path;
  final String title;
  final String thumbnail;
  final bool locked;

  BookList({
    required this.id,
    required this.path,
    required this.title,
    required this.thumbnail,
    required this.locked,
  });

  factory BookList.fromJson(Map<String, dynamic> json) {
    return BookList(
      id: json['id'] ?? 0,
      path: json['path'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      locked: json['Locked'] ?? false,
    );
  }
}

class ApiResponse {
  final List<BookList> books;
  final String backgroundMusic;

  final String? bookListEndText;

  ApiResponse({
    required this.books,
    required this.backgroundMusic,
    this.bookListEndText,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      books: (json['books'] as List<dynamic>? ?? [])
          .map((bookJson) => BookList.fromJson(bookJson))
          .toList(),
      backgroundMusic: json['background_music'] ?? '',
      bookListEndText: json['bookListEndText'],
    );
  }
}
