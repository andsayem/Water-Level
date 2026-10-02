import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../services/demo_motion.dart';
import '../services/sensor_service.dart';
import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/neon_text.dart';
import '../widgets/tool_scaffold.dart';

/// Seismograph-style vibration meter. Reads the linear acceleration (gravity
/// already removed by the OS) and plots its magnitude over time.
class VibrationMeterScreen extends StatefulWidget {
  const VibrationMeterScreen({super.key});

  @override
  State<VibrationMeterScreen> createState() => _VibrationMeterScreenState();
}

class _VibrationMeterScreenState extends State<VibrationMeterScreen> {
  /// Samples kept on screen (~6 s at the game sampling rate).
  static const _historyLength = 300;

  StreamSubscription<UserAccelerometerEvent>? _sub;
  final List<double> _history = [];
  bool _running = true;
  bool _supported = true;

  double _current = 0;

  static const _biasRate = 0.02;
  double _biasX = 0;
  double _biasY = 0;
  double _biasZ = 0;
  bool _biasReady = false;
  double _peak = 0;
  double _sum = 0;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _sub?.cancel();
    final events =
        kDebugMode && SensorService().demoMode == DemoMotion.vibrationMode
        ? DemoMotion.vibration()
        : userAccelerometerEventStream(
            samplingPeriod: SensorInterval.gameInterval,
          );
    _sub = events.listen(
      (e) {
        // Phone accelerometers carry a small constant bias even at rest,
        // which read as a permanent "vibration". Track it with a slow
        // average and keep only the fast-changing part (a high-pass).
        if (!_biasReady) {
          _biasX = e.x;
          _biasY = e.y;
          _biasZ = e.z;
          _biasReady = true;
        }
        _biasX += (e.x - _biasX) * _biasRate;
        _biasY += (e.y - _biasY) * _biasRate;
        _biasZ += (e.z - _biasZ) * _biasRate;
        final dx = e.x - _biasX;
        final dy = e.y - _biasY;
        final dz = e.z - _biasZ;
        final magnitude = sqrt(dx * dx + dy * dy + dz * dz);
        // Signed trace for the chart: the magnitude, with the direction of
        // the strongest axis so the plot oscillates like a seismograph.
        final strongest = [
          dx,
          dy,
          dz,
        ].reduce((a, b) => a.abs() >= b.abs() ? a : b);
        final signed = strongest < 0 ? -magnitude : magnitude;
        if (!mounted) return;
        setState(() {
          _current = magnitude;
          _peak = max(_peak, magnitude);
          _sum += magnitude;
          _count++;
          _history.add(signed);
          if (_history.length > _historyLength) _history.removeAt(0);
        });
      },
      onError: (Object _) {
        if (mounted) setState(() => _supported = false);
      },
    );
    setState(() => _running = true);
  }

  void _pause() {
    _sub?.cancel();
    _sub = null;
    setState(() => _running = false);
  }

  void _reset() {
    setState(() {
      _history.clear();
      _peak = 0;
      _sum = 0;
      _count = 0;
      _current = 0;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Rough description of a vibration level in m/s².
  String _describe(double value) {
    if (value < 0.08) return tr('Still');
    if (value < 0.3) return tr('Barely felt');
    if (value < 1.0) return tr('Light vibration');
    if (value < 3.0) return tr('Moderate vibration');
    return tr('Strong vibration');
  }

  @override
  Widget build(BuildContext context) {
    final avg = _count == 0 ? 0.0 : _sum / _count;
    final level = (_current / 3).clamp(0.0, 1.0);
    final color = Color.lerp(AppColors.primary, Colors.redAccent, level)!;

    return ToolScaffold(
      title: tr('Vibration Meter'),
      subtitle: tr('Place the phone on the surface to monitor'),
      body: !_supported
          ? Center(
              child: Text(
                tr('Sensor not available on this device.'),
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 6),
                NeonText(
                  text: '${_current.toStringAsFixed(2)} m/s²',
                  fontSize: 38,
                ),
                const SizedBox(height: 4),
                Text(
                  _describe(_current),
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: AppColors.isDark
                          ? const Color(0xFF0B120B)
                          : AppColors.card,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: CustomPaint(
                        painter: _SeismographPainter(
                          samples: List.of(_history),
                          capacity: _historyLength,
                          color: AppColors.primary,
                          grid: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    StatCard(label: tr('Avg'), value: avg.toStringAsFixed(2)),
                    StatCard(
                      label: tr('Peak'),
                      value: _peak.toStringAsFixed(2),
                    ),
                    StatCard(label: tr('Samples'), value: '$_count'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ToolActionButton(
                        label: _running ? tr('Pause') : tr('Start'),
                        active: _running,
                        onTap: _running ? _pause : _start,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ToolActionButton(
                        label: tr('Reset'),
                        onTap: _reset,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _SeismographPainter extends CustomPainter {
  final List<double> samples;
  final int capacity;
  final Color color;
  final Color grid;

  _SeismographPainter({
    required this.samples,
    required this.capacity,
    required this.color,
    required this.grid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final gridPaint = Paint()
      ..color = grid.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (int i = 1; i < 8; i++) {
      final x = size.width * i / 8;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    canvas.drawLine(
      Offset(0, mid),
      Offset(size.width, mid),
      gridPaint..color = grid.withValues(alpha: 0.35),
    );

    if (samples.length < 2) return;

    // Auto-scale so small vibrations are still visible, with a sensible
    // floor so sensor noise does not fill the chart.
    final peak = samples.map((v) => v.abs()).reduce(max);
    final scale = (mid * 0.9) / max(peak, 0.5);
    final dx = size.width / (capacity - 1);
    final startX = size.width - dx * (samples.length - 1);

    final path = Path();
    for (int i = 0; i < samples.length; i++) {
      final px = startX + dx * i;
      final py = mid - samples[i] * scale;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SeismographPainter old) => true;
}
