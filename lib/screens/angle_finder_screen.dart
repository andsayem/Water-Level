import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/neon_text.dart';
import '../widgets/tool_scaffold.dart';
import '../widgets/ui_kit.dart';

/// Inclinometer with a target: pick an angle (e.g. 45° for a mitre or a
/// stair stringer) and tilt the work piece until the phone beeps.
///
/// Uses the screen's inclination against the horizontal, so it works in any
/// direction the phone is tilted.
class AngleFinderScreen extends StatefulWidget {
  const AngleFinderScreen({super.key});

  @override
  State<AngleFinderScreen> createState() => _AngleFinderScreenState();
}

class _AngleFinderScreenState extends State<AngleFinderScreen> {
  static const _targetKey = 'angle_finder_target';
  static const _presets = [15.0, 22.5, 30.0, 45.0, 60.0, 90.0];

  /// How close (in degrees) counts as "on target".
  static const _tolerance = 0.5;

  double _target = 45;
  bool _wasOnTarget = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final saved = prefs.getDouble(_targetKey);
      if (saved != null && mounted) setState(() => _target = saved);
    });
  }

  Future<void> _setTarget(double value) async {
    setState(() {
      _target = value.clamp(0.0, 180.0);
      _wasOnTarget = false;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_targetKey, _target);
  }

  Future<void> _customTarget() async {
    final controller = TextEditingController(text: _target.toString());
    final value = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          tr('Target angle (°)'),
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
            onPressed: () => Navigator.of(
              ctx,
            ).pop(double.tryParse(controller.text.replaceAll(',', '.'))),
            child: Text(tr('Done'), style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (value != null && value >= 0 && value <= 180) _setTarget(value);
  }

  void _feedback(LevelProvider provider) {
    if (provider.isSoundEnabled) SystemSound.play(SystemSoundType.click);
    if (provider.isVibrationEnabled) {
      Vibration.vibrate(duration: 80).catchError((_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelProvider>();
    final angle = provider.inclination;
    final diff = angle - _target;
    final onTarget = diff.abs() <= _tolerance;

    if (onTarget && !_wasOnTarget) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _feedback(provider));
    }
    _wasOnTarget = onTarget;

    final hint = onTarget
        ? tr('On target!')
        : (diff < 0 ? tr('Tilt more') : tr('Tilt less'));

    return ToolScaffold(
      title: tr('Angle Finder'),
      subtitle: tr('Beeps when the target angle is reached'),
      action: GlowIconButton(
        icon: Icons.edit_rounded,
        tooltip: tr('Custom angle'),
        onTap: _customTarget,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: _TargetGaugePainter(
                    angle: angle,
                    target: _target,
                    onTarget: onTarget,
                    accent: AppColors.primary,
                    track: AppColors.textTertiary,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NeonText(
                          text: '${angle.toStringAsFixed(1)}°',
                          fontSize: 46,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tr('Target')} ${_target.toStringAsFixed(1)}°',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LevelStatusPill(
                          isLevel: onTarget,
                          label: onTarget
                              ? hint.toUpperCase()
                              : '$hint  ${diff.abs().toStringAsFixed(1)}°',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in _presets)
                ChoiceChip(
                  label: Text('${preset % 1 == 0 ? preset.toInt() : preset}°'),
                  selected: _target == preset,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.card,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  labelStyle: TextStyle(
                    color: _target == preset
                        ? Colors.black
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => _setTarget(preset),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StepButton(
                icon: Icons.remove_rounded,
                onTap: () => _setTarget(_target - 0.5),
              ),
              Expanded(
                child: Slider(
                  value: _target,
                  min: 0,
                  max: 180,
                  divisions: 360,
                  activeColor: AppColors.primary,
                  label: '${_target.toStringAsFixed(1)}°',
                  onChanged: _setTarget,
                ),
              ),
              _StepButton(
                icon: Icons.add_rounded,
                onTap: () => _setTarget(_target + 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlowIconButton(icon: icon, onTap: onTap);
  }
}

/// 0-180° arc gauge with a target marker and the live angle needle.
class _TargetGaugePainter extends CustomPainter {
  final double angle;
  final double target;
  final bool onTarget;
  final Color accent;
  final Color track;

  _TargetGaugePainter({
    required this.angle,
    required this.target,
    required this.onTarget,
    required this.accent,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 18;
    final rect = Rect.fromCircle(center: center, radius: radius);
    // 0° at the left, 180° at the right, sweeping over the top.
    double toRad(double deg) => pi + deg * pi / 180;

    canvas.drawArc(
      rect,
      pi,
      pi,
      false,
      Paint()
        ..color = track.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    final live = angle.clamp(0.0, 180.0);
    canvas.drawArc(
      rect,
      pi,
      live * pi / 180,
      false,
      Paint()
        ..color = onTarget ? accent : Colors.orangeAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    // Ticks every 15°.
    final tick = Paint()
      ..color = track
      ..strokeWidth = 2;
    for (double d = 0; d <= 180; d += 15) {
      final a = toRad(d);
      final outer = center + Offset(cos(a), sin(a)) * (radius - 14);
      final inner =
          center + Offset(cos(a), sin(a)) * (radius - (d % 45 == 0 ? 30 : 22));
      canvas.drawLine(inner, outer, tick);
    }

    // Target marker.
    final t = toRad(target.clamp(0.0, 180.0));
    final tp = center + Offset(cos(t), sin(t)) * radius;
    canvas.drawCircle(tp, 11, Paint()..color = accent);
    canvas.drawCircle(
      tp,
      18,
      Paint()
        ..color = accent.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Needle.
    final n = toRad(live);
    canvas.drawLine(
      center + Offset(cos(n), sin(n)) * (radius * 0.45),
      center + Offset(cos(n), sin(n)) * (radius - 34),
      Paint()
        ..color = onTarget ? accent : Colors.orangeAccent
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TargetGaugePainter old) =>
      old.angle != angle ||
      old.target != target ||
      old.onTarget != onTarget ||
      old.accent != accent;
}
