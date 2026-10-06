import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isDark;
  final VoidCallback onLogout;
  final VoidCallback onSavedNews;
  final VoidCallback onToggleTheme;

  const HomeAppBar({
    super.key,
    required this.isDark,
    required this.onLogout,
    required this.onSavedNews,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: onLogout,
        icon: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(3.14159),
          child: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
        ),
        tooltip: 'Logout',
      ),
      title: const Text(
        'Newsly',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onSavedNews,
          icon: const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          tooltip: 'Saved News',
        ),
        IconButton(
          onPressed: onToggleTheme,
          icon: Icon(
            isDark
                ? Icons.light_mode
                : Icons.dark_mode,
            color: Colors.white,
          ),
          tooltip:
              isDark ? 'Light Mode' : 'Dark Mode',
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}