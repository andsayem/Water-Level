import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/neon_text.dart';
import '../widgets/tool_scaffold.dart';
import '../widgets/ui_kit.dart';

/// Caravan / RV / camper leveler. With the phone lying flat on the floor,
/// top pointing to the front (hitch) of the vehicle, it shows how much the
/// low side and the front need to be raised or lowered to make it level.
///
/// Lift needed = distance between the supports x tan(tilt angle).
class CaravanLevelScreen extends StatefulWidget {
  const CaravanLevelScreen({super.key});

  @override
  State<CaravanLevelScreen> createState() => _CaravanLevelScreenState();
}

class _CaravanLevelScreenState extends State<CaravanLevelScreen> {
  static const _widthKey = 'caravan_width_cm';
  static const _lengthKey = 'caravan_length_cm';
  static const _inchKey = 'caravan_use_inch';

  /// Distance between the left and right wheels.
  double _widthCm = 200;

  /// Distance from the axle to the hitch / front jack.
  double _lengthCm = 400;
  bool _useInch = false;

  bool _held = false;
  double _heldX = 0;
  double _heldY = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _widthCm = prefs.getDouble(_widthKey) ?? _widthCm;
      _lengthCm = prefs.getDouble(_lengthKey) ?? _lengthCm;
      _useInch = prefs.getBool(_inchKey) ?? false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_widthKey, _widthCm);
    await prefs.setDouble(_lengthKey, _lengthCm);
    await prefs.setBool(_inchKey, _useInch);
  }

  String _fmt(double cm) => _useInch
      ? '${(cm / 2.54).toStringAsFixed(1)} in'
      : '${cm.toStringAsFixed(1)} cm';

  Future<void> _editSizes() async {
    final width = TextEditingController(
      text: (_useInch ? _widthCm / 2.54 : _widthCm).toStringAsFixed(0),
    );
    final length = TextEditingController(
      text: (_useInch ? _lengthCm / 2.54 : _lengthCm).toStringAsFixed(0),
    );
    final unit = _useInch ? 'in' : 'cm';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          tr('Vehicle size'),
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SizeField(
              controller: width,
              label: '${tr('Width between wheels')} ($unit)',
            ),
            const SizedBox(height: 12),
            _SizeField(
              controller: length,
              label: '${tr('Axle to hitch / front jack')} ($unit)',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(tr('Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(tr('Done'), style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    final w = double.tryParse(width.text.replaceAll(',', '.'));
    final l = double.tryParse(length.text.replaceAll(',', '.'));
    if (ok != true) return;
    final factor = _useInch ? 2.54 : 1.0;
    setState(() {
      if (w != null && w > 0 && w < 2000) _widthCm = w * factor;
      if (l != null && l > 0 && l < 5000) _lengthCm = l * factor;
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelProvider>();
    final x = _held ? _heldX : provider.x;
    final y = _held ? _heldY : provider.y;

    // x > 0: right side is lower. y > 0: front (top of phone) is higher.
    final sideLift = _widthCm * tan(x.abs().clamp(0.0, 45.0) * pi / 180);
    final frontChange = _lengthCm * tan(y.abs().clamp(0.0, 45.0) * pi / 180);
    final sideOk = provider.isWithinTolerance(x);
    final frontOk = provider.isWithinTolerance(y);

    final sideText = sideOk
        ? tr('Side to side is level')
        : '${x > 0 ? tr('Raise RIGHT side by') : tr('Raise LEFT side by')} ${_fmt(sideLift)}';
    final frontText = frontOk
        ? tr('Front to back is level')
        : '${y > 0 ? tr('Lower FRONT by') : tr('Raise FRONT by')} ${_fmt(frontChange)}';

    return ToolScaffold(
      title: tr('Caravan Leveler'),
      subtitle: tr('Phone flat on the floor, top towards the hitch'),
      action: GlowIconButton(
        icon: Icons.straighten_rounded,
        tooltip: tr('Vehicle size'),
        onTap: _editSizes,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 0.8,
                child: CustomPaint(
                  painter: _CaravanPainter(
                    x: x,
                    y: y,
                    sideOk: sideOk,
                    frontOk: frontOk,
                    accent: AppColors.primary,
                    body: AppColors.card,
                    outline: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          _InstructionCard(
            icon: Icons.swap_horiz_rounded,
            ok: sideOk,
            text: sideText,
            angle: provider.formatAngle(x),
          ),
          const SizedBox(height: 8),
          _InstructionCard(
            icon: Icons.swap_vert_rounded,
            ok: frontOk,
            text: frontText,
            angle: provider.formatAngle(y),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              StatCard(label: tr('Width'), value: _fmt(_widthCm)),
              StatCard(label: tr('Length'), value: _fmt(_lengthCm)),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _useInch = !_useInch);
                    _save();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: AppColors.primary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          tr('Unit'),
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _useInch ? 'inch' : 'cm',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ToolActionButton(
            label: _held ? tr('HELD — Tap to resume') : tr('HOLD'),
            active: _held,
            onTap: () => setState(() {
              if (!_held) {
                _heldX = provider.x;
                _heldY = provider.y;
              }
              _held = !_held;
            }),
          ),
        ],
      ),
    );
  }
}

class _SizeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _SizeField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  final IconData icon;
  final bool ok;
  final String text;
  final String angle;

  const _InstructionCard({
    required this.icon,
    required this.ok,
    required this.text,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.primary : Colors.orangeAccent;
    return GlassCard(
      highlight: ok,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle_rounded : icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          NeonText(text: angle, fontSize: 15),
        ],
      ),
    );
  }
}

/// Top-down view of a caravan; the low corners glow orange.
class _CaravanPainter extends CustomPainter {
  final double x;
  final double y;
  final bool sideOk;
  final bool frontOk;
  final Color accent;
  final Color body;
  final Color outline;

  _CaravanPainter({
    required this.x,
    required this.y,
    required this.sideOk,
    required this.frontOk,
    required this.accent,
    required this.body,
    required this.outline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width * 0.52;
    final h = size.height * 0.62;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.56),
      width: w,
      height: h,
    );
    const warn = Colors.orangeAccent;

    // Hitch (front).
    final hitch = Path()
      ..moveTo(rect.center.dx - w * 0.18, rect.top)
      ..lineTo(rect.center.dx, rect.top - size.height * 0.12)
      ..lineTo(rect.center.dx + w * 0.18, rect.top);
    canvas.drawPath(
      hitch,
      Paint()
        ..color = frontOk ? accent : warn
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(
      Offset(rect.center.dx, rect.top - size.height * 0.12),
      7,
      Paint()..color = frontOk ? accent : warn,
    );

    // Body.
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(22));
    canvas.drawRRect(rrect, Paint()..color = body);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = (sideOk && frontOk) ? accent : outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Wheels at the axle (slightly behind the middle).
    final axleY = rect.top + h * 0.62;
    final wheelSize = Size(w * 0.12, h * 0.2);
    final leftLow = !sideOk && x < 0;
    final rightLow = !sideOk && x > 0;
    void wheel(double cx, bool low) {
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, axleY),
          width: wheelSize.width,
          height: wheelSize.height,
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(r, Paint()..color = low ? warn : accent);
      if (low) {
        canvas.drawRRect(
          r.inflate(6),
          Paint()
            ..color = warn.withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
    }

    wheel(rect.left - wheelSize.width / 2, leftLow);
    wheel(rect.right + wheelSize.width / 2, rightLow);

    // Bubble showing the tilt (floats to the higher side).
    final bubbleRange = min(w, h) * 0.32;
    final bx = (-x * 6).clamp(-bubbleRange, bubbleRange);
    final by = (y * 6).clamp(-bubbleRange, bubbleRange);
    final center = Offset(rect.center.dx, rect.top + h * 0.38);
    final ring = Paint()
      ..color = outline.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, bubbleRange, ring);
    canvas.drawCircle(center, bubbleRange * 0.25, ring);
    canvas.drawCircle(
      center + Offset(bx, -by),
      12,
      Paint()..color = (sideOk && frontOk) ? accent : warn,
    );

    // Front label.
    final tp = TextPainter(
      text: TextSpan(
        text: tr('FRONT'),
        style: TextStyle(
          color: outline,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(rect.center.dx - tp.width / 2, rect.top + 10));
  }

  @override
  bool shouldRepaint(covariant _CaravanPainter old) =>
      old.x != x ||
      old.y != y ||
      old.sideOk != sideOk ||
      old.frontOk != frontOk ||
      old.accent != accent;
}
