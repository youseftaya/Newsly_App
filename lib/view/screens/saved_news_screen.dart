import 'package:flutter/material.dart';

import '../../data/models/news_article.dart';
import '../../data/services/firestore_service.dart';
import '../widgets/news_card.dart';
import 'article_screen.dart';

class SavedNewsScreen extends StatefulWidget {
  const SavedNewsScreen({super.key});

  @override
  State<SavedNewsScreen> createState() =>
      _SavedNewsScreenState();
}

class _SavedNewsScreenState
    extends State<SavedNewsScreen> {
  final FirestoreService _firestoreService =
      FirestoreService();

  List<NewsArticle> favorites = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final savedArticles =
          await _firestoreService.getFavorites();

      if (!mounted) return;

      setState(() {
        favorites = savedArticles;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load saved news: $e',
          ),
        ),
      );
    }
  }

  Future<void> _removeFavorite(
    NewsArticle article,
  ) async {
    try {
      await _firestoreService.removeFavorite(
        article,
      );

      if (!mounted) return;

      setState(() {
        favorites.removeWhere(
          (item) =>
              item.articleUrl ==
              article.articleUrl,
        );
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to remove saved news: $e',
          ),
        ),
      );
    }
  }

  void _openArticle(NewsArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ArticleScreen(
          article: article,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved News',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.star_border,
              size: 70,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No saved news yet.',
              style: TextStyle(
                color: isDark
                    ? Colors.white
                    : Colors.black87,
                fontSize: 17,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final article = favorites[index];

        return NewsCard(
          article: article,
          isFavorite: true,
          onFavorite: () {
            _removeFavorite(article);
          },
          onTap: () {
            _openArticle(article);
          },
        );
      },
    );
  }
}