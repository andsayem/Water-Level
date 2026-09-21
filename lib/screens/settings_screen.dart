import 'dart:async';

import 'package:admob_kit/admob_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/level_provider.dart';
import '../services/ad_free_service.dart';
import '../services/purchase_service.dart';
import '../utils/app_colors.dart';
import '../widgets/neon_text.dart';
import '../widgets/remove_ads_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const NeonText(text: 'Settings', fontSize: 20),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _RemoveAdsCard(),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            subtitle: provider.isDarkTheme
                ? 'Dark theme is active'
                : 'Light theme is active',
            trailing: Switch(
              value: provider.isDarkTheme,
              activeThumbColor: AppColors.primary,
              onChanged: (_) => provider.toggleTheme(),
            ),
          ),
          _SettingsTile(
            icon: Icons.volume_up_rounded,
            title: 'Sound',
            subtitle: 'Play a sound when the level is centred',
            trailing: Switch(
              value: provider.isSoundEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (_) => provider.toggleSound(),
            ),
          ),
          _SettingsTile(
            icon: Icons.vibration_rounded,
            title: 'Vibration',
            subtitle: 'Vibrate when the level is centred',
            trailing: Switch(
              value: provider.isVibrationEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (_) => provider.toggleVibration(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: AppColors.cardGradient),
        border: Border.all(color: AppColors.primary.withValues(alpha: .15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _RemoveAdsCard extends StatefulWidget {
  const _RemoveAdsCard();

  @override
  State<_RemoveAdsCard> createState() => _RemoveAdsCardState();
}

class _RemoveAdsCardState extends State<_RemoveAdsCard> {
  Timer? _ticker;
  bool _isLoadingAd = false;

  @override
  void initState() {
    super.initState();
    // Ticks the countdown text while an ad-free window is active; harmless
    // no-op re-render otherwise.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _watchAd() async {
    setState(() => _isLoadingAd = true);
    final result = await AdFreeService.watchToRemoveAds();
    if (!mounted) return;
    setState(() => _isLoadingAd = false);

    final message = switch (result) {
      AdShowResult.shown => 'Ads removed for 30 minutes!',
      AdShowResult.notReady =>
        'Ad not ready yet - try again in a few seconds.',
      _ => 'Could not show ad right now (${result.description}).',
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatRemaining(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PurchaseService>().isPremium;
    if (isPremium) return const _PremiumActiveCard();

    final remaining = AdManager.adsSuppressionRemaining;
    final isSuppressed = remaining != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: AppColors.cardGradient),
        border: Border.all(color: AppColors.primary.withValues(alpha: .15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  isSuppressed
                      ? Icons.check_circle_rounded
                      : Icons.block_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remove Ads',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSuppressed
                          ? 'Ad-free for ${_formatRemaining(remaining)}'
                          : 'Watch a short ad to remove ads for 30 minutes',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSuppressed)
                TextButton(
                  onPressed: _isLoadingAd ? null : _watchAd,
                  child: _isLoadingAd
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Watch Ad'),
                ),
            ],
          ),
          if (!isSuppressed) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showRemoveAdsDialog(context),
                icon: Icon(
                  Icons.workspace_premium_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Remove Ads Forever',
                  style: TextStyle(color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: .4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PremiumActiveCard extends StatelessWidget {
  const _PremiumActiveCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: AppColors.cardGradient),
        border: Border.all(color: AppColors.primary.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Active',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ads removed forever. Thank you!',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
