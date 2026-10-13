import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/app_localizations.dart';
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

  bool get _isArabic => localeNotifier.value.languageCode == 'ar';

  String _text(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  @override
  void initState() {
    super.initState();
    _loadProfileSettings();
  }

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
        _displayName =
            prefs.getString('newsly_profile_name') ??
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

  Future<void> _editName() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: _displayName);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.editName),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 50,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.fullName,
              hintText: l10n.enterName,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text.trim());
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null) return;

    if (newName.isEmpty) {
      _showMessage(l10n.nameCannotBeEmpty);
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

      _showMessage(l10n.nameUpdated);
    } catch (e) {
      debugPrint('Failed to update name: $e');

      if (!mounted) return;

      setState(() {
        _isSavingName = false;
      });

      _showMessage(l10n.nameUpdateFailed);
    }
  }

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
        _showMessage(
          _text(
            'Could not read the selected image.',
            'تعذرت قراءة الصورة المحددة.',
          ),
        );
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
        _showMessage(
          _text('Could not save the image.', 'تعذر حفظ الصورة.'),
        );
        return;
      }

      setState(() {
        _profileImageBytes = compressedBytes;
      });

      _showMessage(AppLocalizations.of(context).profilePictureUpdated);
    } catch (e) {
      debugPrint('Failed to update profile image: $e');

      if (!mounted) return;

      _showMessage(
        _text(
          'Could not select the image. Please try again.',
          'تعذر اختيار الصورة. حاول مرة أخرى.',
        ),
      );
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('newsly_profile_image');

      if (!mounted) return;

      setState(() {
        _profileImageBytes = null;
      });

      _showMessage(AppLocalizations.of(context).profilePictureRemoved);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _text(
          'Could not remove the profile picture.',
          'تعذر حذف الصورة الشخصية.',
        ),
      );
    }
  }

  void _showPhotoOptions() {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(l10n.chooseFromGallery),
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
                  title: Text(l10n.removeProfilePicture),
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

  Future<void> _chooseLanguage() async {
    final l10n = AppLocalizations.of(context);

    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(l10n.chooseLanguage),
          children: [
            RadioGroup<String>(
              groupValue: _language,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(dialogContext, value);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    value: 'English',
                    title: Text(l10n.english),
                  ),
                  RadioListTile<String>(
                    value: 'العربية',
                    title: Text(l10n.arabic),
                  ),
                ],
              ),
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
        _text(
          'Language updated successfully.',
          'تم تغيير اللغة بنجاح.',
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _text(
          'Could not save language preference.',
          'تعذر حفظ إعداد اللغة.',
        ),
      );
    }
  }

  Future<void> _chooseFontSize() async {
    final l10n = AppLocalizations.of(context);

    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(
            _text('Choose Font Size', 'اختر حجم الخط'),
          ),
          children: [
            RadioGroup<String>(
              groupValue: _fontSize,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(dialogContext, value);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    value: 'Small',
                    title: Text(l10n.small),
                  ),
                  RadioListTile<String>(
                    value: 'Medium',
                    title: Text(l10n.medium),
                  ),
                  RadioListTile<String>(
                    value: 'Large',
                    title: Text(l10n.large),
                  ),
                ],
              ),
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

      _showMessage(AppLocalizations.of(context).fontSizeUpdated);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _text(
          'Could not save font size preference.',
          'تعذر حفظ إعداد حجم الخط.',
        ),
      );
    }
  }

  Future<void> _setDarkMode(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('newsly_dark_mode', enabled);

      themeNotifier.value =
          enabled ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _text(
          'Could not save theme preference.',
          'تعذر حفظ إعداد المظهر.',
        ),
      );
    }
  }

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
            ? _text(
                'Notifications enabled.',
                'تم تفعيل الإشعارات.',
              )
            : _text(
                'Notifications disabled.',
                'تم إيقاف الإشعارات.',
              ),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _text(
          'Could not save notification settings.',
          'تعذر حفظ إعدادات الإشعارات.',
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await AuthService().logout();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _text(
          'Logout failed. Please try again.',
          'فشل تسجيل الخروج. حاول مرة أخرى.',
        ),
      );
    }
  }

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
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final isDark = theme.brightness == Brightness.dark;

    final name = _displayName.isNotEmpty
        ? _displayName
        : (user?.displayName?.isNotEmpty == true
            ? user!.displayName!
            : l10n.addYourName);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.profile,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
            email: user?.email ?? l10n.noEmail,
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