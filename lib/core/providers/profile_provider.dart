// lib/core/providers/profile_provider.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  static const String _keyName = 'profile_user_name';
  static const String _keyMotto = 'profile_user_motto';
  static const String _keyAvatarPath = 'profile_user_avatar_path';
  static const String _keyAvatarIndex = 'profile_user_avatar_index';
  static const String _keyFirstLaunch = 'profile_first_launch_done';

  String _name = 'Visionary';
  String _motto = 'Manifesting architectural excellence and freedom.';
  String? _avatarPath;
  int _avatarIndex = 0;
  bool _isFirstLaunchDone = false;
  bool _loaded = false;

  String get name => _name;
  String get motto => _motto;
  String? get avatarPath => _avatarPath;
  int get avatarIndex => _avatarIndex;
  bool get isFirstLaunchDone => _isFirstLaunchDone;
  bool get isLoaded => _loaded;

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunchDone = prefs.getBool(_keyFirstLaunch) ?? false;
    _name = prefs.getString(_keyName) ?? 'Visionary';
    _motto = prefs.getString(_keyMotto) ?? 'Manifesting architectural excellence and freedom.';
    _avatarPath = prefs.getString(_keyAvatarPath);
    _avatarIndex = prefs.getInt(_keyAvatarIndex) ?? 0;
    _loaded = true;
    notifyListeners();
  }

  Future<void> saveProfile({
    required String name,
    required String motto,
    String? avatarPath,
    int? avatarIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _name = name.trim().isEmpty ? 'Visionary' : name.trim();
    _motto = motto.trim().isEmpty ? 'Manifesting architectural excellence and freedom.' : motto.trim();
    _avatarPath = avatarPath;
    if (avatarIndex != null) _avatarIndex = avatarIndex;
    _isFirstLaunchDone = true;

    await prefs.setString(_keyName, _name);
    await prefs.setString(_keyMotto, _motto);
    if (_avatarPath != null) {
      await prefs.setString(_keyAvatarPath, _avatarPath!);
    } else {
      await prefs.remove(_keyAvatarPath);
    }
    await prefs.setInt(_keyAvatarIndex, _avatarIndex);
    await prefs.setBool(_keyFirstLaunch, true);

    notifyListeners();
  }
}
