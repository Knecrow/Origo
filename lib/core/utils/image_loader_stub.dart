// lib/core/utils/image_loader_stub.dart

import 'package:flutter/widgets.dart';

Widget loadLocalImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  required Widget fallback,
}) =>
    fallback;

Future<String> saveLocalImage(String sourcePath) async => sourcePath;

Future<void> deleteLocalImage(String path) async {}
