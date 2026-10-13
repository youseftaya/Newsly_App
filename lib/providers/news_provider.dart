import 'package:flutter/foundation.dart';

import '../data/models/news_article.dart';
import '../data/services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService;

  NewsProvider({NewsService? newsService})
      : _newsService = newsService ?? NewsService();

  List<NewsArticle> _articles = [];

  List<NewsArticle> get articles => List.unmodifiable(_articles);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedCategory = 'general';
  String get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool get isSearching => _searchQuery.isNotEmpty;

  // Used to ignore outdated requests.
  int _requestId = 0;

  Future<void> loadNews() async {
    _selectedCategory = 'general';
    _searchQuery = '';
    await _loadFirstPage();
  }

  Future<void> loadCategory(String category) async {
    _selectedCategory = category;
    _searchQuery = '';
    await _loadFirstPage();
  }

  Future<void> searchNews(String query) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      await loadNews();
      return;
    }

    _searchQuery = normalizedQuery;
    await _loadFirstPage();
  }

  Future<List<NewsArticle>> _fetchPage({
    required String query,
    required String category,
    required int page,
  }) {
    if (query.isNotEmpty) {
      return _newsService.searchNews(query, page: page);
    }

    if (category == 'general') {
      return _newsService.getTopHeadlines(page: page);
    }

    return _newsService.getNewsByCategory(
      category,
      page: page,
    );
  }

  Future<void> _loadFirstPage() async {
    final requestId = ++_requestId;

    // Capture the requested values so this request stays consistent.
    final query = _searchQuery;
    final category = _selectedCategory;

    _isLoading = true;
    _isLoadingMore = false;
    _isRefreshing = false;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _articles = [];

    notifyListeners();

    try {
      final news = await _fetchPage(
        query: query,
        category: category,
        page: 1,
      );

      if (requestId != _requestId) return;

      _articles = news;
      _hasMore = news.isNotEmpty;
    } catch (e) {
      if (requestId != _requestId) return;

      _errorMessage = e.toString();
      debugPrint('Load news error: $e');
    } finally {
      if (requestId == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshNews() async {
    if (_isRefreshing || _isLoadingMore) return;

    final requestId = ++_requestId;
    final query = _searchQuery;
    final category = _selectedCategory;

    _isLoading = false;
    _isRefreshing = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final news = await _fetchPage(
        query: query,
        category: category,
        page: 1,
      );

      if (requestId != _requestId) return;

      _articles = news;
      _currentPage = 1;
      _hasMore = news.isNotEmpty;
    } catch (e) {
      if (requestId != _requestId) return;

      // Keep existing articles if refreshing fails.
      if (_articles.isEmpty) {
        _errorMessage = e.toString();
      }

      debugPrint('Refresh news error: $e');
    } finally {
      if (requestId == _requestId) {
        _isRefreshing = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMoreNews() async {
    if (_isLoading ||
        _isLoadingMore ||
        _isRefreshing ||
        !_hasMore) {
      return;
    }

    final requestId = _requestId;
    final query = _searchQuery;
    final category = _selectedCategory;
    final nextPage = _currentPage + 1;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final newArticles = await _fetchPage(
        query: query,
        category: category,
        page: nextPage,
      );

      if (requestId != _requestId) return;

      final existingUrls =
          _articles.map((article) => article.articleUrl).toSet();

      final uniqueArticles = <NewsArticle>[];

      for (final article in newArticles) {
        if (existingUrls.add(article.articleUrl)) {
          uniqueArticles.add(article);
        }
      }

      if (newArticles.isEmpty || uniqueArticles.isEmpty) {
        _hasMore = false;
      } else {
        _articles = [..._articles, ...uniqueArticles];
        _currentPage = nextPage;
      }
    } catch (e) {
      if (requestId == _requestId) {
        debugPrint('Load more news error: $e');
      }
    } finally {
      if (requestId == _requestId) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }
}