// lib/core/utils/image_loader_io.dart

import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Widget loadLocalImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  required Widget fallback,
}) {
  final file = File(path);
  return Image.file(
    file,
    fit: fit,
    errorBuilder: (_, _, e) => fallback,
  );
}

Future<String> saveLocalImage(String sourcePath) async {
  final appDir = await getApplicationDocumentsDirectory();
  final imagesDir = Directory(p.join(appDir.path, 'origo_images'));
  if (!imagesDir.existsSync()) imagesDir.createSync(recursive: true);
  final fileName =
      '${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}';
  final destPath = p.join(imagesDir.path, fileName);
  await File(sourcePath).copy(destPath);
  return destPath;
}

Future<void> deleteLocalImage(String path) async {
  try {
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  } catch (_) {}
}
