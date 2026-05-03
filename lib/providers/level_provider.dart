import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import '../services/sensor_service.dart';
import '../utils/app_colors.dart';

class LevelProvider extends ChangeNotifier {
  final SensorService _sensorService = SensorService();

  double x = 0;
  double y = 0;

  bool isSoundEnabled = true;
  bool isVibrationEnabled = true;
  bool isLocked = false;
  
  bool _wasCentered = false;
  int _themeIndex = 0;

  StreamSubscription? _sub;

  LevelProvider() {
    _init();
  }

  void _init() {
    _sensorService.start();

    _sub = _sensorService.sensorStream.listen((data) {
      if (isLocked) return;

      x = data["x"] ?? 0;
      y = data["y"] ?? 0;

      // Check if perfect center
      bool isNowCentered = x.abs() < 0.5 && y.abs() < 0.5;

      if (isNowCentered && !_wasCentered) {
        // Trigger haptic and sound if enabled
        if (isVibrationEnabled) {
          Vibration.vibrate(duration: 50, amplitude: 64);
        }
        if (isSoundEnabled) {
          SystemSound.play(SystemSoundType.click);
        }
      }
      _wasCentered = isNowCentered;

      notifyListeners();
    });
  }

  void toggleLock() {
    isLocked = !isLocked;
    notifyListeners();
  }

  void toggleSound() {
    isSoundEnabled = !isSoundEnabled;
    notifyListeners();
  }

  void toggleVibration() {
    isVibrationEnabled = !isVibrationEnabled;
    notifyListeners();
  }

  void toggleTheme() {
    _themeIndex = (_themeIndex + 1) % AppColors.themeColors.length;
    AppColors.primary = AppColors.themeColors[_themeIndex];
    notifyListeners();
  }

  /// CALIBRATE (set current position as zero)
  void calibrate() {
    _sensorService.calibrate();
  }

  /// RESET
  void reset() {
    _sensorService.resetCalibration();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sensorService.dispose();
    super.dispose();
  }
}
