class APIEndpoints {
  static  String baseUrl =
      'https://www.buy.et/devwork/kids_book_app/v1-sub';
  static  String menuUrl = '$baseUrl/menu/';
  static  String booksUrl = '$baseUrl/books/';
  static  String configsUrl = '$baseUrl/configs/configs.json';

  static void updateBaseUrl(String newUrl) {
    baseUrl = newUrl;
  }
}
