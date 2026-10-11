import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/news_article.dart';

class NewsService {
  static const String _workerUrl =
      'https://dawn-grass-64f6.yaha566876.workers.dev';

  Future<List<NewsArticle>> getTopHeadlines({
    int page = 1,
  }) async {
    final uri = Uri.parse(
      '$_workerUrl?type=top&page=$page',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List articles = data['articles'] ?? [];

      debugPrint('Page: $page');
      debugPrint('Number of articles: ${articles.length}');

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
    final uri = Uri.parse(
      '$_workerUrl?type=search'
      '&q=${Uri.encodeQueryComponent(query)}'
      '&page=$page',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List articles = data['articles'] ?? [];

      debugPrint('Search page: $page');
      debugPrint('Search results: ${articles.length}');

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
    final uri = Uri.parse(
      '$_workerUrl?type=top'
      '&category=${Uri.encodeQueryComponent(category)}'
      '&page=$page',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List articles = data['articles'] ?? [];

      debugPrint('Category: $category');
      debugPrint('Category page: $page');
      debugPrint('Category results: ${articles.length}');

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