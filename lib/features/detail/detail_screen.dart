// lib/features/detail/detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/origo_item.dart';
import '../../core/providers/items_provider.dart';
import '../../core/providers/showcase_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/frosted_glass_container.dart';
import '../../core/widgets/origo_image.dart';

class DetailScreen extends StatefulWidget {
  final OrigoItem item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _showUI = true;
  late OrigoItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  void _toggleUI() => setState(() => _showUI = !_showUI);

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final isShowcase = context.watch<ShowcaseProvider>().isActive;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full-bleed zoomable image
            InteractiveViewer(
              minScale: 0.8,
              maxScale: 5.0,
              child: Center(
                child: OrigoImage(
                  imagePath: _item.imagePath,
                  fit: BoxFit.contain,
                  errorWidget: Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: ext.textMuted,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),

            // Top bar overlay
            AnimatedOpacity(
              opacity: _showUI ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_showUI,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const FrostedGlassContainer(
                            borderRadius: 14,
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (!isShowcase)
                          GestureDetector(
                            onTap: () => _toggleSpotlight(context),
                            child: FrostedGlassContainer(
                              borderRadius: 14,
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                _item.isSpotlight
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: _item.isSpotlight
                                    ? const Color(0xFFFFD700)
                                    : Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom swipe-up info sheet
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              bottom: _showUI ? 0 : -300,
              left: 0,
              right: 0,
              child: _InfoSheet(
                item: _item,
                isShowcase: isShowcase,
                onToggleSpotlight: () => _toggleSpotlight(context),
                onDelete: () => _deleteItem(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleSpotlight(BuildContext context) async {
    await context.read<ItemsProvider>().toggleSpotlight(_item);
    setState(() => _item = _item.copyWith(isSpotlight: !_item.isSpotlight));
  }

  Future<void> _deleteItem(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.ext.cardColor,
        title: Text('Delete Item',
            style: TextStyle(color: context.ext.textPrimary)),
        content: Text('Remove "${_item.title}" from your vision board?',
            style: TextStyle(color: context.ext.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: context.ext.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<ItemsProvider>().deleteItem(_item);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

// ── Info Sheet ─────────────────────────────────────────────────────────────────

class _InfoSheet extends StatelessWidget {
  final OrigoItem item;
  final bool isShowcase;
  final VoidCallback onToggleSpotlight;
  final VoidCallback onDelete;

  const _InfoSheet({
    required this.item,
    required this.isShowcase,
    required this.onToggleSpotlight,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final itemsProv = context.watch<ItemsProvider>();
    final accentColor =
        itemsProv.categoryColors[item.category] ?? ext.accent;
    final categoryIcon =
        itemsProv.categoryIcons[item.category] ?? Icons.category_rounded;
    final displayCategory =
        itemsProv.categoryDisplayNames[item.category] ?? item.category.toUpperCase();

    return FrostedGlassContainer(
      blur: 20,
      borderRadius: 0,
      tint: Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withValues(alpha: 0.6)
          : Colors.white.withValues(alpha: 0.6),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Category pill + title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(categoryIcon,
                              size: 11, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            displayCategory,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                              color: Colors.black54, blurRadius: 6)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isShowcase)
                Row(
                  children: [
                    GestureDetector(
                      onTap: onToggleSpotlight,
                      child: Icon(
                        item.isSpotlight
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: item.isSpotlight
                            ? const Color(0xFFFFD700)
                            : Colors.white60,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 24,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Timeframe
          if (item.targetTimeframe != null &&
              item.targetTimeframe!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    color: Colors.white60, size: 14),
                const SizedBox(width: 6),
                Text(
                  item.targetTimeframe!,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],

          // Notes
          if (item.motivationNotes != null &&
              item.motivationNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote_rounded,
                      color: Colors.white38, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.motivationNotes!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
