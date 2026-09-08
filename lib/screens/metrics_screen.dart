import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/admob_helper.dart';
import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/neon_text.dart';

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<LevelProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const NeonText(text: 'Metrics', fontSize: 20),
      ),
      body: Consumer<LevelProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                _MetricCard(
                  icon: Icons.my_location_rounded,
                  title: 'Position',
                  rows: [
                    _Row('X axis', '${provider.x.toStringAsFixed(2)}°'),
                    _Row('Y axis', '${provider.y.toStringAsFixed(2)}°'),
                  ],
                ),
                _MetricCard(
                  icon: Icons.tune_rounded,
                  title: 'Preferences',
                  rows: [
                    _Row('Theme', provider.isDarkTheme ? 'Dark' : 'Light'),
                    _Row('Sound', provider.isSoundEnabled ? 'On' : 'Off'),
                    _Row('Vibration', provider.isVibrationEnabled ? 'On' : 'Off'),
                    _Row('Locked', provider.isLocked ? 'Yes' : 'No'),
                  ],
                ),
                _MetricCard(
                  icon: Icons.percent_rounded,
                  title: 'Unit',
                  rows: [
                    _Row('Mode', provider.isPercentGrade ? '% Grade' : 'Degrees'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(child: AdmobHelper.getBannerAdWidget()),
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
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final row in rows) ...[
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

class _Row {
  final String label;
  final String value;

  const _Row(this.label, this.value);
}
