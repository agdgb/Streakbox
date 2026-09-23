import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_preset.dart';
import '../../state/auth_provider.dart';
import '../../state/cloud_vault_provider.dart';
import '../../state/habit_providers.dart';
import '../../state/pro_entitlement_provider.dart';
import '../../state/repository_provider.dart';
import '../../state/settings_provider.dart';
import '../../state/theme_preset_provider.dart';
import '../paywall/paywall_sheet.dart';

/// Ultra-Premium Settings & Data Vault screen designed with modern iOS/Linear aesthetics
/// and support for the Nordic Noir / Neumorphic Theme Engine & 48-Hour Pro Free Trial.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isLoading = false;

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(habitRepositoryProvider);
      final jsonString = await repository.exportBackupJsonString();

      await Clipboard.setData(ClipboardData(text: jsonString));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Backup JSON copied to clipboard successfully!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
            content: Text('Export failed: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showImportDialog() async {
    final textController = TextEditingController();
    bool overwrite = false;

    final shouldImport = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.download_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Restore from JSON', style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paste your previously exported Streakbox JSON data below:',
                  style: AppTextStyles.bodySmall(context),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: textController,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText: '{\n  "version": 1,\n  "habits": [...]\n}',
                    filled: true,
                    fillColor: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.roundedSm,
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: overwrite,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setDialogState(() {
                            overwrite = val ?? false;
                          });
                        },
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Overwrite existing habits (replaces current data)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: overwrite ? FontWeight.w700 : FontWeight.w500,
                            color: overwrite ? AppColors.error : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.file_download_done_rounded, size: 18),
                label: const Text('Restore Data'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          );
        },
      ),
    );

    if (shouldImport == true && textController.text.trim().isNotEmpty) {
      await _executeImport(textController.text.trim(), overwrite);
    }
  }

  Future<void> _executeImport(String jsonString, bool overwrite) async {
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(habitRepositoryProvider);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final result = await repository.importBackup(
        data,
        overwrite: overwrite,
      );

      ref.invalidate(habitsProvider);
      ref.invalidate(selectedHabitEntriesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Restored ${result.habitsImported} habits and ${result.entriesImported} check-ins!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
            content: Text('Invalid backup JSON: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showClearAllConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
              SizedBox(width: 10),
              Text('Reset All Data?', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          content: Text(
            'This action permanently deletes all habits, streaks, and check-in history from your device. Make sure to export a backup first if needed.',
            style: AppTextStyles.bodyMedium(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Everything'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final repository = ref.read(habitRepositoryProvider);
      final habits = await repository.getAllHabits();
      for (final h in habits) {
        await repository.deleteHabit(h.id);
      }
      ref.invalidate(habitsProvider);
      ref.invalidate(selectedHabitEntriesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been reset.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showProTrialSheet(BuildContext context, AppThemePreset preset) {
    PaywallSheet.show(context, trigger: 'Theme Studio');
  }

  Widget _buildProUpgradeHero(
    BuildContext context,
    bool isDark,
    AppThemePreset themePreset,
    ProTierState proState,
  ) {
    final isPro = proState.isPro;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPro
              ? [
                  const Color(0xFF10B981).withValues(alpha: isDark ? 0.22 : 0.15),
                  const Color(0xFF059669).withValues(alpha: isDark ? 0.14 : 0.08),
                ]
              : [
                  const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.22 : 0.15),
                  const Color(0xFFEF4444).withValues(alpha: isDark ? 0.14 : 0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isPro ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
              .withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPro ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                .withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPro
                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                        : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isPro ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                          .withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isPro ? Icons.verified_rounded : Icons.workspace_premium_rounded,
                  size: 22,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isPro ? 'STREAKBOX PRO' : 'UPGRADE TO PRO',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: isPro ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isPro ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            proState.planLabel,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: isPro ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPro
                          ? (proState.isTrialActive
                              ? '${proState.remainingTrialHours} hours remaining on your free test drive.'
                              : 'All signature themes, streak freezes & cloud features unlocked.')
                          : 'Unlock Streak Freezes, Cloud Sync, Neumorphic Themes & Smart Nudges.',
                      style: AppTextStyles.caption(context).copyWith(
                        color: themePreset.textSecondaryColor,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: FilledButton.icon(
              onPressed: () {
                PaywallSheet.show(context, trigger: 'Settings Header');
              },
              icon: Icon(
                isPro ? Icons.tune_rounded : Icons.bolt_rounded,
                size: 16,
                color: Colors.black,
              ),
              label: Text(
                isPro ? 'Manage PRO Plan' : 'Explore PRO Features (7-Day Trial)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: isPro ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    bool isDark,
    AppThemePreset themePreset,
  ) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final isGoogleUser = user != null && !user.isAnonymous;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGoogleUser ? Icons.account_circle_rounded : Icons.person_outline_rounded,
                color: themePreset.primaryColor,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'ACCOUNT & CLOUD IDENTITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isGoogleUser) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: themePreset.primaryColor.withValues(alpha: 0.2),
                  backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                  child: user.photoURL == null
                      ? Text(
                          (user.displayName?.isNotEmpty ?? false)
                              ? user.displayName![0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themePreset.primaryColor,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'Google User',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      Text(
                        user.email ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).signOut();
                  },
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Sign Out', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(
              height: 1,
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 14),
            Consumer(
              builder: (context, ref, _) {
                final vaultState = ref.watch(cloudVaultProvider);
                final isSyncing = vaultState.isSyncing;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_sync_rounded,
                          size: 18,
                          color: themePreset.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cloud Firestore Vault',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (vaultState.lastBackupTime != null)
                          Text(
                            'Synced ${vaultState.lastBackupTime!.hour.toString().padLeft(2, '0')}:${vaultState.lastBackupTime!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: isSyncing
                                ? null
                                : () async {
                                    try {
                                      final count = await ref
                                          .read(cloudVaultProvider.notifier)
                                          .syncToCloud(user.uid);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppColors.primary,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: AppSpacing.roundedMd),
                                            content: Row(
                                              children: [
                                                const Icon(Icons.cloud_done_rounded,
                                                    color: Colors.white, size: 20),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    'Uploaded $count habit(s) to Cloud Firestore!',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppColors.error,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: AppSpacing.roundedMd),
                                            content: Text('Sync failed: $e'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            icon: isSyncing
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.cloud_upload_rounded, size: 16),
                            label: Text(
                              isSyncing ? 'Syncing...' : 'Sync to Remote DB',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: themePreset.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: isSyncing
                              ? null
                              : () async {
                                  try {
                                    final res = await ref
                                        .read(cloudVaultProvider.notifier)
                                        .syncFromCloud(user.uid);
                                    ref.invalidate(habitsProvider);
                                    ref.invalidate(selectedHabitEntriesProvider);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: AppColors.primary,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: AppSpacing.roundedMd),
                                          content: Row(
                                            children: [
                                              const Icon(Icons.cloud_download_rounded,
                                                  color: Colors.white, size: 20),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  res != null
                                                      ? 'Restored ${res.habitsRestored} habit(s) from cloud!'
                                                      : 'No cloud vault backup found for this account.',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: AppColors.error,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: AppSpacing.roundedMd),
                                          content: Text('Restore failed: $e'),
                                        ),
                                      );
                                    }
                                  }
                                },
                          icon: const Icon(Icons.cloud_download_rounded, size: 16),
                          label: const Text('Restore', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ] else ...[
            Text(
              'You are currently in local-first Guest Mode. Sign in with Google to link your encrypted Cloud Vault across devices.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, _) {
                final authNotifierState = ref.watch(authNotifierProvider);
                final isLoading = authNotifierState.isLoading;

                return SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            try {
                              await ref.read(authNotifierProvider.notifier).signInWithGoogle();
                              final stateAfter = ref.read(authNotifierProvider);
                              if (stateAfter.hasError && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    content: Text('Sign-in error: ${stateAfter.error}'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    content: Text('Error: $e'),
                                  ),
                                );
                              }
                            }
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.login_rounded, size: 18),
                    label: Text(
                      isLoading ? 'Signing in...' : 'Sign In with Google',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themePreset.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themePreset = ref.watch(themePresetProvider);
    final proState = ref.watch(proEntitlementProvider);
    final isDark = themePreset.isDark;
    final firstDay = ref.watch(firstDayOfWeekProvider);
    final currentCheckSymbol = ref.watch(defaultCheckMarkProvider);
    final requireDoubleTap = ref.watch(tapProtectionProvider);
    final emojiMode = ref.watch(emojiPickerStyleProvider);
    final fillStyle = ref.watch(calendarFillStyleProvider);
    final todayStyle = ref.watch(todayIndicatorStyleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings & Vault',
          style: AppTextStyles.displayMedium(context).copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 👑 Streakbox PRO Hero Upgrade Banner
          _buildProUpgradeHero(context, isDark, themePreset, proState),
          const SizedBox(height: 16),

          // 👤 Account & Cloud Identity Section
          _buildAccountSection(context, isDark, themePreset),
          const SizedBox(height: 16),

          // 🛡️ Hero Privacy & Vault Card
          _buildPrivacyVaultHero(context, isDark, themePreset.primaryColor),
          const SizedBox(height: 20),

          // 🎨 1. APPEARANCE & THEME PRESET SECTION
          _buildSectionHeader(
            context,
            title: 'THEME ENGINE & PRESETS',
            icon: Icons.palette_outlined,
            accentColor: themePreset.primaryColor,
          ),
          const SizedBox(height: 8),
          _buildSettingsGroupCard(
            context,
            isDark: isDark,
            children: [
              // Theme Showcase Cards
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildTintedIconBadge(
                          icon: Icons.auto_awesome_rounded,
                          accentColor: themePreset.primaryColor,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Aesthetic Theme Presets', style: AppTextStyles.labelBold(context)),
                                  if (proState.isTrialActive) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'TRIAL (${proState.remainingTrialHours}h left)',
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                'Select a signature design language for your habit dashboard',
                                style: AppTextStyles.bodySmall(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.7,
                      children: AppThemePreset.values.map((preset) {
                        final isSelected = themePreset == preset;
                        return _buildPresetTile(
                          context: context,
                          preset: preset,
                          isSelected: isSelected,
                          proUnlocked: proState.isPro,
                          onTap: () {
                            if (preset.isPro && !proState.isPro) {
                              _showProTrialSheet(context, preset);
                            } else {
                              ref.read(themePresetProvider.notifier).setPreset(preset);
                            }
                          },
                          isDark: isDark,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, indent: 56),

              // Calendar Cell Style (Pure Minimal vs Solid Fill)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildTintedIconBadge(
                          icon: Icons.grid_view_rounded,
                          accentColor: AppColors.secondary,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Calendar Cell Style', style: AppTextStyles.labelBold(context)),
                              Text(
                                fillStyle == CalendarFillStyle.pureMinimal
                                    ? 'Pure Minimal (theme card + clean ✔️ badge)'
                                    : 'Solid Fill (vibrant habit color background)',
                                style: AppTextStyles.bodySmall(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<CalendarFillStyle>(
                      segments: const [
                        ButtonSegment(
                          value: CalendarFillStyle.pureMinimal,
                          icon: Icon(Icons.check_circle_outline, size: 16),
                          label: Text('Pure Minimal', style: TextStyle(fontSize: 12)),
                        ),
                        ButtonSegment(
                          value: CalendarFillStyle.solidFill,
                          icon: Icon(Icons.format_color_fill_rounded, size: 16),
                          label: Text('Solid Fill', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                      selected: {fillStyle},
                      onSelectionChanged: (newSelection) {
                        ref.read(calendarFillStyleProvider.notifier).setStyle(newSelection.first);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 🗓️ 2. CALENDAR & INTERACTION SECTION
          _buildSectionHeader(
            context,
            title: 'CALENDAR & LOGGING',
            icon: Icons.calendar_month_outlined,
            accentColor: AppColors.secondary,
          ),
          const SizedBox(height: 8),
          _buildSettingsGroupCard(
            context,
            isDark: isDark,
            children: [
              // First Day of Week
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildTintedIconBadge(
                          icon: Icons.view_week_outlined,
                          accentColor: AppColors.accent,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('First Day of Week', style: AppTextStyles.labelBold(context)),
                              Text('Grid column layout convention', style: AppTextStyles.bodySmall(context)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: DateTime.monday, label: Text('Monday', style: TextStyle(fontSize: 12))),
                        ButtonSegment(value: DateTime.sunday, label: Text('Sunday', style: TextStyle(fontSize: 12))),
                        ButtonSegment(value: DateTime.saturday, label: Text('Saturday', style: TextStyle(fontSize: 12))),
                      ],
                      selected: {firstDay},
                      onSelectionChanged: (newSelection) {
                        ref.read(firstDayOfWeekProvider.notifier).setFirstDay(newSelection.first);
                      },
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, indent: 56),

              // Default Checkmark Symbol Showcase
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildTintedIconBadge(
                          icon: Icons.done_all_rounded,
                          accentColor: themePreset.primaryColor,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Default Checkmark Symbol', style: AppTextStyles.labelBold(context)),
                              Text('Single-tap stamp symbol', style: AppTextStyles.bodySmall(context)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppCheckmarkSymbols.available.map((symbol) {
                        final isSelected = currentCheckSymbol == symbol;
                        return GestureDetector(
                          onTap: () => ref.read(defaultCheckMarkProvider.notifier).setSymbol(symbol),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? themePreset.primaryColor.withValues(alpha: isDark ? 0.35 : 0.2)
                                  : (isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? themePreset.primaryColor
                                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                width: isSelected ? 2 : 0.8,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: themePreset.primaryColor.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: symbol == '✓' || symbol == '✔️'
                                  ? Icon(Icons.check_rounded, color: themePreset.primaryColor, size: 20)
                                  : (symbol == '❌'
                                      ? const Icon(Icons.close_rounded, color: AppColors.error, size: 20)
                                      : Text(symbol, style: const TextStyle(fontSize: 16))),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, indent: 56),

              // Today's Highlight Indicator Mode (4 Interactive Live Preview Tiles)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildTintedIconBadge(
                          icon: Icons.today_rounded,
                          accentColor: themePreset.primaryColor,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Today's Highlight (When Marked)", style: AppTextStyles.labelBold(context)),
                              Text('Visual indicator to identify Today', style: AppTextStyles.bodySmall(context)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildTodayStyleGrid(context, isDark, todayStyle, themePreset.primaryColor),
                  ],
                ),
              ),

              const Divider(height: 1, indent: 56),

              // Accidental Tap Protection (Require Double-Tap)
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                secondary: _buildTintedIconBadge(
                  icon: Icons.touch_app_outlined,
                  accentColor: AppColors.warning,
                  isDark: isDark,
                ),
                title: Text('Double-Tap Protection', style: AppTextStyles.labelBold(context)),
                subtitle: Text(
                  'Requires two quick taps to mark a day, avoiding misclicks while swiping',
                  style: AppTextStyles.bodySmall(context),
                ),
                value: requireDoubleTap,
                activeTrackColor: themePreset.primaryColor,
                onChanged: (val) => ref.read(tapProtectionProvider.notifier).setDoubleTapRequired(val),
              ),

              const Divider(height: 1, indent: 56),

              // Emoji Picker Mode (Quick vs Full Keyboard)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: _buildTintedIconBadge(
                  icon: Icons.emoji_emotions_outlined,
                  accentColor: const Color(0xFF8B5CF6),
                  isDark: isDark,
                ),
                title: Text('Emoji Picker Mode', style: AppTextStyles.labelBold(context)),
                subtitle: Text(
                  emojiMode == EmojiPickerStyle.fullKeyboard
                      ? 'Full Unicode Keyboard (3,000+ emojis)'
                      : 'Curated Quick Palette (Fast high-frequency tags)',
                  style: AppTextStyles.bodySmall(context),
                ),
                trailing: TextButton(
                  onPressed: () => ref.read(emojiPickerStyleProvider.notifier).toggleStyle(),
                  child: Text(
                    emojiMode == EmojiPickerStyle.fullKeyboard ? 'Switch to Quick' : 'Switch to Full',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 💾 3. DATA VAULT & PORTABILITY SECTION
          _buildSectionHeader(
            context,
            title: 'DATA VAULT & PORTABILITY',
            icon: Icons.security_rounded,
            accentColor: themePreset.primaryColor,
          ),
          const SizedBox(height: 8),
          _buildSettingsGroupCard(
            context,
            isDark: isDark,
            children: [
              // Export JSON
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: _buildTintedIconBadge(
                  icon: Icons.upload_file_rounded,
                  accentColor: themePreset.primaryColor,
                  isDark: isDark,
                ),
                title: Text('Export Backup (JSON)', style: AppTextStyles.labelBold(context)),
                subtitle: Text(
                  'Copy full database snapshot to clipboard for safe keeping',
                  style: AppTextStyles.bodySmall(context),
                ),
                trailing: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.copy_rounded, size: 18),
                onTap: _isLoading ? null : _exportData,
              ),

              const Divider(height: 1, indent: 56),

              // Restore JSON
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: _buildTintedIconBadge(
                  icon: Icons.download_rounded,
                  accentColor: AppColors.secondary,
                  isDark: isDark,
                ),
                title: Text('Restore from Backup', style: AppTextStyles.labelBold(context)),
                subtitle: Text(
                  'Import habits and streaks with merge or replace options',
                  style: AppTextStyles.bodySmall(context),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _isLoading ? null : _showImportDialog,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ℹ️ 4. APP INFO & DANGER ZONE SECTION
          _buildSectionHeader(
            context,
            title: 'SYSTEM & DANGER ZONE',
            icon: Icons.info_outline_rounded,
            accentColor: AppColors.error,
          ),
          const SizedBox(height: 8),
          _buildSettingsGroupCard(
            context,
            isDark: isDark,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: _buildTintedIconBadge(
                  icon: Icons.auto_awesome_rounded,
                  accentColor: themePreset.primaryColor,
                  isDark: isDark,
                ),
                title: Text('Streakbox Engine', style: AppTextStyles.labelBold(context)),
                subtitle: const Text('Version 1.0.0 (Offline Edition • Vulkan Impeller)', style: TextStyle(fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: themePreset.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    proState.isPro ? 'PRO UNLOCKED' : 'FREE EDITION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: themePreset.primaryColor,
                    ),
                  ),
                ),
              ),

              const Divider(height: 1, indent: 56),

              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: _buildTintedIconBadge(
                  icon: Icons.delete_forever_rounded,
                  accentColor: AppColors.error,
                  isDark: isDark,
                ),
                title: Text(
                  'Reset All Habits & Streaks',
                  style: AppTextStyles.labelBold(context).copyWith(color: AppColors.error),
                ),
                subtitle: Text(
                  'Irreversibly wipe all local database records',
                  style: AppTextStyles.bodySmall(context),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.error),
                onTap: _showClearAllConfirmation,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --- Helper Widget Builders ---

  Widget _buildPrivacyVaultHero(BuildContext context, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  primaryColor.withValues(alpha: 0.20),
                  const Color(0xFF0F172A),
                ]
              : [
                  primaryColor.withValues(alpha: 0.15),
                  const Color(0xFFF1F5F9),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(Icons.shield_rounded, color: primaryColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '100% Local Privacy Vault',
                      style: AppTextStyles.labelBold(context).copyWith(
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.lock_rounded, size: 14, color: primaryColor),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Zero tracking, zero cloud telemetry. Your habits stay on your hardware.',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color accentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: accentColor),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroupCard(
    BuildContext context, {
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildTintedIconBadge({
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: accentColor, size: 18),
    );
  }

  Widget _buildPresetTile({
    required BuildContext context,
    required AppThemePreset preset,
    required bool isSelected,
    required bool proUnlocked,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? preset.primaryColor.withValues(alpha: isDark ? 0.20 : 0.14)
              : (isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? preset.primaryColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: preset.backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: preset.primaryColor, width: 1.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: preset.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                if (preset.isPro && !proUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '👑 PRO',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                      ),
                    ),
                  )
                else if (isSelected)
                  Icon(Icons.check_circle_rounded, size: 16, color: preset.primaryColor),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preset.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? preset.primaryColor : null,
                  ),
                ),
                Text(
                  preset.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStyleGrid(
    BuildContext context,
    bool isDark,
    TodayIndicatorStyle currentStyle,
    Color primaryColor,
  ) {
    final styles = [
      (
        style: TodayIndicatorStyle.ringBorder,
        title: 'Ring Border',
        subtitle: 'Crisp outer frame',
      ),
      (
        style: TodayIndicatorStyle.cornerDot,
        title: 'Corner Dot',
        subtitle: 'Glowing top badge',
      ),
      (
        style: TodayIndicatorStyle.ambientPulse,
        title: 'Ambient Pulse',
        subtitle: 'Breathing animation',
      ),
      (
        style: TodayIndicatorStyle.numberUnderline,
        title: 'Underline Bar',
        subtitle: 'Accent bottom line',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.9,
      children: styles.map((item) {
        final isSelected = currentStyle == item.style;
        return GestureDetector(
          onTap: () {
            ref.read(todayIndicatorStyleProvider.notifier).setStyle(item.style);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: isDark ? 0.20 : 0.12)
                  : (isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? primaryColor
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                width: isSelected ? 1.8 : 0.8,
              ),
            ),
            child: Row(
              children: [
                _buildLivePreviewBox(isDark, item.style, primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? primaryColor : null,
                        ),
                      ),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLivePreviewBox(bool isDark, TodayIndicatorStyle style, Color primaryColor) {
    Widget cell = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(7),
        border: style == TodayIndicatorStyle.ringBorder
            ? Border.all(color: isDark ? Colors.white : AppColors.darkTextPrimary, width: 1.8)
            : Border.all(color: primaryColor.withValues(alpha: 0.8), width: 1.2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_rounded, color: primaryColor, size: 11),
              const Text(
                '18',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (style == TodayIndicatorStyle.cornerDot)
            Positioned(
              top: 3,
              right: 3,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          if (style == TodayIndicatorStyle.numberUnderline)
            Positioned(
              bottom: 2,
              child: Container(
                width: 10,
                height: 1.5,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
        ],
      ),
    );

    if (style == TodayIndicatorStyle.ambientPulse) {
      cell = cell
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(0.92, 0.92),
            end: const Offset(1.08, 1.08),
            duration: 1000.ms,
          );
    }

    return cell;
  }
}
