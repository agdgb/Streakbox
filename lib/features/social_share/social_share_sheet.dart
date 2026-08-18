import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_preset.dart';
import '../../data/models/habit.dart';
import '../../state/habit_providers.dart';
import '../../state/pro_entitlement_provider.dart';
import '../../state/theme_preset_provider.dart';
import 'social_share_card.dart';

/// Modal sheet for customizing and sharing high-res habit celebration cards.
class SocialShareSheet extends ConsumerStatefulWidget {
  final Habit habit;
  final ShareCardType initialCardType;

  const SocialShareSheet({
    super.key,
    required this.habit,
    this.initialCardType = ShareCardType.streakMilestone,
  });

  /// Presents the social share sheet for the given habit.
  static Future<void> show(
    BuildContext context, {
    required Habit habit,
    ShareCardType initialCardType = ShareCardType.streakMilestone,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SocialShareSheet(
        habit: habit,
        initialCardType: initialCardType,
      ),
    );
  }

  @override
  ConsumerState<SocialShareSheet> createState() => _SocialShareSheetState();
}

class _SocialShareSheetState extends ConsumerState<SocialShareSheet> {
  final GlobalKey _boundaryKey = GlobalKey();
  ShareAspectRatio _aspectRatio = ShareAspectRatio.story;
  late ShareCardType _cardType;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _cardType = widget.initialCardType;
  }

  Future<void> _captureAndShare() async {
    setState(() => _isGenerating = true);
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/streakbox_${widget.habit.name.toLowerCase().replaceAll(' ', '_')}_share.png');
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '🔥 Keeping my "${widget.habit.name}" streak alive with Streakbox! #Streakbox #HabitBuilding',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not generate share image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themePreset = ref.watch(themePresetProvider);
    final isDark = themePreset.isDark;
    final proState = ref.watch(proEntitlementProvider);
    final currentStreak = ref.watch(currentStreakProvider);
    final bestStreak = ref.watch(bestStreakProvider);
    final entriesAsync = ref.watch(selectedHabitEntriesProvider);
    final checkedDates = entriesAsync.asData?.value ?? {};
    final totalCompletions = checkedDates.length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: themePreset.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: themePreset.textSecondaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Share Celebration Card',
                    style: AppTextStyles.titleMedium(context).copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Card Template Switcher (Pills)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTemplateChip('🔥 Streak Flame', ShareCardType.streakMilestone),
                          const SizedBox(width: 8),
                          _buildTemplateChip('📅 12-Month Matrix', ShareCardType.matrixHeatmap),
                          const SizedBox(width: 8),
                          _buildTemplateChip('🏆 Milestone Seal', ShareCardType.achievementBadge),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Aspect Ratio Selector (Story vs Square)
                    SegmentedButton<ShareAspectRatio>(
                      segments: const [
                        ButtonSegment(
                          value: ShareAspectRatio.story,
                          icon: Icon(Icons.stay_current_portrait_rounded, size: 16),
                          label: Text('Story (9:16)', style: TextStyle(fontSize: 12)),
                        ),
                        ButtonSegment(
                          value: ShareAspectRatio.square,
                          icon: Icon(Icons.crop_square_rounded, size: 16),
                          label: Text('Post (1:1)', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                      selected: {_aspectRatio},
                      onSelectionChanged: (set) {
                        setState(() => _aspectRatio = set.first);
                      },
                    ),
                    const SizedBox(height: 20),

                    // The Rendered Snapshot Card (Wrapped in RepaintBoundary for 4K export)
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: _aspectRatio == ShareAspectRatio.story ? 280 : 320,
                        ),
                        child: RepaintBoundary(
                          key: _boundaryKey,
                          child: SocialShareCardWidget(
                            habit: widget.habit,
                            currentStreak: currentStreak,
                            bestStreak: bestStreak,
                            totalCompletions: totalCompletions,
                            checkedDates: checkedDates,
                            themePreset: themePreset,
                            aspectRatio: _aspectRatio,
                            cardType: _cardType,
                            isProUser: proState.isPro,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary Action Button (Share Card)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _isGenerating ? null : _captureAndShare,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Icon(Icons.share_rounded, size: 20, color: Colors.black),
                        label: Text(
                          _isGenerating ? 'Generating 4K Image...' : 'Share to Instagram / WhatsApp / X',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: themePreset.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChip(String label, ShareCardType type) {
    final themePreset = ref.watch(themePresetProvider);
    final isSelected = _cardType == type;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => setState(() => _cardType = type),
      selectedColor: themePreset.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: themePreset.primaryColor,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        color: isSelected ? themePreset.primaryColor : null,
      ),
      side: BorderSide(
        color: isSelected ? themePreset.primaryColor : themePreset.borderColor,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
