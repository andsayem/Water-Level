import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

/// Debug-only scripted tilt used to record promo videos with a phone lying
/// on a desk. Enabled by the 'debug_demo_motion' preference (see
/// [SensorService]); never used in release builds.
///
/// Each mode returns the flat-mode roll / pitch (degrees) the phone should
/// appear to have [t] seconds after the sensor started.
class DemoMotion {
  DemoMotion._();

  static const prefsKey = 'debug_demo_motion';

  /// Mode 4 also drives the Vibration Meter with scripted bursts.
  static const vibrationMode = 4;

  /// Scripted linear acceleration for the Vibration Meter: quiet, then a
  /// few bursts of different strength, repeating every 7 seconds.
  static Stream<UserAccelerometerEvent> vibration() {
    final random = Random(7);
    return Stream.periodic(const Duration(milliseconds: 20), (i) {
      final t = (i * 0.02) % 7;
      double amp = 0.01;
      if (t > 1.0 && t < 2.4) amp = 1.3 * sin((t - 1.0) / 1.4 * pi);
      if (t > 3.4 && t < 3.9) amp = 3.2 * sin((t - 3.4) / 0.5 * pi);
      if (t > 4.8 && t < 6.0) amp = 0.45;
      double n() => (random.nextDouble() * 2 - 1) * amp;
      return UserAccelerometerEvent(n(), n(), n() * 1.6, DateTime.now());
    });
  }

  /// Converts a flat roll / pitch into the gravity vector an accelerometer
  /// would report, using the same conventions as [SensorService].
  static (double, double, double) gravityFor(double rollDeg, double pitchDeg) {
    const g = 9.81;
    final r = rollDeg * pi / 180;
    final p = pitchDeg * pi / 180;
    final horizontal = g * cos(p);
    return (-horizontal * sin(r), g * sin(p), horizontal * cos(r));
  }

  static (double, double) anglesAt(int mode, double t) {
    final wobble = 0.08 * sin(t * 7.3) + 0.05 * sin(t * 11.1);
    switch (mode) {
      case 2:
        return (0, _keyframes(_inclineSweep, t, loop: 20) + wobble);
      case 3:
        return (
          _keyframes(_caravanRoll, t, loop: 16) + wobble,
          _keyframes(_caravanPitch, t, loop: 16) + wobble,
        );
      default:
        return (
          _keyframes(_levelRoll, t, loop: 14) + wobble,
          _keyframes(_levelPitch, t, loop: 14) + wobble * 0.7,
        );
    }
  }

  // [time, value] pairs, eased between neighbours.
  static const _levelRoll = [
    [0.0, 7.0],
    [1.4, -3.5],
    [2.6, 2.0],
    [3.6, -0.9],
    [4.5, 0.3],
    [5.2, 0.0],
    [8.0, 0.0],
    [9.2, -6.0],
    [10.6, 2.5],
    [11.8, -0.8],
    [12.6, 0.1],
    [14.0, 7.0],
  ];
  static const _levelPitch = [
    [0.0, -4.5],
    [1.6, 2.5],
    [2.8, -1.2],
    [3.8, 0.5],
    [4.6, -0.1],
    [5.2, 0.0],
    [8.0, 0.0],
    [9.4, 4.0],
    [10.8, -1.5],
    [11.9, 0.4],
    [12.6, 0.0],
    [14.0, -4.5],
  ];
  static const _inclineSweep = [
    [0.0, 0.0],
    [2.5, 30.0],
    [3.6, 47.5],
    [4.4, 44.4],
    [5.0, 45.0],
    [8.5, 45.0],
    [10.0, 22.5],
    [13.0, 22.5],
    [15.0, 60.0],
    [18.0, 60.0],
    [20.0, 0.0],
  ];
  static const _caravanRoll = [
    [0.0, -2.6],
    [2.0, -2.6],
    [5.5, -0.2],
    [6.2, 0.0],
    [16.0, 0.0],
  ];
  static const _caravanPitch = [
    [0.0, 1.9],
    [6.0, 1.9],
    [9.5, 0.1],
    [10.2, 0.0],
    [14.5, 0.0],
    [16.0, 1.9],
  ];

  static double _keyframes(
    List<List<double>> frames,
    double t, {
    required double loop,
  }) {
    final lt = t % loop;
    for (var i = 0; i < frames.length - 1; i++) {
      final a = frames[i], b = frames[i + 1];
      if (lt >= a[0] && lt <= b[0]) {
        final p = (lt - a[0]) / (b[0] - a[0]);
        final eased = p * p * (3 - 2 * p);
        return a[1] + (b[1] - a[1]) * eased;
      }
    }
    return frames.last[1];
  }
}
