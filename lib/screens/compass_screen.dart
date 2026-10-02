import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/neon_text.dart';
import '../widgets/tool_scaffold.dart';

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
    _sub = FlutterCompass.events!.listen(
      (event) {
        if (event.heading == null) return;
        // The plugin reports -180..180; show the usual 0..359 bearing.
        setState(() => _heading = (event.heading! % 360 + 360) % 360);
      },
      // Missing magnetometer / sensor failure: surface the "not available"
      // message instead of crashing.
      onError: (Object _) {
        if (mounted) setState(() => _supported = false);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _cardinalFor(double heading) {
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];
    final index = ((heading % 360) / 22.5).round() % 16;
    return directions[index];
  }

  @override
  Widget build(BuildContext context) {
    final heading = _heading;

    return ToolScaffold(
      title: tr('Compass'),
      subtitle: tr('Keep the phone flat and away from metal'),
      body: !_supported
          ? Center(
              child: Text(
                tr('Compass sensor not available on this device.'),
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            )
          : heading == null
          ? Center(
              child: CircularProgressIndicator(color: AppColors.textSecondary),
            )
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: -heading * pi / 180,
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: _CompassDialPainter(
                                color: AppColors.primary,
                                trackColor: AppColors.textTertiary,
                                labelColor: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: AppColors.primary,
                              size: 46,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                NeonText(text: "${heading.round() % 360}°", fontSize: 40),
                const SizedBox(height: 6),
                Text(
                  _cardinalFor(heading),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  final Color color;
  final Color trackColor;
  final Color labelColor;

  _CompassDialPainter({
    required this.color,
    required this.trackColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 12;

    final ringPaint = Paint()
      ..color = trackColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ringPaint);

    final tickPaint = Paint()
      ..color = trackColor
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
      canvas.drawLine(
        inner,
        outer,
        isMajor
            ? (Paint()
                ..color = color
                ..strokeWidth = 3)
            : tickPaint,
      );
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
            color: deg == 0 ? color : labelColor,
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
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.trackColor != trackColor;
}
