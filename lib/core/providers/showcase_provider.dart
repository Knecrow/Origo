// lib/core/providers/showcase_provider.dart

import 'package:flutter/material.dart';

class ShowcaseProvider extends ChangeNotifier {
  bool _active = false;

  bool get isActive => _active;

  void toggle() {
    _active = !_active;
    notifyListeners();
  }
}
