import 'package:flutter/material.dart';

import '../../data/models/news_article.dart';
import '../../data/services/news_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/auth_service.dart';
import '../../main.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/news_search_bar.dart';
import '../widgets/news_categories.dart';
import '../widgets/news_card.dart';
import 'article_screen.dart';

class HomeScreen extends StatefulWidget {
  final String initialCategory;

  const HomeScreen({
    super.key,
    this.initialCategory = 'general',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsService _newsService = NewsService();
  final FirestoreService _firestoreService =
      FirestoreService();
  final AuthService _authService = AuthService();

  final TextEditingController _searchController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  List<NewsArticle> articles = [];
  Set<String> favoriteUrls = {};

  bool isLoading = true;
  bool isLoadingMore = false;
  bool isSearching = false;
  bool isRefreshing = false;
  bool hasMore = true;

  String? errorMessage;

  late String selectedCategory;
  int currentPage = 1;

  final List<Map<String, String>> categories = [
    {'name': 'General', 'value': 'general'},
    {'name': 'Business', 'value': 'business'},
    {'name': 'Technology', 'value': 'technology'},
    {'name': 'Sports', 'value': 'sports'},
    {'name': 'Entertainment', 'value': 'entertainment'},
    {'name': 'Health', 'value': 'health'},
    {'name': 'Science', 'value': 'science'},
  ];

  @override
  void initState() {
    super.initState();

    selectedCategory = widget.initialCategory;
    _scrollController.addListener(_onScroll);

    _loadFavorites();

    if (selectedCategory == 'general') {
      _loadNews();
    } else {
      _loadCategory(selectedCategory);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Load the user's saved articles from Firebase.
  Future<void> _loadFavorites() async {
    try {
      final favorites =
          await _firestoreService.getFavorites();

      if (!mounted) return;

      setState(() {
        favoriteUrls = favorites
            .map((article) => article.articleUrl)
            .toSet();
      });
    } catch (e) {
      debugPrint('Firestore favorites error: $e');
    }
  }

  // Add or remove an article from Firebase favorites.
  Future<void> _toggleFavorite(
    NewsArticle article,
  ) async {
    final isFavorite =
        favoriteUrls.contains(article.articleUrl);

    try {
      if (isFavorite) {
        await _firestoreService.removeFavorite(article);

        if (!mounted) return;

        setState(() {
          favoriteUrls.remove(article.articleUrl);
        });
      } else {
        await _firestoreService.addFavorite(article);

        if (!mounted) return;

        setState(() {
          favoriteUrls.add(article.articleUrl);
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update saved news: $e',
          ),
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
        ),
      );
    }
  }

  void _toggleTheme() {
    themeNotifier.value =
        themeNotifier.value == ThemeMode.dark
            ? ThemeMode.light
            : ThemeMode.dark;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >=
        position.maxScrollExtent - 300) {
      _loadMoreNews();
    }
  }

  Future<void> _loadNews() async {
    setState(() {
      isLoading = true;
      isLoadingMore = false;
      errorMessage = null;
      isSearching = false;
      selectedCategory = 'general';
      currentPage = 1;
      hasMore = true;
      articles = [];
    });

    try {
      final news = await _newsService.getTopHeadlines(
        page: currentPage,
      );

      if (!mounted) return;

      setState(() {
        articles = news;
        isLoading = false;
        hasMore = news.isNotEmpty;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _searchNews() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      await _loadNews();
      return;
    }

    setState(() {
      isLoading = true;
      isLoadingMore = false;
      errorMessage = null;
      isSearching = true;
      currentPage = 1;
      hasMore = true;
      articles = [];
    });

    try {
      final news = await _newsService.searchNews(
        query,
        page: currentPage,
      );

      if (!mounted) return;

      setState(() {
        articles = news;
        isLoading = false;
        hasMore = news.isNotEmpty;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadCategory(String category) async {
    _searchController.clear();

    setState(() {
      isLoading = true;
      isLoadingMore = false;
      errorMessage = null;
      isSearching = false;
      selectedCategory = category;
      currentPage = 1;
      hasMore = true;
      articles = [];
    });

    try {
      final List<NewsArticle> news;

      if (category == 'general') {
        news = await _newsService.getTopHeadlines(
          page: currentPage,
        );
      } else {
        news = await _newsService.getNewsByCategory(
          category,
          page: currentPage,
        );
      }

      if (!mounted) return;

      setState(() {
        articles = news;
        isLoading = false;
        hasMore = news.isNotEmpty;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _refreshNews() async {
    if (isLoading || isRefreshing || isLoadingMore) {
      return;
    }

    setState(() {
      isRefreshing = true;
    });

    try {
      final List<NewsArticle> news;

      if (isSearching &&
          _searchController.text.trim().isNotEmpty) {
        news = await _newsService.searchNews(
          _searchController.text.trim(),
          page: 1,
        );
      } else if (selectedCategory == 'general') {
        news = await _newsService.getTopHeadlines(
          page: 1,
        );
      } else {
        news = await _newsService.getNewsByCategory(
          selectedCategory,
          page: 1,
        );
      }

      if (!mounted) return;

      setState(() {
        articles = news;
        currentPage = 1;
        hasMore = news.isNotEmpty;
        errorMessage = null;
        isRefreshing = false;
      });

      await _loadFavorites();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isRefreshing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not refresh news. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> _loadMoreNews() async {
    if (isLoading ||
        isLoadingMore ||
        isRefreshing ||
        !hasMore) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    final nextPage = currentPage + 1;

    try {
      List<NewsArticle> newArticles;

      if (isSearching) {
        newArticles = await _newsService.searchNews(
          _searchController.text.trim(),
          page: nextPage,
        );
      } else if (selectedCategory == 'general') {
        newArticles =
            await _newsService.getTopHeadlines(
          page: nextPage,
        );
      } else {
        newArticles =
            await _newsService.getNewsByCategory(
          selectedCategory,
          page: nextPage,
        );
      }

      if (!mounted) return;

      setState(() {
        final existingUrls = articles
            .map((article) => article.articleUrl)
            .toSet();

        final uniqueArticles = newArticles
            .where(
              (article) =>
                  !existingUrls.contains(
                    article.articleUrl,
                  ),
            )
            .toList();

        if (newArticles.isEmpty ||
            uniqueArticles.isEmpty) {
          hasMore = false;
        } else {
          articles.addAll(uniqueArticles);
          currentPage = nextPage;
        }

        isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingMore = false;
      });

      debugPrint('Load more news error: $e');
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _loadNews();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  // Open the article details page and refresh saved status
  // when the user returns to Home.
  Future<void> _openArticle(NewsArticle article) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleScreen(
          article: article,
        ),
      ),
    );

    if (!mounted) return;

    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: HomeAppBar(
        isDark: isDark,
        onToggleTheme: _toggleTheme,
        onRefresh: _refreshNews,
      ),
      body: Column(
        children: [
          NewsSearchBar(
            controller: _searchController,
            isDark: isDark,
            onSearch: _searchNews,
            onClear: _clearSearch,
            onChanged: _onSearchChanged,
          ),
          NewsCategories(
            categories: categories,
            selectedCategory: selectedCategory,
            isDark: isDark,
            onCategorySelected: _loadCategory,
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final isDark =
        themeNotifier.value == ThemeMode.dark;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshNews,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (articles.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshNews,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 300,
              child: Center(
                child: Text(
                  isSearching
                      ? 'No news found.'
                      : 'No news available.',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshNews,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount:
            articles.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == articles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final article = articles[index];
          final isFavorite =
              favoriteUrls.contains(
            article.articleUrl,
          );

          return NewsCard(
            article: article,
            isFavorite: isFavorite,
            onFavorite: () =>
                _toggleFavorite(article),
            onTap: () => _openArticle(article),
          );
        },
      ),
    );
  }
}