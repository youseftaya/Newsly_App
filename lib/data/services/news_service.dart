import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/news_article.dart';

class NewsService {
  static const String _baseUrl =
      'https://gnews.io/api/v4/top-headlines';

  static const String _searchUrl =
      'https://gnews.io/api/v4/search';

  Future<List<NewsArticle>> getTopHeadlines({
    int page = 1,
  }) async {
    final apiKey = dotenv.env['GNEWS_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GNews API key not found.');
    }

    final uri = Uri.parse(
      '$_baseUrl?category=general'
      '&lang=en'
      '&country=us'
      '&max=10'
      '&page=$page'
      '&apikey=$apiKey',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List articles = data['articles'] ?? [];

      print('Page: $page');
      print('Number of articles: ${articles.length}');

      return articles
          .map((article) => NewsArticle.fromJson(article))
          .toList();
    }

    throw Exception(
      'Failed to load news.\n'
      'Status Code: ${response.statusCode}\n'
      'Response: ${response.body}',
    );
  }

  Future<List<NewsArticle>> searchNews(
    String query, {
    int page = 1,
  }) async {
    final apiKey = dotenv.env['GNEWS_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GNews API key not found.');
    }

    final uri = Uri.parse(
      '$_searchUrl?q=${Uri.encodeQueryComponent(query)}'
      '&lang=en'
      '&country=us'
      '&max=10'
      '&page=$page'
      '&apikey=$apiKey',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List articles = data['articles'] ?? [];

      print('Search page: $page');
      print('Search results: ${articles.length}');

      return articles
          .map((article) => NewsArticle.fromJson(article))
          .toList();
    }

    throw Exception(
      'Failed to search news.\n'
      'Status Code: ${response.statusCode}\n'
      'Response: ${response.body}',
    );
  }

  Future<List<NewsArticle>> getNewsByCategory(
    String category, {
    int page = 1,
  }) async {
    final apiKey = dotenv.env['GNEWS_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GNews API key not found.');
    }

    final uri = Uri.parse(
      '$_baseUrl?category=$category'
      '&lang=en'
      '&country=us'
      '&max=10'
      '&page=$page'
      '&apikey=$apiKey',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List articles = data['articles'] ?? [];

      print('Category: $category');
      print('Category page: $page');
      print('Category results: ${articles.length}');

      return articles
          .map((article) => NewsArticle.fromJson(article))
          .toList();
    }

    throw Exception(
      'Failed to load category news.\n'
      'Status Code: ${response.statusCode}\n'
      'Response: ${response.body}',
    );
  }
}