// lib/core/widgets/origo_image.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/image_loader.dart' as loader;
import 'shimmer_loading.dart';

class OrigoImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final Widget? errorWidget;

  const OrigoImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final fallback = errorWidget ??
        Container(
          color: ext.cardColor,
          child: Center(
            child: Icon(
              Icons.image_outlined,
              color: ext.textMuted,
              size: 36,
            ),
          ),
        );

    if (imagePath.isEmpty) return fallback;

    // 1. Network image (HTTP / HTTPS)
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: fit,
        cacheWidth: 800,
        errorBuilder: (_, _, e) => fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const ShimmerLoading(
            borderRadius: 0,
          );
        },
      );
    }

    // 2. Base64 Data URL or Blob (Used on Web for offline local persistence)
    if (imagePath.startsWith('data:image') || imagePath.startsWith('blob:')) {
      if (imagePath.startsWith('data:image')) {
        try {
          final commaIdx = imagePath.indexOf(',');
          final base64Str =
              commaIdx != -1 ? imagePath.substring(commaIdx + 1) : imagePath;
          final bytes = base64Decode(base64Str);
          return Image.memory(
            bytes,
            fit: fit,
            cacheWidth: 800,
            errorBuilder: (_, _, e) => fallback,
          );
        } catch (_) {
          return fallback;
        }
      }
      return Image.network(
        imagePath,
        fit: fit,
        cacheWidth: 800,
        errorBuilder: (_, _, e) => fallback,
      );
    }

    // 3. Local File System Image (Mobile / Desktop)
    if (!kIsWeb) {
      return loader.loadLocalImage(
        imagePath,
        fit: fit,
        fallback: fallback,
      );
    }

    return fallback;
  }
}
