import 'package:flutter/material.dart';

import '../../data/models/news_article.dart';
import '../../main.dart';
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

  bool get _isArabic => localeNotifier.value.languageCode == 'ar';

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
                      tooltip: isFavorite
                          ? (_isArabic
                              ? 'إزالة من المحفوظات'
                              : 'Remove from saved news')
                          : (_isArabic
                              ? 'حفظ الخبر'
                              : 'Save article'),
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
            Align(
              alignment: _isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                article.category,
                textAlign: _isArabic
                    ? TextAlign.right
                    : TextAlign.left,
                style: TextStyle(
                  color: isDark
                      ? Colors.grey[400]
                      : Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: _isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                article.title,
                textDirection: _isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                textAlign: _isArabic
                    ? TextAlign.right
                    : TextAlign.left,
                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}