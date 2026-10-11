import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  final ValueChanged<String> onCategorySelected;

  const ExploreScreen({
    super.key,
    required this.onCategorySelected,
  });

  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'General',
      'value': 'general',
      'icon': Icons.public_rounded,
    },
    {
      'name': 'Technology',
      'value': 'technology',
      'icon': Icons.computer_rounded,
    },
    {
      'name': 'Business',
      'value': 'business',
      'icon': Icons.business_center_rounded,
    },
    {
      'name': 'Sports',
      'value': 'sports',
      'icon': Icons.sports_soccer_rounded,
    },
    {
      'name': 'Entertainment',
      'value': 'entertainment',
      'icon': Icons.movie_rounded,
    },
    {
      'name': 'Science',
      'value': 'science',
      'icon': Icons.science_rounded,
    },
    {
      'name': 'Health',
      'value': 'health',
      'icon': Icons.health_and_safety_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Discover your interests',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a category to explore the latest news.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface
                  .withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];

              return Material(
                color: isDark
                    ? const Color(0xFF29292D)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onCategorySelected(
                    category['value'] as String,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6)
                                .withValues(alpha: 0.13),
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: Icon(
                            category['icon'] as IconData,
                            color: const Color(0xFF3B82F6),
                            size: 26,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                category['name'] as String,
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Color(0xFF3B82F6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}