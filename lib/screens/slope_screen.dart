import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/neon_text.dart';
import '../widgets/tool_scaffold.dart';

/// Reads a slope's angle and converts it to percent grade, roof pitch
/// (rise per 12 of run) and a 1:N ratio.
class SlopeScreen extends StatefulWidget {
  const SlopeScreen({super.key});

  @override
  State<SlopeScreen> createState() => _SlopeScreenState();
}

class _SlopeScreenState extends State<SlopeScreen> {
  bool _held = false;
  double _heldAngle = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelProvider>();
    // The slope is the screen's inclination in whatever direction it falls.
    // Using only the larger of the X/Y axes under-read slopes when the phone
    // was not lined up with them (e.g. 20° read as 14° at a 45° twist).
    final liveAngle = min(provider.inclination, 90.0);
    final angle = _held ? _heldAngle : liveAngle;

    final slope = tan(angle.clamp(0.0, 89.9) * pi / 180);
    final pitch = slope * 12;
    final ratio = slope < 0.001 ? '—' : '1 : ${(1 / slope).toStringAsFixed(1)}';

    return ToolScaffold(
      title: tr('Slope / Roof Pitch'),
      body: Column(
        children: [
          Text(
            tr(
              'Lay the phone on the slope to read its angle, grade and roof pitch.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.4,
                child: CustomPaint(
                  painter: _SlopePainter(
                    angle: angle,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          NeonText(text: '${angle.toStringAsFixed(1)}°', fontSize: 44),
          const SizedBox(height: 16),
          Row(
            children: [
              StatCard(
                label: tr('Grade'),
                value: '${(slope * 100).toStringAsFixed(1)}%',
              ),
              StatCard(
                label: tr('Roof pitch'),
                value: '${pitch.toStringAsFixed(1)} / 12',
              ),
              StatCard(label: tr('Ratio'), value: ratio),
            ],
          ),
          const SizedBox(height: 16),
          ToolActionButton(
            label: _held ? tr('HELD — Tap to resume') : tr('HOLD'),
            active: _held,
            onTap: () => setState(() {
              if (!_held) _heldAngle = liveAngle;
              _held = !_held;
            }),
          ),
        ],
      ),
    );
  }
}

class _SlopePainter extends CustomPainter {
  final double angle;
  final Color color;

  _SlopePainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width * 0.1, size.height * 0.85);
    final run = size.width * 0.8;
    final rise = min(
      tan(angle.clamp(0.0, 80.0) * pi / 180) * run,
      size.height * 0.75,
    );
    final top = Offset(origin.dx + run, origin.dy - rise);

    final guide = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 2;
    canvas.drawLine(origin, Offset(origin.dx + run, origin.dy), guide);
    canvas.drawLine(Offset(origin.dx + run, origin.dy), top, guide);

    final fill = Paint()..color = color.withValues(alpha: 0.12);
    canvas.drawPath(
      Path()
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(origin.dx + run, origin.dy)
        ..lineTo(top.dx, top.dy)
        ..close(),
      fill,
    );

    final slopePaint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(origin, top, slopePaint);

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCircle(center: origin, radius: 44),
      -atan2(rise, run),
      atan2(rise, run),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _SlopePainter oldDelegate) =>
      oldDelegate.angle != angle || oldDelegate.color != color;
}
