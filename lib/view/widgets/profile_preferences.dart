import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),

        Text(
          l10n.preferences,
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
            title: Text(l10n.darkMode),
            subtitle: Text(l10n.changeAppearance),
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
            title: Text(l10n.language),
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
            title: Text(l10n.fontSize),
            subtitle: Text(_translatedFontSize(l10n)),
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
            title: Text(l10n.notifications),
            subtitle: Text(l10n.saveNotificationPreference),
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
            title: Text(l10n.logOut),
            subtitle: Text(l10n.signOutAccount),
            onTap: onLogout,
          ),
        ),
      ],
    );
  }

  String _translatedFontSize(AppLocalizations l10n) {
    switch (fontSize) {
      case 'Small':
        return l10n.small;
      case 'Medium':
        return l10n.medium;
      case 'Large':
        return l10n.large;
      default:
        return fontSize;
    }
  }
}