import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/circular_level.dart';
import '../widgets/neon_text.dart';
import '../widgets/tool_scaffold.dart';

/// Large 2D bubble for checking that a table, floor or shelf is flat.
class SurfaceLevelScreen extends StatelessWidget {
  const SurfaceLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelProvider>();
    final isLevel = provider.isLevel;

    return ToolScaffold(
      title: tr('Surface Level'),
      body: Column(
        children: [
          Text(
            tr('Place the phone flat on the surface.'),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: isLevel
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.6),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                  child: CircularLevel(x: provider.x, y: provider.y),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: isLevel
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.card,
              border: Border.all(
                color: isLevel
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: .2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    NeonText(
                      text: "X = ${provider.formatAngle(provider.x)}",
                      fontSize: 20,
                    ),
                    NeonText(
                      text: "Y = ${provider.formatAngle(provider.y)}",
                      fontSize: 20,
                    ),
                  ],
                ),
                if (isLevel) ...[
                  const SizedBox(height: 8),
                  Text(
                    tr('Surface is level'),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
