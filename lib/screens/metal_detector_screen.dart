import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';

import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/neon_text.dart';
import '../widgets/tool_scaffold.dart';

/// Detects nearby ferrous metal (pipes, nails, wires in walls) from the rise
/// in magnetic field strength over a calibrated baseline.
class MetalDetectorScreen extends StatefulWidget {
  const MetalDetectorScreen({super.key});

  @override
  State<MetalDetectorScreen> createState() => _MetalDetectorScreenState();
}

class _MetalDetectorScreenState extends State<MetalDetectorScreen> {
  /// Rise over baseline (μT) that counts as "metal detected".
  static const _threshold = 15.0;

  StreamSubscription<MagnetometerEvent>? _sub;
  bool _supported = true;

  double _field = 0;
  double? _baseline;
  bool _wasDetected = false;

  @override
  void initState() {
    super.initState();
    _sub = magnetometerEventStream().listen(
      (e) {
        final magnitude = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
        if (!mounted) return;
        setState(() {
          _field = _field == 0
              ? magnitude
              : _field + (magnitude - _field) * 0.3;
          // Earth's field alone is ~25–65 μT; take the first reading as the
          // baseline until the user calibrates.
          _baseline ??= _field;
        });
        _checkDetection();
      },
      onError: (Object _) {
        if (mounted) setState(() => _supported = false);
      },
    );
  }

  void _checkDetection() {
    final detected = _baseline != null && _field - _baseline! > _threshold;
    if (detected &&
        !_wasDetected &&
        context.read<LevelProvider>().isVibrationEnabled) {
      Vibration.vibrate(duration: 120).catchError((_) {});
    }
    _wasDetected = detected;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LevelProvider>();
    final rise = _baseline == null ? 0.0 : max(0.0, _field - _baseline!);
    final detected = rise > _threshold;
    final strength = (rise / (_threshold * 4)).clamp(0.0, 1.0);
    final activeColor = detected ? Colors.redAccent : AppColors.primary;

    return ToolScaffold(
      title: tr('Metal Detector'),
      body: !_supported
          ? Center(
              child: Text(
                tr('Sensor not available on this device.'),
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : Column(
              children: [
                Text(
                  tr(
                    'Move the top of the phone slowly along the wall or surface.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeColor.withValues(
                          alpha: 0.08 + strength * 0.3,
                        ),
                        border: Border.all(color: activeColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(
                              alpha: 0.2 + strength * 0.5,
                            ),
                            blurRadius: 20 + strength * 40,
                            spreadRadius: strength * 12,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NeonText(
                            text: _field.toStringAsFixed(0),
                            fontSize: 52,
                          ),
                          Text(
                            'μT',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: strength,
                    minHeight: 14,
                    color: activeColor,
                    backgroundColor: AppColors.card,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  detected ? tr('Metal detected!') : tr('No metal nearby'),
                  style: TextStyle(
                    color: detected ? Colors.redAccent : AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ToolActionButton(
                  label: tr('Calibrate'),
                  onTap: () {
                    setState(() => _baseline = _field);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(tr('Calibrate away from metal')),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
