import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  static final SensorService _instance = SensorService._internal();

  factory SensorService() => _instance;

  SensorService._internal();

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

  /// Start listening sensor
  void start() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
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
    });
  }

  /// Set current values as center
  void calibrate() {
    _xOffset = _smoothX;
    _yOffset = _smoothY;
  }

  /// Reset calibration
  void resetCalibration() {
    _xOffset = 0;
    _yOffset = 0;
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
