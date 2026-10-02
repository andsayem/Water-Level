import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_motion.dart';

/// One smoothed accelerometer sample converted to the angles the app uses.
///
/// Sign conventions (all in degrees):
/// * [x] - flat roll; positive when the RIGHT edge of the phone is lower.
/// * [y] - flat pitch; positive when the TOP edge of the phone is higher.
/// * [uprightRoll] - rotation of an upright (portrait) phone around the
///   screen normal; positive when rotated clockwise (right side lower).
/// * [elevation] - where the back camera points; 0 = horizon, positive =
///   above the horizon, -90 = straight down.
/// * [inclination] - angle between the screen and the horizontal plane in
///   any direction; 0 = lying flat, 90 = standing upright, 180 = face down.
class TiltReading {
  final double x;
  final double y;
  final double uprightRoll;
  final double elevation;
  final double inclination;

  const TiltReading({
    required this.x,
    required this.y,
    required this.uprightRoll,
    required this.elevation,
    required this.inclination,
  });
}

class SensorService {
  static final SensorService _instance = SensorService._internal();

  factory SensorService() => _instance;

  SensorService._internal();

  static const _xOffsetKey = 'calibration_x_offset';
  static const _yOffsetKey = 'calibration_y_offset';

  /// Low-pass factor: higher reacts faster, lower is steadier.
  static const _smoothing = 0.15;

  final StreamController<TiltReading> _sensorController =
      StreamController.broadcast();

  Stream<TiltReading> get sensorStream => _sensorController.stream;

  StreamSubscription? _accelerometerSubscription;
  Timer? _demoTimer;

  /// Scripted demo motion mode (debug builds only, 0 = off).
  int _demoMode = 0;

  int get demoMode => _demoMode;

  /// Smoothed raw acceleration. Smoothing the vector (instead of the angles)
  /// avoids glitches when an angle wraps around +/-180 degrees.
  double _ax = 0;
  double _ay = 0;
  double _az = 0;
  bool _hasSample = false;

  /// Calibration offsets (flat mode only)
  double _xOffset = 0;
  double _yOffset = 0;

  bool get isCalibrated => _xOffset != 0 || _yOffset != 0;

  /// Load any previously saved calibration before the sensor starts emitting
  Future<void> loadSavedCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    _xOffset = prefs.getDouble(_xOffsetKey) ?? 0;
    _yOffset = prefs.getDouble(_yOffsetKey) ?? 0;
    if (kDebugMode) _demoMode = prefs.getInt(DemoMotion.prefsKey) ?? 0;
  }

  double get _rawX => atan2(-_ax, _az) * 180 / pi;

  double get _rawY => atan2(_ay, sqrt(_ax * _ax + _az * _az)) * 180 / pi;

  /// Start listening sensor
  void start() {
    if (kDebugMode && _demoMode > 0) {
      _startDemo();
      return;
    }
    // The default (normal) interval is only ~5 Hz, which made the bubble lag
    // well over a second behind the phone; the game interval is ~50 Hz.
    _accelerometerSubscription ??=
        accelerometerEventStream(
          samplingPeriod: SensorInterval.gameInterval,
        ).listen(
          (event) => _onSample(event.x, event.y, event.z),
          // A device without a working accelerometer emits a platform error.
          // Swallow it instead of crashing the app at launch.
          onError: (Object error) {
            debugPrint('Accelerometer unavailable: $error');
          },
        );
  }

  /// Debug builds only: feeds a scripted tilt instead of the accelerometer
  /// so promo screen recordings show realistic bubble movement.
  void _startDemo() {
    if (_demoTimer != null) return;
    final clock = Stopwatch()..start();
    _demoTimer = Timer.periodic(const Duration(milliseconds: 20), (_) {
      final t = clock.elapsedMilliseconds / 1000;
      final (roll, pitch) = DemoMotion.anglesAt(_demoMode, t);
      final (ax, ay, az) = DemoMotion.gravityFor(roll, pitch);
      _onSample(ax, ay, az);
    });
  }

  void _onSample(double x, double y, double z) {
    if (!_hasSample) {
      _ax = x;
      _ay = y;
      _az = z;
      _hasSample = true;
    } else {
      _ax += (x - _ax) * _smoothing;
      _ay += (y - _ay) * _smoothing;
      _az += (z - _az) * _smoothing;
    }

    final g = sqrt(_ax * _ax + _ay * _ay + _az * _az);
    if (g == 0) return;

    _sensorController.add(
      TiltReading(
        x: _rawX - _xOffset,
        y: _rawY - _yOffset,
        uprightRoll: atan2(-_ax, _ay) * 180 / pi,
        elevation: asin((-_az / g).clamp(-1.0, 1.0)) * 180 / pi,
        inclination: acos((_az / g).clamp(-1.0, 1.0)) * 180 / pi,
      ),
    );
  }

  /// Set current values as center
  void calibrate() {
    if (!_hasSample) return;
    _xOffset = _rawX;
    _yOffset = _rawY;
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
    _accelerometerSubscription = null;
    _demoTimer?.cancel();
    _demoTimer = null;
  }

  void dispose() {
    stop();
    _sensorController.close();
  }
}
