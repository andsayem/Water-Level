import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../services/sensor_service.dart';
import '../utils/app_colors.dart';
import '../utils/strings.dart';

class LevelProvider extends ChangeNotifier {
  final SensorService _sensorService = SensorService();
  final SharedPreferences _prefs;

  static const _darkKey = 'pref_dark_theme';
  static const _soundKey = 'pref_sound';
  static const _vibrationKey = 'pref_vibration';
  static const _percentKey = 'pref_percent_grade';
  static const _toleranceKey = 'pref_level_tolerance';
  static const _languageKey = 'language_code';

  /// Tolerances (in degrees) the user can pick for "is level".
  static const toleranceOptions = [0.1, 0.25, 0.5, 1.0];

  /// Flat roll / pitch, see [TiltReading] for the sign conventions.
  double x = 0;
  double y = 0;

  /// Upright (camera / wall) roll and camera elevation.
  double uprightRoll = 0;
  double elevation = 0;

  /// Angle of the screen against the horizontal, in any direction.
  double inclination = 0;

  bool isSoundEnabled;
  bool isVibrationEnabled;
  bool isLocked = false;
  bool isPercentGrade;
  bool isDarkTheme;
  double levelTolerance;

  bool _wasCentered = false;

  StreamSubscription? _sub;

  LevelProvider(this._prefs)
    : isDarkTheme = _prefs.getBool(_darkKey) ?? true,
      isSoundEnabled = _prefs.getBool(_soundKey) ?? true,
      isVibrationEnabled = _prefs.getBool(_vibrationKey) ?? true,
      isPercentGrade = _prefs.getBool(_percentKey) ?? false,
      levelTolerance = _prefs.getDouble(_toleranceKey) ?? 0.5 {
    AppColors.isDark = isDarkTheme;
    _init();
  }

  Future<void> _init() async {
    try {
      await _sensorService.loadSavedCalibration();
      _sensorService.start();

      _sub = _sensorService.sensorStream.listen((data) {
        if (isLocked) return;

        x = data.x;
        y = data.y;
        uprightRoll = data.uprightRoll;
        elevation = data.elevation;
        inclination = data.inclination;

        final isNowCentered = isLevel;

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

  /// Whether both flat axes are within the chosen tolerance.
  bool get isLevel => isWithinTolerance(x) && isWithinTolerance(y);

  bool isWithinTolerance(double degrees) => degrees.abs() < levelTolerance;

  bool get isCalibrated => _sensorService.isCalibrated;

  void toggleLock() {
    isLocked = !isLocked;
    notifyListeners();
  }

  void toggleSound() {
    isSoundEnabled = !isSoundEnabled;
    _prefs.setBool(_soundKey, isSoundEnabled);
    notifyListeners();
  }

  void toggleVibration() {
    isVibrationEnabled = !isVibrationEnabled;
    _prefs.setBool(_vibrationKey, isVibrationEnabled);
    notifyListeners();
  }

  void toggleTheme() {
    isDarkTheme = !isDarkTheme;
    AppColors.isDark = isDarkTheme;
    _prefs.setBool(_darkKey, isDarkTheme);
    notifyListeners();
  }

  void setTolerance(double value) {
    levelTolerance = value;
    _prefs.setDouble(_toleranceKey, value);
    notifyListeners();
  }

  String get languageCode => AppStrings.languageCode;

  /// Saved language choice, or [AppStrings.system] to follow the phone.
  static String savedLanguage(SharedPreferences prefs) =>
      prefs.getString(_languageKey) ?? AppStrings.system;

  Future<void> setLanguage(String code) async {
    await AppStrings.load(code);
    notifyListeners();
    await _prefs.setString(_languageKey, code);
  }

  /// The larger of the two tilt angles — the axis the user is measuring.
  double get dominantAngle => x.abs() >= y.abs() ? x : y;

  void toggleUnit() {
    isPercentGrade = !isPercentGrade;
    _prefs.setBool(_percentKey, isPercentGrade);
    notifyListeners();
  }

  /// Formats an angle in degrees as either "12.3°" or, in percent-grade
  /// mode, the construction/roofing standard "rise/run × 100" slope: "21.9%".
  String formatAngle(double degrees) {
    // Avoid printing "-0.0" for tiny negative values.
    if (degrees.abs() < 0.05) degrees = 0;
    if (!isPercentGrade) return "${degrees.toStringAsFixed(1)}°";
    // tan() explodes towards 90°, where a percent grade is meaningless.
    if (degrees.abs() >= 89.5) return degrees > 0 ? "∞" : "-∞";
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
    notifyListeners();
  }

  /// RESET
  void reset() {
    _sensorService.resetCalibration();
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sensorService.dispose();
    super.dispose();
  }
}
