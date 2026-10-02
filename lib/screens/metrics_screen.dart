import 'package:admob_kit/admob_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/ui_kit.dart';

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelProvider>();
    String on(bool v) => v ? tr('On') : tr('Off');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ScreenHeader(
                title: tr('Metrics'),
                subtitle: tr('Live sensor readings'),
                showBack: Navigator.of(context).canPop(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  children: [
                    _MetricCard(
                      icon: Icons.my_location_rounded,
                      title: tr('Position'),
                      rows: [
                        _Row(tr('X axis'), '${provider.x.toStringAsFixed(2)}°'),
                        _Row(tr('Y axis'), '${provider.y.toStringAsFixed(2)}°'),
                        _Row(
                          tr('Inclination'),
                          '${provider.inclination.toStringAsFixed(2)}°',
                        ),
                        _Row(
                          tr('Upright roll'),
                          '${provider.uprightRoll.toStringAsFixed(2)}°',
                        ),
                        _Row(
                          tr('Camera tilt'),
                          '${provider.elevation.toStringAsFixed(2)}°',
                        ),
                        _Row(
                          tr('Status'),
                          provider.isLevel ? tr('LEVEL') : tr('Tilted'),
                        ),
                      ],
                    ),
                    const MediumRectangleAd(
                      padding: EdgeInsets.only(bottom: 16),
                    ),
                    _MetricCard(
                      icon: Icons.tune_rounded,
                      title: tr('Preferences'),
                      rows: [
                        _Row(
                          tr('Theme'),
                          provider.isDarkTheme ? tr('Dark') : tr('Light'),
                        ),
                        _Row(tr('Sound'), on(provider.isSoundEnabled)),
                        _Row(tr('Vibration'), on(provider.isVibrationEnabled)),
                        _Row(
                          tr('Locked'),
                          provider.isLocked ? tr('Yes') : tr('No'),
                        ),
                        _Row(
                          tr('Calibrated'),
                          provider.isCalibrated ? tr('Yes') : tr('No'),
                        ),
                      ],
                    ),
                    _MetricCard(
                      icon: Icons.percent_rounded,
                      title: tr('Unit'),
                      rows: [
                        _Row(
                          tr('Mode'),
                          provider.isPercentGrade
                              ? tr('% Grade')
                              : tr('Degrees'),
                        ),
                        _Row(
                          tr('Level tolerance'),
                          '±${provider.levelTolerance}°',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const AdaptiveBannerAd(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_Row> rows;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.rows,
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
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.label,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    row.value,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Row {
  final String label;
  final String value;

  const _Row(this.label, this.value);
}
