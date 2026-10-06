import 'package:flutter/material.dart';

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

          final isSelected =
              selectedCategory ==
                  category['value'];

          return Padding(
            padding: const EdgeInsets.only(
              right: 8,
            ),
            child: ChoiceChip(
              label: Text(
                category['name']!,
              ),
              selected: isSelected,
              onSelected: (_) {
                onCategorySelected(
                  category['value']!,
                );
              },
              selectedColor:
                  const Color(0xFF3B82F6),
              backgroundColor: isDark
                  ? const Color(0xFF2C2C2E)
                  : Colors.white,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? Colors.grey[300]
                        : Colors.black87,
                fontWeight:
                    FontWeight.w500,
              ),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }
}