import 'package:flutter/material.dart';

class ProfileSettingsCard extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const ProfileSettingsCard({
    super.key,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isDark
          ? const Color(0xFF29292D)
          : Colors.white,
      child: child,
    );
  }
}