// lib/features/profile/first_time_setup_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/origo_image.dart';

class FirstTimeSetupSheet extends StatefulWidget {
  const FirstTimeSetupSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FirstTimeSetupSheet(),
    );
  }

  @override
  State<FirstTimeSetupSheet> createState() => _FirstTimeSetupSheetState();
}

class _FirstTimeSetupSheetState extends State<FirstTimeSetupSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _mottoCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _customAvatarPath;
  int _selectedAvatarIndex = 0;

  static const List<IconData> _avatarIcons = [
    Icons.person_rounded,
    Icons.auto_awesome_rounded,
    Icons.military_tech_rounded,
    Icons.account_balance_rounded,
    Icons.diamond_rounded,
    Icons.shield_rounded,
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>();
    _nameCtrl.text = profile.name == 'Visionary' ? '' : profile.name;
    _mottoCtrl.text = profile.motto;
    _selectedAvatarIndex = profile.avatarIndex;
    _customAvatarPath = profile.avatarPath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mottoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCustomAvatar() async {
    HapticFeedback.lightImpact();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _customAvatarPath = image.path;
      });
    }
  }

  Future<void> _onCompleteSetup() async {
    HapticFeedback.mediumImpact();
    final name = _nameCtrl.text.trim().isEmpty ? 'Visionary' : _nameCtrl.text.trim();
    final motto = _mottoCtrl.text.trim().isEmpty
        ? 'Manifesting architectural excellence and freedom.'
        : _mottoCtrl.text.trim();

    await context.read<ProfileProvider>().saveProfile(
      name: name,
      motto: motto,
      avatarPath: _customAvatarPath,
      avatarIndex: _selectedAvatarIndex,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161828) : const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 32,
                  offset: const Offset(0, -8),
                ),
              ]
            : [
                BoxShadow(
                  color: const Color(0xFF757E9E).withValues(alpha: 0.2),
                  blurRadius: 28,
                  offset: const Offset(0, -8),
                ),
              ],
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ext.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Title
            Center(
              child: Column(
                children: [
                  Text(
                    'Welcome to Origo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: ext.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Configure your personal visionary profile',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: ext.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 1. Avatar Selector ───────────────────────────────────────
            Text(
              'CHOOSE YOUR AVATAR',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: ext.textMuted,
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: GestureDetector(
                onTap: _pickCustomAvatar,
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF22253B) : const Color(0xFFEFF1FA),
                        boxShadow: isDark
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF7582FF).withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 0),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: const Color(0xFF757E9E).withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: ClipOval(
                        child: _customAvatarPath != null
                            ? OrigoImage(
                                imagePath: _customAvatarPath!,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Icon(
                                  _avatarIcons[_selectedAvatarIndex],
                                  size: 38,
                                  color: isDark ? const Color(0xFF8B96FF) : const Color(0xFF5360ED),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Curated Avatar Preset Grid
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _avatarIcons.length,
                separatorBuilder: (context, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = _customAvatarPath == null && _selectedAvatarIndex == index;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _customAvatarPath = null;
                        _selectedAvatarIndex = index;
                      });
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? (isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED))
                            : (isDark ? const Color(0xFF202338) : const Color(0xFFF0F2FA)),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: (isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED))
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        _avatarIcons[index],
                        size: 20,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : ext.textPrimary),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // ── 2. Name Field ────────────────────────────────────────────
            Text(
              'YOUR NAME OR MONIKER',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: ext.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2236) : const Color(0xFFF3F4FB),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _nameCtrl,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ext.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Alex Mercer',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: ext.textMuted.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── 3. Life Vision Motto Field ───────────────────────────────
            Text(
              'PERSONAL VISION STATEMENT / MOTTO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: ext.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2236) : const Color(0xFFF3F4FB),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _mottoCtrl,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ext.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Pursuing architectural mastery and freedom.',
                  hintStyle: TextStyle(
                    fontSize: 13.5,
                    color: ext.textMuted.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── 4. Complete Action Button ────────────────────────────────
            GestureDetector(
              onTap: _onCompleteSetup,
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(27),
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF7582FF),
                            const Color(0xFF5360ED),
                          ]
                        : [
                            const Color(0xFF5E6BEE),
                            const Color(0xFF4350E0),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5360ED).withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Enter Origo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
