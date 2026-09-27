import 'dart:async';

import 'package:admob_kit/admob_kit.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/level_provider.dart';
import '../services/ad_free_service.dart';
import '../services/purchase_service.dart';
import '../services/review_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_links.dart';
import '../utils/strings.dart';
import '../widgets/neon_text.dart';
import '../widgets/other_apps_section.dart';
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
        title: NeonText(text: tr('Settings'), fontSize: 20),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _RemoveAdsCard(),
          _SettingsTile(
            icon: Icons.translate_rounded,
            title: tr('Language'),
            subtitle: AppStrings.isBangla ? 'বাংলা' : 'English',
            trailing: SegmentedButton<String>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.primary,
                selectedForegroundColor: Colors.black,
                foregroundColor: AppColors.textSecondary,
                visualDensity: VisualDensity.compact,
              ),
              segments: const [
                ButtonSegment(value: 'en', label: Text('EN')),
                ButtonSegment(value: 'bn', label: Text('বাং')),
              ],
              selected: {provider.languageCode},
              onSelectionChanged: (s) => provider.setLanguage(s.first),
            ),
          ),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: tr('Dark Mode'),
            subtitle: provider.isDarkTheme
                ? tr('Dark theme is active')
                : tr('Light theme is active'),
            trailing: Switch(
              value: provider.isDarkTheme,
              activeThumbColor: AppColors.primary,
              onChanged: (_) => provider.toggleTheme(),
            ),
          ),
          _SettingsTile(
            icon: Icons.volume_up_rounded,
            title: tr('Sound'),
            subtitle: tr('Play a sound when the level is centred'),
            trailing: Switch(
              value: provider.isSoundEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (_) => provider.toggleSound(),
            ),
          ),
          _SettingsTile(
            icon: Icons.vibration_rounded,
            title: tr('Vibration'),
            subtitle: tr('Vibrate when the level is centred'),
            trailing: Switch(
              value: provider.isVibrationEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (_) => provider.toggleVibration(),
            ),
          ),
          _SettingsTile(
            icon: Icons.star_rate_rounded,
            title: tr('Rate App'),
            subtitle: tr('Enjoying the app? Leave a review'),
            trailing: _chevron,
            onTap: () async {
              final opened = await ReviewService.openStoreListing();
              if (!opened && context.mounted) _showLinkError(context);
            },
          ),
          _SettingsTile(
            icon: Icons.share_rounded,
            title: tr('Share App'),
            subtitle: tr('Tell your friends about it'),
            trailing: _chevron,
            onTap: () => SharePlus.instance.share(
              ShareParams(
                text: 'Water Level - Bubble Level\n${AppLinks.playStoreUrl}',
              ),
            ),
          ),
          if (AppLinks.privacyPolicyUrl.isNotEmpty)
            _SettingsTile(
              icon: Icons.privacy_tip_rounded,
              title: tr('Privacy Policy'),
              subtitle: tr('How we handle your data'),
              trailing: _chevron,
              onTap: () async {
                final opened = await launchUrl(
                  Uri.parse(AppLinks.privacyPolicyUrl),
                  mode: LaunchMode.externalApplication,
                );
                if (!opened && context.mounted) _showLinkError(context);
              },
            ),
          const _VersionTile(),
          const OtherAppsSection(),
        ],
      ),
    );
  }

  static Widget get _chevron =>
      Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary);

  static void _showLinkError(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(tr('Could not open link'))));
  }
}

class _VersionTile extends StatelessWidget {
  const _VersionTile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        return _SettingsTile(
          icon: Icons.info_outline_rounded,
          title: tr('Version'),
          subtitle: info == null
              ? '…'
              : '${info.version} (${info.buildNumber})',
          trailing: const SizedBox.shrink(),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
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
      AdShowResult.notReady => 'Ad not ready yet - try again in a few seconds.',
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
