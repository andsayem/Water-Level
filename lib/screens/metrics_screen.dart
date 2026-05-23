import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      ),
    body: Consumer<LevelProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Position', style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('X: ${provider.x.toStringAsFixed(2)}°', style: const TextStyle(fontSize: 18, color: Colors.white70)),
              Text('Y: ${provider.y.toStringAsFixed(2)}°', style: const TextStyle(fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 20),
              Text('Status', style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Locked: ${provider.isLocked ? "Yes" : "No"}', style: const TextStyle(fontSize: 18, color: Colors.white70)),
              Text('Sound: ${provider.isSoundEnabled ? "On" : "Off"}', style: const TextStyle(fontSize: 18, color: Colors.white70)),
              Text('Vibration: ${provider.isVibrationEnabled ? "On" : "Off"}', style: const TextStyle(fontSize: 18, color: Colors.white70)),
            ],
          ),
        );
      },
    ),
    );
  }
}
