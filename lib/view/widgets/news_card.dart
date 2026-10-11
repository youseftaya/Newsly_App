import 'package:flutter/material.dart';

import '../../data/models/news_article.dart';
import 'article_image.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const NewsCard({
    super.key,
    required this.article,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 24,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ArticleImage(
                  imageUrl: article.imageUrl,
                  height: 200,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha: 0.65,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: onFavorite,
                      icon: Icon(
                        isFavorite
                            ? Icons.star
                            : Icons.star_border,
                        color: isFavorite
                            ? Colors.amber
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              article.category,
              style: TextStyle(
                color: isDark
                    ? Colors.grey[400]
                    : Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              article.title,
              style: TextStyle(
                color: isDark
                    ? Colors.white
                    : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}