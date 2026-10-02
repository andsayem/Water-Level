import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/circular_level.dart';
import '../widgets/horizontal_level.dart';
import '../widgets/neon_text.dart';
import '../widgets/tool_scaffold.dart';
import '../widgets/ui_kit.dart';
import '../widgets/vertical_level.dart';

/// Vertical / plumb-bob level: hold the phone flat against a wall, pole, or
/// door frame (top of the phone pointing up) to check it is perfectly plumb.
///
/// With the phone upright, gravity should point purely along its own
/// top-to-bottom axis. Any lean forward/back or left/right shows up on the
/// x/z accelerometer axes instead, so the tilt formulas below differ from
/// the flat/horizontal mode used on the home screen.
class PlumbLevelScreen extends StatefulWidget {
  const PlumbLevelScreen({super.key});

  @override
  State<PlumbLevelScreen> createState() => _PlumbLevelScreenState();
}

class _PlumbLevelScreenState extends State<PlumbLevelScreen> {
  StreamSubscription<AccelerometerEvent>? _sub;

  double _smoothLeftRight = 0;
  double _smoothFrontBack = 0;

  double _leftRightOffset = 0;
  double _frontBackOffset = 0;

  /// Positive when the top leans to the right (right side lower), matching
  /// the flat-mode x axis so the level widgets float the bubble correctly.
  double _leftRight = 0;

  /// Positive when the top leans back, away from the viewer.
  double _frontBack = 0;

  @override
  void initState() {
    super.initState();
    _sub = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
        .listen(
          (event) {
            final leftRight = atan2(-event.x, event.y) * 180 / pi;
            final frontBack = atan2(event.z, event.y) * 180 / pi;

            _smoothLeftRight =
                _smoothLeftRight + (leftRight - _smoothLeftRight) * 0.15;
            _smoothFrontBack =
                _smoothFrontBack + (frontBack - _smoothFrontBack) * 0.15;

            if (!mounted) return;
            setState(() {
              _leftRight = _smoothLeftRight - _leftRightOffset;
              _frontBack = _smoothFrontBack - _frontBackOffset;
            });
          },
          onError: (Object error) {
            debugPrint('PlumbLevel accelerometer unavailable: $error');
          },
        );
  }

  void _calibrate() {
    _leftRightOffset = _smoothLeftRight;
    _frontBackOffset = _smoothFrontBack;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('Calibrated Successfully')),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tolerance = context.select<LevelProvider, double>(
      (p) => p.levelTolerance,
    );
    final isPlumb =
        _leftRight.abs() < tolerance && _frontBack.abs() < tolerance;

    return ToolScaffold(
      title: tr('Plumb Level'),
      subtitle: tr(
        'Hold the phone flat against a wall or pole, top pointing up.',
      ),
      action: GlowIconButton(
        icon: Icons.tune_rounded,
        tooltip: tr('Calibrate'),
        onTap: _calibrate,
      ),
      body: Column(
        children: [
          LevelStatusPill(
            isLevel: isPlumb,
            label: isPlumb
                ? tr('PLUMB')
                : '${tr('TILT')} ${totalTilt(_leftRight, _frontBack).toStringAsFixed(1)}°',
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FittedBox(
              // Keep the instrument layout fixed in right-to-left languages.
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SizedBox(
                  width: 392,
                  height: 372,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          HorizontalLevel(x: _leftRight),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: 300,
                            height: 290,
                            child: Center(
                              child: CircularLevel(
                                x: _leftRight,
                                y: _frontBack,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 22),
                      Padding(
                        padding: const EdgeInsets.only(top: 82),
                        child: VerticalLevel(y: _frontBack),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            highlight: isPlumb,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NeonText(
                  text: "L/R = ${_leftRight.toStringAsFixed(1)}°",
                  fontSize: 20,
                ),
                NeonText(
                  text: "F/B = ${_frontBack.toStringAsFixed(1)}°",
                  fontSize: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
