import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/news_article.dart';
import '../widgets/article_image.dart';

class ArticleScreen extends StatelessWidget {
  final NewsArticle article;

  const ArticleScreen({
    super.key,
    required this.article,
  });

  Future<void> _openArticle(
    BuildContext context,
  ) async {
    if (article.articleUrl.trim().isEmpty) {
      _showMessage(
        context,
        'Article link is not available.',
      );
      return;
    }

    final uri = Uri.tryParse(
      article.articleUrl,
    );

    if (uri == null) {
      _showMessage(
        context,
        'Invalid article link.',
      );
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        _showMessage(
          context,
          'Could not open the article.',
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      _showMessage(
        context,
        'Could not open the article: $e',
      );
    }
  }

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Details News',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            ArticleImage(
              imageUrl: article.imageUrl,
              height: 220,
            ),

            const SizedBox(height: 16),

            Text(
              article.title,
              style: TextStyle(
                color: isDark
                    ? Colors.white
                    : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              article.category,
              style: TextStyle(
                color: isDark
                    ? Colors.grey[400]
                    : Colors.grey[700],
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              article.description,
              style: TextStyle(
                color: isDark
                    ? Colors.grey[300]
                    : Colors.grey[800],
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    article.articleUrl.trim().isEmpty
                        ? null
                        : () => _openArticle(
                              context,
                            ),
                icon: const Icon(
                  Icons.open_in_new,
                ),
                label: const Text(
                  'Read Full Article',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}