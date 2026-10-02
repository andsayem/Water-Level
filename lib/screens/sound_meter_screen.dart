import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/neon_text.dart';
import '../widgets/tool_scaffold.dart';
import '../widgets/ui_kit.dart';

/// Approximate sound level meter using the microphone's PCM stream.
class SoundMeterScreen extends StatefulWidget {
  const SoundMeterScreen({super.key});

  @override
  State<SoundMeterScreen> createState() => _SoundMeterScreenState();
}

class _SoundMeterScreenState extends State<SoundMeterScreen> {
  /// Rough dBFS → dB SPL offset for phone microphones.
  static const _splOffset = 90.0;

  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _sub;

  bool _running = false;
  bool _denied = false;
  double _db = 0;
  double? _min;
  double? _max;
  double _sum = 0;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      if (!await _recorder.hasPermission()) {
        if (mounted) setState(() => _denied = true);
        return;
      }
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 44100,
          numChannels: 1,
        ),
      );
      _sub = stream.listen(_onAudio);
      if (mounted) {
        setState(() {
          _denied = false;
          _running = true;
        });
      }
    } catch (e) {
      debugPrint('Sound meter failed to start: $e');
      if (mounted) setState(() => _denied = true);
    }
  }

  Future<void> _stop() async {
    await _sub?.cancel();
    _sub = null;
    try {
      await _recorder.stop();
    } catch (_) {}
    if (mounted) setState(() => _running = false);
  }

  void _onAudio(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    final samples = bytes.lengthInBytes ~/ 2;
    if (samples == 0) return;

    double sumSquares = 0;
    for (int i = 0; i < samples; i++) {
      final s = data.getInt16(i * 2, Endian.little).toDouble();
      sumSquares += s * s;
    }
    final rms = sqrt(sumSquares / samples);
    final dbfs = rms > 0 ? 20 * log(rms / 32768) / ln10 : -90.0;
    final db = (dbfs + _splOffset).clamp(0.0, 130.0);

    if (!mounted) return;
    setState(() {
      // Start the smoothed level at the first real sample; easing up from 0
      // made the first readings (and so the Min stat) far too low.
      _db = _count == 0 ? db : _db + (db - _db) * 0.3;
      _min = _min == null ? _db : min(_min!, _db);
      _max = _max == null ? _db : max(_max!, _db);
      _sum += _db;
      _count++;
    });
  }

  void _resetStats() {
    setState(() {
      _min = null;
      _max = null;
      _sum = 0;
      _count = 0;
    });
  }

  String _describe(double db) {
    if (db < 40) return tr('Quiet');
    if (db < 65) return tr('Normal conversation');
    if (db < 85) return tr('Busy traffic');
    if (db < 100) return tr('Loud — limit exposure');
    return tr('Dangerous');
  }

  @override
  void dispose() {
    _sub?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String fmt(double? v) => v == null ? '—' : '${v.toStringAsFixed(0)} dB';

    return ToolScaffold(
      title: tr('Sound Meter'),
      action: GlowIconButton(
        icon: Icons.refresh_rounded,
        tooltip: tr('Reset'),
        onTap: _resetStats,
      ),
      body: _denied
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mic_off_rounded,
                    color: AppColors.textTertiary,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr('Microphone permission is required to measure sound.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextButton(onPressed: _start, child: Text(tr('Start'))),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1.5,
                      child: CustomPaint(
                        painter: _GaugePainter(
                          value: _db,
                          color: AppColors.primary,
                          trackColor: AppColors.textTertiary,
                        ),
                        child: Align(
                          alignment: const Alignment(0, 0.6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NeonText(
                                text: '${_db.toStringAsFixed(0)} dB',
                                fontSize: 44,
                              ),
                              Text(
                                _describe(_db),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    StatCard(label: tr('Min'), value: fmt(_min)),
                    StatCard(
                      label: tr('Avg'),
                      value: fmt(_count == 0 ? null : _sum / _count),
                    ),
                    StatCard(label: tr('Max'), value: fmt(_max)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  tr(
                    'Approximate values — phone microphones are not calibrated sound meters.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
                const SizedBox(height: 12),
                ToolActionButton(
                  label: _running ? tr('Stop') : tr('Start'),
                  active: _running,
                  onTap: _running ? _stop : _start,
                ),
              ],
            ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;
  final Color trackColor;

  _GaugePainter({
    required this.value,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    final radius = min(size.width / 2, size.height * 0.9) - 16;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = trackColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, pi, pi, false, track);

    final fraction = (value / 130).clamp(0.0, 1.0);
    final activeColor = value >= 100
        ? Colors.redAccent
        : (value >= 85 ? Colors.orangeAccent : color);
    final active = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, pi, pi * fraction, false, active);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.value != value || old.color != color;
}
