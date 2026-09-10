import 'dart:async';
import 'dart:math';
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
  bool isPercentGrade = false;

  bool _wasCentered = false;
  bool isDarkTheme = true;

  StreamSubscription? _sub;

  LevelProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _sensorService.loadSavedCalibration();
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
            _vibrate();
          }
          if (isSoundEnabled) {
            try {
              SystemSound.play(SystemSoundType.click);
            } catch (e) {
              debugPrint('SystemSound failed: $e');
            }
          }
        }
        _wasCentered = isNowCentered;

        notifyListeners();
      });
    } catch (e) {
      debugPrint('LevelProvider init failed: $e');
    }
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
    isDarkTheme = !isDarkTheme;
    AppColors.isDark = isDarkTheme;
    notifyListeners();
  }

  void toggleUnit() {
    isPercentGrade = !isPercentGrade;
    notifyListeners();
  }

  /// Formats an angle in degrees as either "12.3°" or, in percent-grade
  /// mode, the construction/roofing standard "rise/run × 100" slope: "21.9%".
  String formatAngle(double degrees) {
    if (!isPercentGrade) return "${degrees.toStringAsFixed(1)}°";
    final percent = tan(degrees * pi / 180) * 100;
    return "${percent.toStringAsFixed(1)}%";
  }

  Future<void> _vibrate() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator != true) return;
      await Vibration.vibrate(duration: 50, amplitude: 64);
    } catch (e) {
      debugPrint('Vibration failed: $e');
    }
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
