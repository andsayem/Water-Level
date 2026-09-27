import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/neon_text.dart';

/// Measures the height of a tree / building by triangulation:
/// the phone is held at a known height, aimed at the object's base (gives the
/// distance) and then at its top (gives the height above the phone).
class HeightMeterScreen extends StatefulWidget {
  const HeightMeterScreen({super.key});

  @override
  State<HeightMeterScreen> createState() => _HeightMeterScreenState();
}

class _HeightMeterScreenState extends State<HeightMeterScreen> {
  CameraController? _camera;
  StreamSubscription<AccelerometerEvent>? _sensorSub;
  String? _error;

  /// Camera elevation above the horizon, in degrees (negative = pointing down).
  double _elevation = 0;

  double _phoneHeight = 1.5;
  double? _distance;
  double? _height;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _sensorSub = accelerometerEventStream().listen(
      (e) {
        final g = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
        if (g == 0) return;
        // The back camera looks along the device's -Z axis.
        final raw = asin((-e.z / g).clamp(-1.0, 1.0)) * 180 / pi;
        if (mounted) {
          setState(() => _elevation = _elevation + (raw - _elevation) * 0.2);
        }
      },
      onError: (Object _) {
        if (mounted) {
          setState(() => _error = tr('Sensor not available on this device.'));
        }
      },
    );
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _camera = controller);
    } catch (e) {
      debugPrint('Height meter camera unavailable: $e');
    }
  }

  @override
  void dispose() {
    _sensorSub?.cancel();
    _camera?.dispose();
    super.dispose();
  }

  void _onMark() {
    if (_height != null) {
      setState(() {
        _distance = null;
        _height = null;
      });
      return;
    }
    if (_distance == null) {
      if (_elevation > -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('Aim below the horizon for the base.'))),
        );
        return;
      }
      setState(() => _distance = _phoneHeight / tan(-_elevation * pi / 180));
      return;
    }
    setState(
      () => _height = _phoneHeight + _distance! * tan(_elevation * pi / 180),
    );
  }

  Future<void> _editPhoneHeight() async {
    final controller = TextEditingController(text: _phoneHeight.toString());
    final value = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          tr('Phone height (m)'),
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tr('Cancel')),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(double.tryParse(controller.text)),
            child: Text(tr('Done'), style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (value != null && value > 0 && value < 10) {
      setState(() {
        _phoneHeight = value;
        _distance = null;
        _height = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _distance == null ? 1 : 2;
    final buttonLabel = _height != null
        ? tr('Measure again')
        : (step == 1 ? tr('Mark base') : tr('Mark top'));
    final hint = step == 1
        ? tr(
            '1. Aim the crosshair at the BASE of the object and tap the button.',
          )
        : tr(
            '2. Aim the crosshair at the TOP of the object and tap the button.',
          );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildPreview(),
          const IgnorePointer(child: _Crosshair()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      _RoundButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Center(
                          child: NeonText(
                            text: tr('Height Meter'),
                            fontSize: 18,
                          ),
                        ),
                      ),
                      _RoundButton(
                        icon: Icons.height_rounded,
                        onTap: _editPhoneHeight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_error != null || _height == null)
                    _Panel(
                      child: Text(
                        _error ?? hint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  const Spacer(),
                  _Panel(
                    child: Column(
                      children: [
                        NeonText(
                          text: '${_elevation.toStringAsFixed(1)}°',
                          fontSize: 16,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${tr('Phone height (m)')}: ${_phoneHeight.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        if (_distance != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${tr('Distance')}: ${_distance!.toStringAsFixed(1)} m',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                        if (_height != null) ...[
                          const SizedBox(height: 6),
                          NeonText(
                            text:
                                '${tr('Height')}: ${_height!.toStringAsFixed(1)} m',
                            fontSize: 26,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _error == null ? _onMark : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final controller = _camera;
    final previewSize = controller?.value.previewSize;
    if (controller == null ||
        !controller.value.isInitialized ||
        previewSize == null) {
      return const ColoredBox(color: Colors.black);
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: previewSize.height,
        height: previewSize.width,
        child: CameraPreview(controller),
      ),
    );
  }
}

class _Crosshair extends StatelessWidget {
  const _Crosshair();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 90,
        height: 90,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(width: 90, height: 2, color: AppColors.primary),
            Container(width: 2, height: 90, color: AppColors.primary),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withValues(alpha: 0.55),
        border: Border.all(color: AppColors.primary.withValues(alpha: .3)),
      ),
      child: child,
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.5),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }
}
