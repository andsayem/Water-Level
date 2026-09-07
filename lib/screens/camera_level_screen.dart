import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/admob_helper.dart';
import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/neon_text.dart';

class CameraLevelScreen extends StatefulWidget {
  const CameraLevelScreen({super.key});

  @override
  State<CameraLevelScreen> createState() => _CameraLevelScreenState();
}

class _CameraLevelScreenState extends State<CameraLevelScreen> {
  CameraController? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _error = "No camera found on this device.");
        return;
      }
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
      setState(() => _controller = controller);
    } catch (e) {
      if (mounted) setState(() => _error = "Camera unavailable.\n$e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelProvider>();
    final isCentered = provider.x.abs() < 0.5 && provider.y.abs() < 0.5;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),

          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: _LevelOverlayPainter(
                rollDegrees: provider.x,
                isCentered: isCentered,
                color: AppColors.primary,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  const NeonText(text: "Camera Level", fontSize: 18),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.black.withOpacity(0.55),
                      border: Border.all(
                        color: isCentered
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NeonText(
                          text: "X = ${provider.x.toStringAsFixed(1)}°",
                          fontSize: 18,
                        ),
                        const SizedBox(width: 24),
                        NeonText(
                          text: "Y = ${provider.y.toStringAsFixed(1)}°",
                          fontSize: 18,
                        ),
                      ],
                    ),
                  ),
                  AdmobHelper.getBannerAdWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white70),
      );
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.previewSize!.height,
        height: controller.value.previewSize!.width,
        child: CameraPreview(controller),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.5),
          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }
}

/// Draws a fixed crosshair (the phone's own frame) plus a line that rotates
/// with the true horizon (gravity). Rotating the phone until the two lines
/// overlap means the camera/frame is level.
class _LevelOverlayPainter extends CustomPainter {
  final double rollDegrees;
  final bool isCentered;
  final Color color;

  _LevelOverlayPainter({
    required this.rollDegrees,
    required this.isCentered,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final activeColor = isCentered ? color : Colors.white;

    final fixedPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(center.dx - 40, center.dy),
      Offset(center.dx + 40, center.dy),
      fixedPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 40),
      Offset(center.dx, center.dy + 40),
      fixedPaint,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rollDegrees * pi / 180);

    final horizonPaint = Paint()
      ..color = activeColor
      ..strokeWidth = 2.5;
    final lineLength = size.width * 0.42;
    canvas.drawLine(
      Offset(-lineLength, 0),
      Offset(lineLength, 0),
      horizonPaint,
    );

    final dotPaint = Paint()..color = activeColor;
    canvas.drawCircle(Offset.zero, 5, dotPaint);
    canvas.drawCircle(Offset(-lineLength, 0), 3, dotPaint);
    canvas.drawCircle(Offset(lineLength, 0), 3, dotPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LevelOverlayPainter oldDelegate) {
    return oldDelegate.rollDegrees != rollDegrees ||
        oldDelegate.isCentered != isCentered;
  }
}
