import 'dart:typed_data';

import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final Uint8List? imageBytes;
  final bool isLoadingImage;
  final bool isSavingName;
  final String name;
  final String email;
  final VoidCallback onPhotoTap;
  final VoidCallback onEditName;

  const ProfileHeader({
    super.key,
    required this.imageBytes,
    required this.isLoadingImage,
    required this.isSavingName,
    required this.name,
    required this.email,
    required this.onPhotoTap,
    required this.onEditName,
  });

  static const Color _primaryColor = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 16),

        GestureDetector(
          onTap: onPhotoTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor:
                    _primaryColor.withValues(alpha: 0.15),
                backgroundImage: imageBytes != null
                    ? MemoryImage(imageBytes!)
                    : null,
                child: isLoadingImage
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : imageBytes == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 52,
                            color: _primaryColor,
                          )
                        : null,
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Edit name',
              onPressed: isSavingName ? null : onEditName,
              icon: isSavingName
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.edit_rounded,
                      color: _primaryColor,
                      size: 20,
                    ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          email,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface
                .withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}