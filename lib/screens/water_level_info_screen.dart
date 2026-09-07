import 'package:flutter/material.dart';
import '../common/admob_helper.dart';
import '../utils/app_colors.dart';

class WaterLevelInfoScreen extends StatelessWidget {
  const WaterLevelInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Water Level Info'),
        backgroundColor: AppColors.primary,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'This app measures water level using device sensors.\n\n'
          'Use the calibration button to reset the zero position.\n'
          'Tilt the device to see the level indicators.',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      bottomNavigationBar: SafeArea(child: AdmobHelper.getBannerAdWidget()),
    );
  }
}
