import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onRefresh;

  const HomeAppBar({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    required this.onRefresh,
  });

  @override
  State<HomeAppBar> createState() =>
      _HomeAppBarState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends State<HomeAppBar> {
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final savedImage =
          prefs.getString('newsly_profile_image');

      if (!mounted) return;

      setState(() {
        _profileImageBytes = savedImage != null
            ? base64Decode(savedImage)
            : null;
      });
    } catch (e) {
      debugPrint(
        'Error loading profile image: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor = widget.isDark
        ? Colors.white
        : Colors.black87;

    return AppBar(
      centerTitle: true,
      leadingWidth: 60,

      // Profile picture
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Center(
          child: CircleAvatar(
            radius: 19,
            backgroundColor: widget.isDark
                ? Colors.white24
                : Colors.black12,
            backgroundImage:
                _profileImageBytes != null
                    ? MemoryImage(
                        _profileImageBytes!,
                      )
                    : null,
            child: _profileImageBytes == null
                ? Icon(
                    Icons.person,
                    color: foregroundColor,
                    size: 23,
                  )
                : null,
          ),
        ),
      ),

      // App title
      title: Text(
        'Newsly',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: foregroundColor,
        ),
      ),

      actions: [
        IconButton(
          onPressed: widget.onRefresh,
          icon: Icon(
            Icons.refresh_rounded,
            color: foregroundColor,
          ),
          tooltip: 'Refresh News',
        ),
        IconButton(
          onPressed: widget.onToggleTheme,
          icon: Icon(
            widget.isDark
                ? Icons.light_mode
                : Icons.dark_mode,
            color: foregroundColor,
          ),
          tooltip: widget.isDark
              ? 'Light Mode'
              : 'Dark Mode',
        ),
      ],
    );
  }
}