import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/neon_text.dart';
import '../widgets/tool_scaffold.dart';

/// On-screen ruler: centimetres on the left edge, inches on the right, with a
/// draggable marker. Screen density varies per device, so the scale can be
/// calibrated against a standard bank / ID card (short edge 54 mm).
class RulerScreen extends StatefulWidget {
  const RulerScreen({super.key});

  @override
  State<RulerScreen> createState() => _RulerScreenState();
}

class _RulerScreenState extends State<RulerScreen> {
  static const _prefsKey = 'ruler_px_per_mm';

  /// Android defines 1 logical pixel as ~1/160 inch.
  static const _defaultPxPerMm = 160 / 25.4;
  static const _cardEdgeMm = 53.98;

  double _pxPerMm = _defaultPxPerMm;
  double _markerPx = 150;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_prefsKey);
    if (saved != null && mounted) setState(() => _pxPerMm = saved);
  }

  Future<void> _calibrate() async {
    double value = _pxPerMm;
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            tr('Calibrate ruler'),
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr(
                  'Place a bank / ID card on the screen and drag the slider until the box matches the short edge of the card (54 mm).',
                ),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                width: _cardEdgeMm * value,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Slider(
                value: value,
                min: 4.5,
                max: 8.5,
                activeColor: AppColors.primary,
                onChanged: (v) => setDialogState(() => value = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(_defaultPxPerMm),
              child: Text(tr('Reset')),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(value),
              child: Text(
                tr('Done'),
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    setState(() => _pxPerMm = result);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsKey, result);
  }

  @override
  Widget build(BuildContext context) {
    final mm = _markerPx / _pxPerMm;

    return ToolScaffold(
      title: tr('Ruler'),
      action: GestureDetector(
        onTap: _calibrate,
        child: Icon(Icons.tune_rounded, color: AppColors.primary),
      ),
      body: Column(
        children: [
          Text(
            tr('Drag the marker to measure'),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          NeonText(
            text:
                '${(mm / 10).toStringAsFixed(2)} cm  ·  ${(mm / 25.4).toStringAsFixed(2)} in',
            fontSize: 20,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxPx = constraints.maxHeight;
                final marker = _markerPx.clamp(0.0, maxPx);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (d) => setState(
                    () => _markerPx = d.localPosition.dy.clamp(0.0, maxPx),
                  ),
                  onTapDown: (d) => setState(
                    () => _markerPx = d.localPosition.dy.clamp(0.0, maxPx),
                  ),
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, maxPx),
                    painter: _RulerPainter(
                      pxPerMm: _pxPerMm,
                      markerPx: marker,
                      color: AppColors.primary,
                      tickColor: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double pxPerMm;
  final double markerPx;
  final Color color;
  final Color tickColor;

  _RulerPainter({
    required this.pxPerMm,
    required this.markerPx,
    required this.color,
    required this.tickColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tick = Paint()
      ..color = tickColor
      ..strokeWidth = 1;

    // Centimetre scale on the left edge.
    for (int mm = 0; mm * pxPerMm <= size.height; mm++) {
      final y = mm * pxPerMm;
      final len = mm % 10 == 0 ? 34.0 : (mm % 5 == 0 ? 22.0 : 12.0);
      canvas.drawLine(Offset(0, y), Offset(len, y), tick);
      if (mm % 10 == 0) _label(canvas, '${mm ~/ 10}', Offset(40, y), false);
    }

    // Inch scale on the right edge, in 1/8 inch steps.
    final pxPerEighth = pxPerMm * 25.4 / 8;
    for (int e = 0; e * pxPerEighth <= size.height; e++) {
      final y = e * pxPerEighth;
      final len = e % 8 == 0
          ? 34.0
          : (e % 4 == 0 ? 24.0 : (e % 2 == 0 ? 16.0 : 10.0));
      canvas.drawLine(Offset(size.width - len, y), Offset(size.width, y), tick);
      if (e % 8 == 0) {
        _label(canvas, '${e ~/ 8}', Offset(size.width - 40, y), true);
      }
    }

    // Marker.
    final marker = Paint()
      ..color = color
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(0, markerPx), Offset(size.width, markerPx), marker);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, markerPx),
      Paint()..color = color.withValues(alpha: 0.08),
    );
    canvas.drawCircle(
      Offset(size.width / 2, markerPx),
      9,
      Paint()..color = color,
    );
  }

  void _label(Canvas canvas, String text, Offset at, bool alignRight) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: tickColor, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = alignRight ? at.dx - tp.width : at.dx;
    final dy = (at.dy - tp.height / 2).clamp(0.0, double.infinity);
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _RulerPainter old) =>
      old.pxPerMm != pxPerMm ||
      old.markerPx != markerPx ||
      old.color != color ||
      old.tickColor != tickColor;
}
