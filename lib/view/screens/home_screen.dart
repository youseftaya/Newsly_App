import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/news_article.dart';
import '../../data/services/firestore_service.dart';
import '../../main.dart';
import '../../providers/news_provider.dart';
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
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _searchController =
      TextEditingController();

  final ScrollController _scrollController = ScrollController();

  Set<String> favoriteUrls = {};

  final List<Map<String, String>> categories = [
    {'name': 'General', 'value': 'general'},
    {'name': 'Business', 'value': 'business'},
    {'name': 'Technology', 'value': 'technology'},
    {'name': 'Sports', 'value': 'sports'},
    {'name': 'Entertainment', 'value': 'entertainment'},
    {'name': 'Health', 'value': 'health'},
    {'name': 'Science', 'value': 'science'},
  ];

  bool get _isArabic => localeNotifier.value.languageCode == 'ar';

  String _text(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<NewsProvider>();

      if (widget.initialCategory == 'general') {
        provider.loadNews();
      } else {
        provider.loadCategory(widget.initialCategory);
      }

      _loadFavorites();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _firestoreService.getFavorites();

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

  Future<void> _toggleFavorite(NewsArticle article) async {
    final isFavorite = favoriteUrls.contains(article.articleUrl);

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
            _text(
              'Failed to update saved news.',
              'فشل تحديث الأخبار المحفوظة.',
            ),
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

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<NewsProvider>().loadMoreNews();
    }
  }

  Future<void> _searchNews() async {
    await context.read<NewsProvider>().searchNews(
          _searchController.text,
        );
  }

  Future<void> _loadCategory(String category) async {
    _searchController.clear();

    await context.read<NewsProvider>().loadCategory(category);
  }

  Future<void> _refreshNews() async {
    await context.read<NewsProvider>().refreshNews();

    if (!mounted) return;

    await _loadFavorites();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<NewsProvider>().loadNews();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _openArticle(NewsArticle article) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleScreen(article: article),
      ),
    );

    if (!mounted) return;

    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.value == ThemeMode.dark;

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
          Consumer<NewsProvider>(
            builder: (context, provider, child) {
              return NewsCategories(
                categories: categories,
                selectedCategory: provider.selectedCategory,
                isDark: isDark,
                onCategorySelected: _loadCategory,
              );
            },
          ),
          Expanded(
            child: Consumer<NewsProvider>(
              builder: (context, provider, child) {
                return _buildBody(provider, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(NewsProvider provider, bool isDark) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null) {
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
                _text(
                  'Could not load news. Please try again.',
                  'تعذر تحميل الأخبار. حاول مرة أخرى.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshNews,
                child: Text(
                  _text('Try Again', 'حاول مرة أخرى'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.articles.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshNews,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 300,
              child: Center(
                child: Text(
                  provider.isSearching
                      ? _text(
                          'No news found.',
                          'لم يتم العثور على أخبار.',
                        )
                      : _text(
                          'No news available.',
                          'لا توجد أخبار متاحة حاليًا.',
                        ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
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
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount:
            provider.articles.length +
            (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.articles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final article = provider.articles[index];
          final isFavorite = favoriteUrls.contains(article.articleUrl);

          return NewsCard(
            article: article,
            isFavorite: isFavorite,
            onFavorite: () => _toggleFavorite(article),
            onTap: () => _openArticle(article),
          );
        },
      ),
    );
  }
}