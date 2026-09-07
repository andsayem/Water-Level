import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class ControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const ControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = true,
  });

  @override
  State<ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isActive ? AppColors.primary : Colors.white54;
    final borderColor = widget.isActive ? AppColors.primary.withValues(alpha: 0.4) : Colors.white12;
    final shadowColor = widget.isActive ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => isPressed = true);
      },
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 82,
        height: 82,
        transform: Matrix4.identity()..scaleByDouble(
            isPressed ? 0.92 : 1.0, isPressed ? 0.92 : 1.0, 1.0, 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2A2A), Color(0xFF121212)],
          ),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
              spreadRadius: 1,
            ),
            const BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: activeColor, size: 28),
            const SizedBox(height: 8),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: activeColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
