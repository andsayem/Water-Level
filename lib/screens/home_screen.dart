import 'dart:async';

import 'package:admob_kit/admob_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/saved_reading.dart';
import '../providers/level_provider.dart';
import '../services/history_service.dart';
import '../services/purchase_service.dart';
import '../utils/app_colors.dart';
import '../utils/navigation.dart';
import '../utils/strings.dart';
import '../utils/tool_catalog.dart';
import '../widgets/circular_level.dart';
import '../widgets/control_button.dart';
import '../widgets/horizontal_level.dart';
import '../widgets/neon_text.dart';
import '../widgets/remove_ads_dialog.dart';
import '../widgets/ui_kit.dart';
import '../widgets/vertical_level.dart';
import 'settings_screen.dart';
import 'water_level_info_screen.dart';

class HomeScreen extends StatefulWidget {
  /// Whether the App Open ad was just shown (and has now closed) on this
  /// cold start, so the Remove Ads popup should be offered shortly after.
  final bool offerRemoveAdsAfterOpenAd;

  /// Switches the shell to the Tools tab.
  final VoidCallback? onOpenAllTools;

  const HomeScreen({
    super.key,
    this.offerRemoveAdsAfterOpenAd = false,
    this.onOpenAllTools,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HistoryService _historyService = HistoryService();
  Timer? _removeAdsPromptTimer;

  @override
  void initState() {
    super.initState();
    if (widget.offerRemoveAdsAfterOpenAd) {
      _removeAdsPromptTimer = Timer(const Duration(seconds: 5), () {
        if (!mounted) return;
        if (context.read<PurchaseService>().isPremium) return;
        showRemoveAdsDialog(context);
      });
    }
  }

  @override
  void dispose() {
    _removeAdsPromptTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveReading(LevelProvider provider) async {
    // Snapshot the angles now; the phone moves while the dialog is open.
    final x = provider.x;
    final y = provider.y;
    final controller = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          tr('Save reading'),
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: tr('Label (e.g. "Shelf in kitchen")'),
            hintStyle: TextStyle(color: AppColors.textTertiary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tr('Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(
              controller.text.trim().isEmpty
                  ? tr('Reading')
                  : controller.text.trim(),
            ),
            child: Text(tr('Save'), style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (label == null) return;

    await _historyService.saveReading(
      SavedReading(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        label: label,
        x: x,
        y: y,
        timestamp: DateTime.now(),
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('Reading Saved')),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _calibrate(LevelProvider provider) {
    provider.calibrate();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('Calibrated Successfully')),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _resetCalibration(LevelProvider provider) {
    provider.reset();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('Calibration Reset!')),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelProvider>();
    final isPremium = context.watch<PurchaseService>().isPremium;
    final isLevel = provider.isLevel;
    final tilt = totalTilt(provider.x, provider.y);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        // Tints the whole screen while the phone is level so it can be read
        // from a distance.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: isLevel
              ? AppColors.primary.withValues(
                  alpha: AppColors.isDark ? 0.10 : 0.14,
                )
              : Colors.transparent,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                ScreenHeader(
                  title: tr('Water Level'),
                  subtitle: provider.isLocked
                      ? tr('Reading locked')
                      : (provider.isCalibrated
                            ? tr('Calibrated · tap ⚙ to recalibrate')
                            : tr('Place the phone on a surface')),
                  leading: const _MenuButton(),
                  actions: [
                    if (!isPremium)
                      GlowIconButton(
                        icon: Icons.workspace_premium_rounded,
                        tooltip: tr('Remove Ads'),
                        onTap: () => showRemoveAdsDialog(context),
                      ),
                    GlowIconButton(
                      icon: Icons.tune_rounded,
                      tooltip: tr('Calibrate (long-press to reset)'),
                      onTap: () => _calibrate(provider),
                      onLongPress: () => _resetCalibration(provider),
                    ),
                  ],
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Size the instrument so that it and the ad below it
                      // (the second section) both fit without scrolling.
                      final reserved = isPremium ? 190.0 : 286.0;
                      final instrumentHeight =
                          (constraints.maxHeight - reserved).clamp(
                            250.0,
                            440.0,
                          );
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        children: [
                          SizedBox(
                            height: instrumentHeight,
                            child: _InstrumentCard(
                              provider: provider,
                              isLevel: isLevel,
                              tilt: tilt,
                            ),
                          ),
                          const MediumRectangleAd(),
                          const SizedBox(height: 6),
                          _Controls(
                            provider: provider,
                            onSave: () => _saveReading(provider),
                          ),
                          SectionLabel(tr('Quick tools')),
                          _QuickTools(onAllTools: widget.onOpenAllTools),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InstrumentCard extends StatelessWidget {
  final LevelProvider provider;
  final bool isLevel;
  final double tilt;

  const _InstrumentCard({
    required this.provider,
    required this.isLevel,
    required this.tilt,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      highlight: isLevel,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LevelStatusPill(
                isLevel: isLevel,
                label: isLevel
                    ? tr('LEVEL')
                    : '${tr('TILT')} ${provider.formatAngle(tilt)}',
              ),
              if (provider.isLocked)
                Icon(Icons.lock_rounded, color: AppColors.primary, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: FittedBox(
              // Keep the instrument layout fixed in right-to-left languages.
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SizedBox(
                  width: 392,
                  height: 372,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          HorizontalLevel(x: provider.x),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: 300,
                            height: 290,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: isLevel
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.55),
                                              blurRadius: 40,
                                              spreadRadius: 8,
                                            ),
                                          ]
                                        : const [],
                                  ),
                                ),
                                CircularLevel(x: provider.x, y: provider.y),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 22),
                      Padding(
                        padding: const EdgeInsets.only(top: 82),
                        child: VerticalLevel(y: provider.y),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _AxisReadout(
                  label: 'X',
                  value: provider.formatAngle(provider.x),
                  ok: provider.isWithinTolerance(provider.x),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AxisReadout(
                  label: 'Y',
                  value: provider.formatAngle(provider.y),
                  ok: provider.isWithinTolerance(provider.y),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AxisReadout extends StatelessWidget {
  final String label;
  final String value;
  final bool ok;

  const _AxisReadout({
    required this.label,
    required this.value,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.background.withValues(alpha: 0.6),
        border: Border.all(
          color: ok
              ? AppColors.primary.withValues(alpha: 0.6)
              : AppColors.textTertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: NeonText(text: value, fontSize: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final LevelProvider provider;
  final VoidCallback onSave;

  const _Controls({required this.provider, required this.onSave});

  @override
  Widget build(BuildContext context) {
    Widget tile(ControlButton button) => Expanded(child: button);
    const gap = SizedBox(width: 10);

    return Column(
      children: [
        Row(
          children: [
            tile(
              ControlButton(
                width: double.infinity,
                height: 70,
                icon: provider.isLocked
                    ? Icons.lock_rounded
                    : Icons.lock_outline_rounded,
                label: tr('Lock'),
                isActive: provider.isLocked,
                onTap: provider.toggleLock,
              ),
            ),
            gap,
            tile(
              ControlButton(
                width: double.infinity,
                height: 70,
                icon: provider.isSoundEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                label: tr('Sound'),
                isActive: provider.isSoundEnabled,
                onTap: provider.toggleSound,
              ),
            ),
            gap,
            tile(
              ControlButton(
                width: double.infinity,
                height: 70,
                icon: provider.isVibrationEnabled
                    ? Icons.vibration_rounded
                    : Icons.mobile_off_rounded,
                label: tr('Vibration'),
                isActive: provider.isVibrationEnabled,
                onTap: provider.toggleVibration,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            tile(
              ControlButton(
                width: double.infinity,
                height: 70,
                icon: provider.isDarkTheme
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                label: tr('Theme'),
                onTap: provider.toggleTheme,
              ),
            ),
            gap,
            tile(
              ControlButton(
                width: double.infinity,
                height: 70,
                icon: Icons.bookmark_add_rounded,
                label: tr('Save'),
                onTap: onSave,
              ),
            ),
            gap,
            tile(
              ControlButton(
                width: double.infinity,
                height: 70,
                icon: Icons.percent_rounded,
                label: provider.isPercentGrade ? tr('% Grade') : tr('Degrees'),
                isActive: provider.isPercentGrade,
                onTap: provider.toggleUnit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickTools extends StatelessWidget {
  final VoidCallback? onAllTools;

  const _QuickTools({this.onAllTools});

  @override
  Widget build(BuildContext context) {
    final quick = toolCatalog.take(8).toList();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < quick.length; i++)
          _QuickChip(
                icon: quick[i].icon,
                label: tr(quick[i].label),
                onTap: () => openTool(context, quick[i].builder),
              )
              .animate()
              .fadeIn(delay: (40 * i).ms, duration: 250.ms)
              .slideY(begin: 0.2, end: 0),
        if (onAllTools != null)
          _QuickChip(
            icon: Icons.apps_rounded,
            label: tr('All Tools'),
            onTap: onAllTools!,
            filled: true,
          ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: filled ? AppColors.primary : AppColors.card,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: filled ? Colors.black : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.black : AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    final entries = <(IconData, String, WidgetBuilder)>[
      for (final tool in toolCatalog) (tool.icon, tool.label, tool.builder),
      (Icons.settings_rounded, 'Settings', (_) => const SettingsScreen()),
      (Icons.info_outline_rounded, 'Info', (_) => const WaterLevelInfoScreen()),
    ];
    return PopupMenuButton<WidgetBuilder>(
      tooltip: tr('Menu'),
      color: AppColors.card,
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.primary.withValues(alpha: .2)),
      ),
      itemBuilder: (context) => [
        for (final (icon, label, builder) in entries)
          PopupMenuItem<WidgetBuilder>(
            value: builder,
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(tr(label), style: TextStyle(color: AppColors.textPrimary)),
              ],
            ),
          ),
      ],
      onSelected: (builder) => openTool(context, builder),
      child: const IgnorePointer(
        child: GlowIconButton(icon: Icons.grid_view_rounded),
      ),
    );
  }
}
