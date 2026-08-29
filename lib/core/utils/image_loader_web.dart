// lib/core/utils/image_loader_web.dart

import 'package:flutter/widgets.dart';

Widget loadLocalImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  required Widget fallback,
}) {
  return fallback;
}

Future<String> saveLocalImage(String sourcePath) async {
  return sourcePath;
}

Future<void> deleteLocalImage(String path) async {}
