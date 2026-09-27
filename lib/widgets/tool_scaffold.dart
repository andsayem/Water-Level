import 'package:admob_kit/admob_kit.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'neon_text.dart';

/// Shared layout for tool screens: rounded top bar with back button and
/// title, the tool body, and a banner ad at the bottom.
class ToolScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? action;

  const ToolScaffold({
    super.key,
    required this.title,
    required this.body,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
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
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: NeonText(text: title, fontSize: 20),
                        ),
                      ),
                    ),
                    SizedBox(width: 24, child: action),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: body),
              const SizedBox(height: 8),
              const AdaptiveBannerAd(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-width primary action button used by the tool screens.
class ToolActionButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const ToolActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: active ? AppColors.primary : AppColors.card,
          border: Border.all(color: AppColors.primary),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.black : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small labelled value card (e.g. "Min 42 dB").
class StatCard extends StatelessWidget {
  final String label;
  final String value;

  const StatCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: AppColors.cardGradient),
          border: Border.all(color: AppColors.primary.withValues(alpha: .15)),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
