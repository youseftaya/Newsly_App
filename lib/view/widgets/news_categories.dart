import 'package:flutter/material.dart';
import '../../main.dart';

class NewsCategories extends StatelessWidget {
  final List<Map<String, String>> categories;
  final String selectedCategory;
  final bool isDark;
  final ValueChanged<String> onCategorySelected;

  const NewsCategories({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.isDark,
    required this.onCategorySelected,
  });

  bool get _isArabic => localeNotifier.value.languageCode == 'ar';

  String _translatedCategory(String value) {
    if (!_isArabic) {
      switch (value) {
        case 'general':
          return 'General';
        case 'business':
          return 'Business';
        case 'technology':
          return 'Technology';
        case 'sports':
          return 'Sports';
        case 'entertainment':
          return 'Entertainment';
        case 'health':
          return 'Health';
        case 'science':
          return 'Science';
        default:
          return value;
      }
    }

    switch (value) {
      case 'general':
        return 'عام';
      case 'business':
        return 'أعمال';
      case 'technology':
        return 'تكنولوجيا';
      case 'sports':
        return 'رياضة';
      case 'entertainment':
        return 'ترفيه';
      case 'health':
        return 'صحة';
      case 'science':
        return 'علوم';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final categoryValue = category['value']!;

          final isSelected =
              selectedCategory == categoryValue;

          return Padding(
            padding: EdgeInsets.only(
              right: _isArabic ? 0 : 8,
              left: _isArabic ? 8 : 0,
            ),
            child: ChoiceChip(
              label: Text(
                _translatedCategory(categoryValue),
              ),
              selected: isSelected,
              onSelected: (_) {
                onCategorySelected(categoryValue);
              },
              selectedColor: const Color(0xFF3B82F6),
              backgroundColor: isDark
                  ? const Color(0xFF2C2C2E)
                  : Colors.white,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? Colors.grey[300]
                        : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }
}