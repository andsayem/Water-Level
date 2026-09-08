import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/neon_text.dart';

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
