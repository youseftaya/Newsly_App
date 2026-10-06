class NewsArticle {
  final String category;
  final String title;
  final String imageUrl;
  final String description;
  final String articleUrl;

  const NewsArticle({
    required this.category,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.articleUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      category: json['source']?['name'] ?? 'News',
      title: json['title'] ?? 'No title',
      imageUrl: json['image'] ?? '',
      description: json['description'] ?? 'No description available.',
      articleUrl: json['url'] ?? '',
    );
  }
}