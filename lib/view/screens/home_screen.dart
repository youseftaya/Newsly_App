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
import 'saved_news_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
  bool hasMore = true;

  String? errorMessage;

  String selectedCategory = 'general';
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

    _scrollController.addListener(_onScroll);

    _loadFavorites();
    _loadNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed: $e',
          ),
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

  void _openSavedNews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SavedNewsScreen(),
      ),
    );
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
    });

    try {
      final news = await _newsService.getTopHeadlines(
        page: currentPage,
      );

      if (!mounted) return;

      setState(() {
        articles = news;
        isLoading = false;

        if (news.isEmpty) {
          hasMore = false;
        }
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
      _loadNews();
      return;
    }

    setState(() {
      isLoading = true;
      isLoadingMore = false;
      errorMessage = null;
      isSearching = true;
      currentPage = 1;
      hasMore = true;
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

        if (news.isEmpty) {
          hasMore = false;
        }
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
    });

    try {
      final news =
          await _newsService.getNewsByCategory(
        category,
        page: currentPage,
      );

      if (!mounted) return;

      setState(() {
        articles = news;
        isLoading = false;

        if (news.isEmpty) {
          hasMore = false;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMoreNews() async {
    if (isLoading || isLoadingMore || !hasMore) return;

    setState(() {
      isLoadingMore = true;
    });

    final nextPage = currentPage + 1;

    try {
      List<NewsArticle> newArticles;

      if (isSearching) {
        final query =
            _searchController.text.trim();

        newArticles =
            await _newsService.searchNews(
          query,
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
        if (newArticles.isEmpty) {
          hasMore = false;
        } else {
          articles.addAll(newArticles);
          currentPage = nextPage;
        }

        isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();

    _loadNews();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: HomeAppBar(
        isDark: isDark,
        onLogout: _logout,
        onSavedNews: _openSavedNews,
        onToggleTheme: _toggleTheme,
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
            mainAxisAlignment:
                MainAxisAlignment.center,
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
                onPressed: () {
                  if (isSearching) {
                    _searchNews();
                  } else {
                    _loadCategory(
                      selectedCategory,
                    );
                  }
                },
                child: const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (articles.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount:
          articles.length +
          (isLoadingMore ? 1 : 0),
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
          onFavorite: () {
            _toggleFavorite(article);
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ArticleScreen(
                  article: article,
                ),
              ),
            );
          },
        );
      },
    );
  }
}