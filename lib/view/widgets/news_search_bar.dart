import 'package:flutter/material.dart';
import '../../main.dart';

class NewsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final VoidCallback onChanged;

  const NewsSearchBar({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onSearch,
    required this.onClear,
    required this.onChanged,
  });

  bool get _isArabic => localeNotifier.value.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onSearch(),
        textDirection: _isArabic
            ? TextDirection.rtl
            : TextDirection.ltr,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: _isArabic
              ? 'ابحث عن الأخبار...'
              : 'Search news...',
          hintTextDirection: _isArabic
              ? TextDirection.rtl
              : TextDirection.ltr,
          hintStyle: TextStyle(
            color: isDark
                ? Colors.grey[500]
                : Colors.grey[600],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey : Colors.grey[700],
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: onClear,
                  tooltip: _isArabic ? 'مسح البحث' : 'Clear search',
                  icon: Icon(
                    Icons.close,
                    color: isDark
                        ? Colors.grey
                        : Colors.grey[700],
                  ),
                )
              : null,
          filled: true,
          fillColor: isDark
              ? const Color(0xFF2C2C2E)
              : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }
}