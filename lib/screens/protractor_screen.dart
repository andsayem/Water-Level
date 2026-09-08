import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/admob_helper.dart';
import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/neon_text.dart';

class ProtractorScreen extends StatefulWidget {
  const ProtractorScreen({super.key});

  @override
  State<ProtractorScreen> createState() => _ProtractorScreenState();
}

class _ProtractorScreenState extends State<ProtractorScreen> {
  bool _held = false;
  double _heldAngle = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelProvider>();

    // Whichever axis is tilted the most is the one the user is measuring.
    final liveAngle = provider.x.abs() >= provider.y.abs()
        ? provider.x
        : provider.y;
    final angle = _held ? _heldAngle : liveAngle;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(colors: AppColors.cardGradient),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: .2),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    const NeonText(text: "Protractor", fontSize: 20),
                    const Spacer(),
                    GestureDetector(
                      onTap: provider.toggleUnit,
                      child: Icon(
                        Icons.percent_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Lay the phone against the slope, then tap Hold to freeze the reading.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),

              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.6,
                    child: CustomPaint(
                      painter: _ProtractorPainter(
                        angle: angle,
                        color: AppColors.primary,
                      ),
                      child: Align(
                        alignment: const Alignment(0, 0.55),
                        child: NeonText(
                          text: provider.formatAngle(angle),
                          fontSize: 34,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  setState(() {
                    if (!_held) _heldAngle = liveAngle;
                    _held = !_held;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: _held ? AppColors.primary : AppColors.card,
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Center(
                    child: Text(
                      _held ? "HELD — Tap to resume" : "HOLD",
                      style: TextStyle(
                        color: _held ? Colors.black : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AdmobHelper.getBannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProtractorPainter extends CustomPainter {
  final double angle;
  final Color color;

  _ProtractorPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = min(size.width / 2, size.height) - 12;

    final arcPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      arcPaint,
    );

    final tickPaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 2;
    final labelStyle = TextStyle(color: Colors.white54, fontSize: 11);

    for (int deg = -90; deg <= 90; deg += 10) {
      final rad = (deg - 90) * pi / 180;
      final isMajor = deg % 30 == 0;
      final outer = Offset(
        center.dx + radius * cos(rad),
        center.dy + radius * sin(rad),
      );
      final inner = Offset(
        center.dx + (radius - (isMajor ? 14 : 8)) * cos(rad),
        center.dy + (radius - (isMajor ? 14 : 8)) * sin(rad),
      );
      canvas.drawLine(inner, outer, tickPaint);

      if (isMajor) {
        final labelPos = Offset(
          center.dx + (radius - 30) * cos(rad),
          center.dy + (radius - 30) * sin(rad),
        );
        final tp = TextPainter(
          text: TextSpan(text: '${deg.abs()}°', style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, labelPos - Offset(tp.width / 2, tp.height / 2));
      }
    }

    // Needle
    final clamped = angle.clamp(-90.0, 90.0);
    final needleRad = (clamped - 90) * pi / 180;
    final needleEnd = Offset(
      center.dx + (radius - 20) * cos(needleRad),
      center.dy + (radius - 20) * sin(needleRad),
    );
    final needlePaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 7, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ProtractorPainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
