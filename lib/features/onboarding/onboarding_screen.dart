// lib/features/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/clay_icon_badge.dart';
import '../../core/widgets/origo_image.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _mottoCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int _currentPage = 0;
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

  static const List<String> _suggestedMottos = [
    'Mastery, architectural freedom, and excellence.',
    'Build the future, preserve the vision.',
    'Fearless ambition and enduring legacy.',
    'Crafting a life of uncompromising luxury.',
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _mottoCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < 2) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    HapticFeedback.lightImpact();
    if (_currentPage > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
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

  Future<void> _finishOnboarding() async {
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
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final themeProv = context.watch<ThemeProvider>();
    final isDark = themeProv.isDark;

    return Scaffold(
      backgroundColor: ext.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation & Progress Header ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (shown on steps 2 & 3)
                  _currentPage > 0
                      ? ClayIconBadge(
                          icon: Icons.arrow_back_rounded,
                          size: 19,
                          padding: 9,
                          iconColor: ext.textPrimary,
                          onTap: _prevPage,
                        )
                      : const SizedBox(width: 38, height: 38),

                  // Progress Step Indicator
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isActive
                              ? (isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED))
                              : (isDark ? const Color(0xFF282C46) : const Color(0xFFD6DAEC)),
                        ),
                      );
                    }),
                  ),

                  // Theme Toggle
                  ClayIconBadge(
                    icon: Icons.contrast_rounded,
                    size: 19,
                    padding: 9,
                    iconColor: isDark ? const Color(0xFFFFD60A) : const Color(0xFF5360ED),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      themeProv.toggle();
                    },
                  ),
                ],
              ),
            ),

            // ── Step-by-Step PageView ────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(), // Controlled by buttons
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  // ── Step 1: Name ───────────────────────────────────────
                  _buildStepContainer(
                    context: context,
                    isDark: isDark,
                    icon: Icons.person_outline_rounded,
                    stepLabel: 'STEP 1 OF 3',
                    title: 'What should we call you?',
                    subtitle: 'Enter your name or visionary moniker to personalize your portfolio.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1B1D2E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isDark
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: const Color(0xFF757E9E).withValues(alpha: 0.14),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          child: TextField(
                            controller: _nameCtrl,
                            autofocus: true,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ext.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. Alex Mercer',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: ext.textMuted.withValues(alpha: 0.55),
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _nextPage(),
                          ),
                        ),
                      ],
                    ),
                    buttonText: 'Continue',
                    onButtonPressed: _nextPage,
                  ),

                  // ── Step 2: Personal Vision Motto ──────────────────────
                  _buildStepContainer(
                    context: context,
                    isDark: isDark,
                    icon: Icons.auto_awesome_outlined,
                    stepLabel: 'STEP 2 OF 3',
                    title: 'What is your vision motto?',
                    subtitle: 'A personal life statement that defines your aspirations and daily drive.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1B1D2E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isDark
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: const Color(0xFF757E9E).withValues(alpha: 0.14),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          child: TextField(
                            controller: _mottoCtrl,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ext.textPrimary,
                              height: 1.4,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. Mastery, architectural freedom, and excellence.',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: ext.textMuted.withValues(alpha: 0.55),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Suggested Mottos
                        Text(
                          'INSPIRATIONAL SUGGESTIONS',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: ext.textMuted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _suggestedMottos.map((motto) {
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _mottoCtrl.text = motto;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1F2236) : const Color(0xFFEFF1FA),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  motto,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFF8B96FF) : const Color(0xFF5360ED),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    buttonText: 'Continue',
                    onButtonPressed: _nextPage,
                  ),

                  // ── Step 3: Avatar Selection ───────────────────────────
                  _buildStepContainer(
                    context: context,
                    isDark: isDark,
                    icon: Icons.diamond_outlined,
                    stepLabel: 'STEP 3 OF 3',
                    title: 'Select your signature avatar',
                    subtitle: 'Choose a luxury 3D ceramic emblem or upload your personal portrait.',
                    child: Column(
                      children: [
                        // Large Avatar Preview Circle
                        GestureDetector(
                          onTap: _pickCustomAvatar,
                          child: Stack(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? const Color(0xFF1B1D2E) : Colors.white,
                                  boxShadow: isDark
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFF7582FF).withValues(alpha: 0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 0),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: const Color(0xFF757E9E).withValues(alpha: 0.22),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
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
                                            size: 46,
                                            color: isDark ? const Color(0xFF8B96FF) : const Color(0xFF5360ED),
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap avatar to choose custom photo',
                          style: TextStyle(fontSize: 12, color: ext.textMuted),
                        ),
                        const SizedBox(height: 24),

                        // Preset Avatar Grid
                        SizedBox(
                          height: 52,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _avatarIcons.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
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
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? (isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED))
                                        : (isDark ? const Color(0xFF1E2136) : const Color(0xFFEFF1FA)),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: (isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED))
                                                  .withValues(alpha: 0.45),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    _avatarIcons[index],
                                    size: 24,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : ext.textPrimary),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    buttonText: 'Enter Origo',
                    onButtonPressed: _finishOnboarding,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContainer({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String stepLabel,
    required String title,
    required String subtitle,
    required Widget child,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    final ext = context.ext;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2136) : const Color(0xFFECEFFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 13,
                  color: isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED),
                ),
                const SizedBox(width: 6),
                Text(
                  stepLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: ext.textPrimary,
              letterSpacing: -0.6,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: ext.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Main Step Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: child,
            ),
          ),

          // Bottom Action Button
          GestureDetector(
            onTap: onButtonPressed,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
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
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
