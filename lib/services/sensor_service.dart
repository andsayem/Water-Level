import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SensorService {
  static final SensorService _instance = SensorService._internal();

  factory SensorService() => _instance;

  SensorService._internal();

  static const _xOffsetKey = 'calibration_x_offset';
  static const _yOffsetKey = 'calibration_y_offset';

  final StreamController<Map<String, double>> _sensorController =
      StreamController.broadcast();

  Stream<Map<String, double>> get sensorStream => _sensorController.stream;

  StreamSubscription? _accelerometerSubscription;

  /// Smooth values
  double _smoothX = 0;
  double _smoothY = 0;

  /// Calibration offsets
  double _xOffset = 0;
  double _yOffset = 0;

  /// Load any previously saved calibration before the sensor starts emitting
  Future<void> loadSavedCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    _xOffset = prefs.getDouble(_xOffsetKey) ?? 0;
    _yOffset = prefs.getDouble(_yOffsetKey) ?? 0;
  }

  /// Start listening sensor
  void start() {
    _accelerometerSubscription = accelerometerEventStream().listen(
      (event) {
        // Calculate true pitch and roll angles in degrees
        double pitch = atan2(event.y, sqrt(event.x * event.x + event.z * event.z)) * 180 / pi;
        double roll = atan2(-event.x, event.z) * 180 / pi;

        /// Low-pass smoothing
        _smoothX = _smoothX + (roll - _smoothX) * 0.15;
        _smoothY = _smoothY + (pitch - _smoothY) * 0.15;

        /// Apply calibration offset
        final calibratedX = _smoothX - _xOffset;
        final calibratedY = _smoothY - _yOffset;

        _sensorController.add({"x": calibratedX, "y": calibratedY});
      },
      // A device without a working accelerometer emits a platform error.
      // Swallow it instead of crashing the app at launch.
      onError: (Object error) {
        debugPrint('Accelerometer unavailable: $error');
      },
    );
  }

  /// Set current values as center
  void calibrate() {
    _xOffset = _smoothX;
    _yOffset = _smoothY;
    _saveCalibration();
  }

  /// Reset calibration
  void resetCalibration() {
    _xOffset = 0;
    _yOffset = 0;
    _saveCalibration();
  }

  Future<void> _saveCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_xOffsetKey, _xOffset);
    await prefs.setDouble(_yOffsetKey, _yOffset);
  }

  /// Stop sensor
  void stop() {
    _accelerometerSubscription?.cancel();
  }

  void dispose() {
    stop();
    _sensorController.close();
  }
}
