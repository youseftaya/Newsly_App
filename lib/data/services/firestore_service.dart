import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/news_article.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _favoritesCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites');
  }

  Future<void> addFavorite(NewsArticle article) async {
    await _favoritesCollection
        .doc(_createDocumentId(article.articleUrl))
        .set({
      'category': article.category,
      'title': article.title,
      'imageUrl': article.imageUrl,
      'description': article.description,
      'articleUrl': article.articleUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(NewsArticle article) async {
    await _favoritesCollection
        .doc(_createDocumentId(article.articleUrl))
        .delete();
  }

  Future<List<NewsArticle>> getFavorites() async {
    final snapshot = await _favoritesCollection
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return NewsArticle(
        category: data['category'] ?? 'News',
        title: data['title'] ?? 'No title',
        imageUrl: data['imageUrl'] ?? '',
        description:
            data['description'] ?? 'No description available.',
        articleUrl: data['articleUrl'] ?? '',
      );
    }).toList();
  }

  Future<bool> isFavorite(NewsArticle article) async {
    final doc = await _favoritesCollection
        .doc(_createDocumentId(article.articleUrl))
        .get();

    return doc.exists;
  }

  String _createDocumentId(String url) {
    return url.hashCode.toString();
  }
}