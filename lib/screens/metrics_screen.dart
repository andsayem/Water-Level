import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/admob_helper.dart';
import '../providers/level_provider.dart';
import '../utils/app_colors.dart';

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Metrics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
      ),
    body: Consumer<LevelProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Position', style: TextStyle(fontSize: 20, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('X: ${provider.x.toStringAsFixed(2)}°', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
              Text('Y: ${provider.y.toStringAsFixed(2)}°', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              Text('Status', style: TextStyle(fontSize: 20, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Locked: ${provider.isLocked ? "Yes" : "No"}', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
              Text('Sound: ${provider.isSoundEnabled ? "On" : "Off"}', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
              Text('Vibration: ${provider.isVibrationEnabled ? "On" : "Off"}', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
            ],
          ),
        );
      },
    ),
      bottomNavigationBar: SafeArea(child: AdmobHelper.getBannerAdWidget()),
    );
  }
}
