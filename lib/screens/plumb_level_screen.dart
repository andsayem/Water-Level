import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../common/admob_helper.dart';
import '../utils/app_colors.dart';
import '../widgets/circular_level.dart';
import '../widgets/horizontal_level.dart';
import '../widgets/neon_text.dart';
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

  double _leftRight = 0;
  double _frontBack = 0;

  @override
  void initState() {
    super.initState();
    _sub = accelerometerEventStream().listen((event) {
      final leftRight = atan2(event.x, event.y) * 180 / pi;
      final frontBack = atan2(event.z, event.y) * 180 / pi;

      _smoothLeftRight =
          _smoothLeftRight + (leftRight - _smoothLeftRight) * 0.15;
      _smoothFrontBack =
          _smoothFrontBack + (frontBack - _smoothFrontBack) * 0.15;

      setState(() {
        _leftRight = _smoothLeftRight - _leftRightOffset;
        _frontBack = _smoothFrontBack - _frontBackOffset;
      });
    });
  }

  void _calibrate() {
    _leftRightOffset = _smoothLeftRight;
    _frontBackOffset = _smoothFrontBack;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlumb = _leftRight.abs() < 0.5 && _frontBack.abs() < 0.5;

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
                    const NeonText(text: "Plumb Level", fontSize: 20),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        _calibrate();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Calibrated Successfully"),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Icon(Icons.tune, color: AppColors.primary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Text(
                'Hold the phone flat against a wall or pole, top pointing up.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),

              HorizontalLevel(x: _leftRight),

              const SizedBox(height: 25),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: CircularLevel(x: _leftRight, y: _frontBack),
                      ),
                    ),
                    const SizedBox(width: 18),
                    VerticalLevel(y: _frontBack),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: isPlumb
                        ? [
                            AppColors.primary.withValues(alpha: 0.2),
                            ...AppColors.panelGradient.skip(1),
                          ]
                        : AppColors.panelGradient,
                  ),
                  border: Border.all(
                    color: isPlumb
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: .2),
                  ),
                ),
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
              const SizedBox(height: 8),
              AdmobHelper.getBannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
