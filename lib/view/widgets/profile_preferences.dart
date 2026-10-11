import 'package:flutter/material.dart';

import 'profile_settings_card.dart';

class ProfilePreferences extends StatelessWidget {
  final bool isDark;
  final bool isDarkMode;
  final String language;
  final String fontSize;
  final bool notificationsEnabled;

  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onLanguageTap;
  final VoidCallback onFontSizeTap;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onLogout;

  const ProfilePreferences({
    super.key,
    required this.isDark,
    required this.isDarkMode,
    required this.language,
    required this.fontSize,
    required this.notificationsEnabled,
    required this.onDarkModeChanged,
    required this.onLanguageTap,
    required this.onFontSizeTap,
    required this.onNotificationsChanged,
    required this.onLogout,
  });

  static const Color _primaryColor = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),

        Text(
          'Preferences',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        // Dark mode.
        ProfileSettingsCard(
          isDark: isDark,
          child: SwitchListTile(
            secondary: Icon(
              isDarkMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              color: _primaryColor,
            ),
            title: const Text('Dark Mode'),
            subtitle: const Text(
              'Change the appearance of Newsly',
            ),
            value: isDarkMode,
            activeTrackColor: _primaryColor,
            onChanged: onDarkModeChanged,
          ),
        ),

        const SizedBox(height: 12),

        // Language.
        ProfileSettingsCard(
          isDark: isDark,
          child: ListTile(
            leading: const Icon(
              Icons.language_rounded,
              color: _primaryColor,
            ),
            title: const Text('Language'),
            subtitle: Text(language),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
            onTap: onLanguageTap,
          ),
        ),

        const SizedBox(height: 12),

        // Font size.
        ProfileSettingsCard(
          isDark: isDark,
          child: ListTile(
            leading: const Icon(
              Icons.text_fields_rounded,
              color: _primaryColor,
            ),
            title: const Text('Font Size'),
            subtitle: Text(fontSize),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
            onTap: onFontSizeTap,
          ),
        ),

        const SizedBox(height: 12),

        // Notifications.
        ProfileSettingsCard(
          isDark: isDark,
          child: SwitchListTile(
            secondary: const Icon(
              Icons.notifications_active_outlined,
              color: _primaryColor,
            ),
            title: const Text('Notifications'),
            subtitle: const Text(
              'Save your notification preference',
            ),
            value: notificationsEnabled,
            activeTrackColor: _primaryColor,
            onChanged: onNotificationsChanged,
          ),
        ),

        const SizedBox(height: 12),

        // Logout.
        ProfileSettingsCard(
          isDark: isDark,
          child: ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
            ),
            title: const Text('Log Out'),
            subtitle: const Text(
              'Sign out of your account',
            ),
            onTap: onLogout,
          ),
        ),
      ],
    );
  }
}