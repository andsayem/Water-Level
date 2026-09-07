import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../common/admob_helper.dart';
import '../utils/app_colors.dart';
import '../widgets/neon_text.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  StreamSubscription<CompassEvent>? _sub;
  double? _heading;
  bool _supported = true;

  @override
  void initState() {
    super.initState();
    if (FlutterCompass.events == null) {
      _supported = false;
      return;
    }
    _sub = FlutterCompass.events!.listen((event) {
      if (event.heading == null) return;
      setState(() => _heading = event.heading);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _cardinalFor(double heading) {
    const directions = [
      'N', 'NNE', 'NE', 'ENE',
      'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW',
      'W', 'WNW', 'NW', 'NNW',
    ];
    final index = ((heading % 360) / 22.5).round() % 16;
    return directions[index];
  }

  @override
  Widget build(BuildContext context) {
    final heading = _heading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF232323), Color(0xFF121212)],
                  ),
                  border: Border.all(color: AppColors.primary.withValues(alpha: .2)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.arrow_back_rounded, color: AppColors.primary),
                    ),
                    const Spacer(),
                    const NeonText(text: "Compass", fontSize: 20),
                    const Spacer(),
                    const SizedBox(width: 24),
                  ],
                ),
              ),

              Expanded(
                child: !_supported
                    ? const Center(
                        child: Text(
                          'Compass sensor not available on this device.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 15),
                        ),
                      )
                    : heading == null
                        ? const Center(
                            child: CircularProgressIndicator(color: Colors.white70),
                          )
                        : Center(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: -heading * pi / 180,
                                    child: CustomPaint(
                                      size: Size.infinite,
                                      painter: _CompassDialPainter(color: AppColors.primary),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_up_rounded,
                                    color: AppColors.primary,
                                    size: 46,
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),

              if (heading != null) ...[
                NeonText(text: "${heading.toStringAsFixed(0)}°", fontSize: 40),
                const SizedBox(height: 6),
                Text(
                  _cardinalFor(heading),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              AdmobHelper.getBannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  final Color color;

  _CompassDialPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 12;

    final ringPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ringPaint);

    final tickPaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 2;

    for (int deg = 0; deg < 360; deg += 10) {
      final rad = deg * pi / 180;
      final isMajor = deg % 90 == 0;
      final isMedium = deg % 30 == 0;
      final tickLen = isMajor ? 20.0 : (isMedium ? 14.0 : 8.0);
      final outer = Offset(
        center.dx + radius * sin(rad),
        center.dy - radius * cos(rad),
      );
      final inner = Offset(
        center.dx + (radius - tickLen) * sin(rad),
        center.dy - (radius - tickLen) * cos(rad),
      );
      canvas.drawLine(inner, outer, isMajor ? (Paint()..color = color..strokeWidth = 3) : tickPaint);
    }

    const labels = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    labels.forEach((deg, label) {
      final rad = deg * pi / 180;
      final pos = Offset(
        center.dx + (radius - 36) * sin(rad),
        center.dy - (radius - 36) * cos(rad),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: deg == 0 ? color : Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    });
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) => false;
}
