import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/auth_service.dart';
import '../../main.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _profileImageBytes;

  bool _isLoadingImage = true;
  bool _isSavingName = false;
  bool _notificationsEnabled = true;

  String _displayName = '';
  String _language = 'English';
  String _fontSize = 'Medium';

  @override
  void initState() {
    super.initState();
    _loadProfileSettings();
  }

  // Load saved profile settings.
  Future<void> _loadProfileSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      final savedImage = prefs.getString('newsly_profile_image');
      Uint8List? imageBytes;

      if (savedImage != null) {
        try {
          imageBytes = base64Decode(savedImage);
        } catch (_) {
          await prefs.remove('newsly_profile_image');
        }
      }

      if (!mounted) return;

      setState(() {
        _profileImageBytes = imageBytes;
        _displayName = prefs.getString('newsly_profile_name') ??
            user?.displayName ??
            '';
        _language = prefs.getString('newsly_language') ?? 'English';
        _fontSize = prefs.getString('newsly_font_size') ?? 'Medium';
        _notificationsEnabled =
            prefs.getBool('newsly_notifications_enabled') ?? true;
        _isLoadingImage = false;
      });
    } catch (e) {
      debugPrint('Failed to load profile settings: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingImage = false;
      });
    }
  }

  // Edit and save profile name.
  Future<void> _editName() async {
    final controller = TextEditingController(text: _displayName);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 50,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full name',
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null) return;

    if (newName.isEmpty) {
      _showMessage('Name cannot be empty.');
      return;
    }

    setState(() {
      _isSavingName = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      await prefs.setString('newsly_profile_name', newName);
      await user?.updateDisplayName(newName);

      if (!mounted) return;

      setState(() {
        _displayName = newName;
        _isSavingName = false;
      });

      _showMessage('Name updated successfully.');
    } catch (e) {
      debugPrint('Failed to update name: $e');

      if (!mounted) return;

      setState(() {
        _isSavingName = false;
      });

      _showMessage('Could not update your name.');
    }
  }

  // Select, resize, compress, and save profile image.
  Future<void> _pickProfileImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final originalBytes = await pickedFile.readAsBytes();
      final decodedImage = img.decodeImage(originalBytes);

      if (decodedImage == null) {
        _showMessage('Could not read the selected image.');
        return;
      }

      final resizedImage = img.copyResizeCropSquare(
        decodedImage,
        size: 256,
      );

      final compressedBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: 85),
      );

      final prefs = await SharedPreferences.getInstance();

      final saved = await prefs.setString(
        'newsly_profile_image',
        base64Encode(compressedBytes),
      );

      if (!mounted) return;

      if (!saved) {
        _showMessage('Could not save the image.');
        return;
      }

      setState(() {
        _profileImageBytes = compressedBytes;
      });

      _showMessage('Profile picture updated successfully.');
    } catch (e) {
      debugPrint('Failed to update profile image: $e');

      if (!mounted) return;

      _showMessage('Could not select the image. Please try again.');
    }
  }

  // Remove saved profile image.
  Future<void> _removeProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('newsly_profile_image');

      if (!mounted) return;

      setState(() {
        _profileImageBytes = null;
      });

      _showMessage('Profile picture removed.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Could not remove the profile picture.');
    }
  }

  // Display image options.
  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickProfileImage();
                },
              ),
              if (_profileImageBytes != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text('Remove profile picture'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _removeProfileImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Change language preference.
  Future<void> _chooseLanguage() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Choose Language'),
          children: [
            RadioListTile<String>(
              value: 'English',
              groupValue: _language,
              title: const Text('English'),
              onChanged: (value) {
                Navigator.pop(dialogContext, value);
              },
            ),
            RadioListTile<String>(
              value: 'العربية',
              groupValue: _language,
              title: const Text('العربية'),
              onChanged: (value) {
                Navigator.pop(dialogContext, value);
              },
            ),
          ],
        );
      },
    );

    if (selected == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('newsly_language', selected);

      localeNotifier.value = selected == 'العربية'
          ? const Locale('ar')
          : const Locale('en');

      if (!mounted) return;

      setState(() {
        _language = selected;
      });

      _showMessage(
        'Language saved. Full translation requires localization setup.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('Could not save language preference.');
    }
  }

  // Change font size across the application.
  Future<void> _chooseFontSize() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Choose Font Size'),
          children: [
            for (final size in ['Small', 'Medium', 'Large'])
              RadioListTile<String>(
                value: size,
                groupValue: _fontSize,
                title: Text(size),
                onChanged: (value) {
                  Navigator.pop(dialogContext, value);
                },
              ),
          ],
        );
      },
    );

    if (selected == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('newsly_font_size', selected);

      fontScaleNotifier.value = switch (selected) {
        'Small' => 0.85,
        'Large' => 1.20,
        _ => 1.0,
      };

      if (!mounted) return;

      setState(() {
        _fontSize = selected;
      });

      _showMessage('Font size updated.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Could not save font size preference.');
    }
  }

  // Change and persist theme.
  Future<void> _setDarkMode(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('newsly_dark_mode', enabled);

      themeNotifier.value =
          enabled ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      if (!mounted) return;

      _showMessage('Could not save theme preference.');
    }
  }

  // Save notification preference.
  Future<void> _setNotifications(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
        'newsly_notifications_enabled',
        enabled,
      );

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = enabled;
      });

      _showMessage(
        enabled
            ? 'Notification preference enabled.'
            : 'Notification preference disabled.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('Could not save notification settings.');
    }
  }

  // Sign out.
  Future<void> _logout() async {
    try {
      await AuthService().logout();
    } catch (e) {
      if (!mounted) return;

      _showMessage('Logout failed. Please try again.');
    }
  }

  // Show feedback to user.
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final isDark = theme.brightness == Brightness.dark;

    final name = _displayName.isNotEmpty
        ? _displayName
        : (user?.displayName?.isNotEmpty == true
            ? user!.displayName!
            : 'Add your name');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ProfileHeader(
            imageBytes: _profileImageBytes,
            isLoadingImage: _isLoadingImage,
            isSavingName: _isSavingName,
            name: name,
            email: user?.email ?? 'No email available',
            onPhotoTap: _showPhotoOptions,
            onEditName: _editName,
          ),
          ProfilePreferences(
            isDark: isDark,
            isDarkMode: themeNotifier.value == ThemeMode.dark,
            language: _language,
            fontSize: _fontSize,
            notificationsEnabled: _notificationsEnabled,
            onDarkModeChanged: _setDarkMode,
            onLanguageTap: _chooseLanguage,
            onFontSizeTap: _chooseFontSize,
            onNotificationsChanged: _setNotifications,
            onLogout: _logout,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}