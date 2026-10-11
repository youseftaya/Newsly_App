import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/news_article.dart';
import '../../data/services/firestore_service.dart';
import '../widgets/article_image.dart';

class ArticleScreen extends StatefulWidget {
  final NewsArticle article;

  const ArticleScreen({
    super.key,
    required this.article,
  });

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool isFavorite = false;
  bool isLoadingFavorite = true;
  bool isSavingFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    if (FirebaseAuth.instance.currentUser == null) {
      if (mounted) {
        setState(() => isLoadingFavorite = false);
      }
      return;
    }

    try {
      final saved = await _firestoreService.isFavorite(
        widget.article,
      );

      if (!mounted) return;

      setState(() {
        isFavorite = saved;
        isLoadingFavorite = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingFavorite = false);
      debugPrint('Could not load favorite: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (isSavingFavorite) return;

    if (FirebaseAuth.instance.currentUser == null) {
      _showMessage('Please log in to save articles.');
      return;
    }

    setState(() => isSavingFavorite = true);

    try {
      if (isFavorite) {
        await _firestoreService.removeFavorite(
          widget.article,
        );
      } else {
        await _firestoreService.addFavorite(
          widget.article,
        );
      }

      if (!mounted) return;

      setState(() {
        isFavorite = !isFavorite;
        isSavingFavorite = false;
      });

      _showMessage(
        isFavorite
            ? 'Article added to Saved News.'
            : 'Article removed from Saved News.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isSavingFavorite = false);

      _showMessage('Could not update saved news. Please try again.');
      debugPrint('Favorite error: $e');
    }
  }

  Future<void> _shareArticle() async {
    final url = widget.article.articleUrl.trim();

    if (url.isEmpty) {
      _showMessage('Article link is not available.');
      return;
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          subject: widget.article.title,
          text: '${widget.article.title}\n$url',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not share the article.');
    }
  }

  Future<void> _openArticle() async {
    final uri = Uri.tryParse(widget.article.articleUrl);

    if (uri == null ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty) {
      _showMessage('Article link is not available.');
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        _showMessage('Could not open the article.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Could not open the article.');
      }
    }
  }

  String? _formatDate(String? value) {
    if (value == null || value.isEmpty) return null;

    final date = DateTime.tryParse(value);
    if (date == null) return null;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final primaryText =
        isDark ? Colors.white : Colors.black87;

    final secondaryText =
        isDark ? Colors.grey[400] : Colors.grey[700];

    final publishedDate = _formatDate(article.publishedAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'News Details',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _shareArticle,
            tooltip: 'Share article',
            icon: const Icon(
              Icons.share_rounded,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed:
                isSavingFavorite ? null : _toggleFavorite,
            tooltip: isFavorite
                ? 'Remove from Saved News'
                : 'Save article',
            icon: isSavingFavorite || isLoadingFavorite
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: isFavorite
                        ? Colors.amber
                        : Colors.white,
                    size: 28,
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ArticleImage(
                imageUrl: article.imageUrl,
                height: 230,
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                article.category,
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              article.title,
              style: TextStyle(
                color: primaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.public_rounded,
                  size: 18,
                  color: secondaryText,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    article.category,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (publishedDate != null) ...[
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 15,
                    color: secondaryText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    publishedDate,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'About this story',
              style: TextStyle(
                color: primaryText,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              article.description,
              style: TextStyle(
                color: isDark
                    ? Colors.grey[300]
                    : Colors.grey[800],
                fontSize: 16,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openArticle,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text(
                  'Read Full Article',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}