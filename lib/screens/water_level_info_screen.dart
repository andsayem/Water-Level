import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/admob_helper.dart';
import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/neon_text.dart';

class WaterLevelInfoScreen extends StatelessWidget {
  const WaterLevelInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<LevelProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const NeonText(text: 'Water Level Info', fontSize: 20),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _InfoCard(
            icon: Icons.water_drop_rounded,
            title: 'How it works',
            body:
                'This app measures the angle of your device using its built-in '
                'sensors, letting you check if a surface is perfectly level.',
          ),
          const _InfoCard(
            icon: Icons.tune_rounded,
            title: 'Calibration',
            body:
                'Use the calibration button to set the current position as '
                'zero. Long-press it to reset the zero point.',
          ),
          const _InfoCard(
            icon: Icons.touch_app_rounded,
            title: 'Usage tip',
            body:
                'Place the phone flat on the surface you want to check. Tilt '
                'the device and watch the bubble until it is perfectly centred.',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(child: AdmobHelper.getBannerAdWidget()),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: AppColors.cardGradient),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}