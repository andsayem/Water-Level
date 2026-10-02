import 'package:flutter/material.dart';
import 'package:admob_kit/admob_kit.dart';
import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/ui_kit.dart';

class WaterLevelInfoScreen extends StatelessWidget {
  const WaterLevelInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watchAppSettings();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: tr('Water Level Info'),
                subtitle: tr('Tips for accurate readings'),
                showBack: true,
              ),
              Expanded(child: _buildList()),
              const AdaptiveBannerAd(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      children: [
        const _InfoCard(
          icon: Icons.water_drop_rounded,
          title: 'How it works',
          body:
              'This app measures the angle of your device using its built-in '
              'sensors, letting you check if a surface is perfectly level.',
        ),
        const MediumRectangleAd(padding: EdgeInsets.only(bottom: 16)),
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
        const _InfoCard(
          icon: Icons.bubble_chart_rounded,
          title: 'Reading the bubble',
          body:
              'Just like a real spirit level, the bubble floats towards the '
              'HIGHER side. Lower that side (or raise the other) until the '
              'bubble sits between the lines.',
        ),
        const _InfoCard(
          icon: Icons.center_focus_strong_rounded,
          title: 'Tolerance',
          body:
              'Settings > Level tolerance sets how close to 0° counts as '
              'level. Use ±0.1° for precision work and ±1° for rough jobs.',
        ),
        const _InfoCard(
          icon: Icons.rv_hookup_rounded,
          title: 'Caravan Leveler',
          body:
              'Lay the phone on the floor with its top towards the hitch and '
              'enter the wheel spacing once. The app tells you how many cm to '
              'raise each side or the front.',
        ),
      ],
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
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                tr(title),
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
            tr(body),
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
