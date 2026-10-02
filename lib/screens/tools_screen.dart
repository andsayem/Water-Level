import 'package:admob_kit/admob_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/app_colors.dart';
import '../utils/navigation.dart';
import '../utils/strings.dart';
import '../utils/tool_catalog.dart';
import '../widgets/other_apps_section.dart';
import '../widgets/ui_kit.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watchAppSettings();
    final featured = toolCatalog.where((t) => t.isNew).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ScreenHeader(
                title: tr('Tools'),
                subtitle:
                    '${toolCatalog.length} ${tr('precision tools in one app')}',
                showBack: Navigator.of(context).canPop(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  children: [
                    SectionLabel(tr('New')),
                    _FeaturedRow(tools: featured),
                    const MediumRectangleAd(),
                    for (final category in toolCategories) ...[
                      SectionLabel(tr(category)),
                      _ToolGrid(
                        tools: toolCatalog
                            .where((t) => t.category == category)
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const OtherAppsSection(),
                  ],
                ),
              ),
              const AdaptiveBannerAd(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedRow extends StatelessWidget {
  final List<ToolInfo> tools;

  const _FeaturedRow({required this.tools});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tools.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final tool = tools[i];
          return GestureDetector(
                onTap: () => openTool(context, tool.builder),
                child: Container(
                  width: 210,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.28),
                        AppColors.cardGradient.last,
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(tool.icon, color: AppColors.primary, size: 30),
                          const Spacer(),
                          const _NewBadge(),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        tr(tool.label),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr(tool.description),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: (80 * i).ms, duration: 300.ms)
              .slideX(begin: 0.15, end: 0);
        },
      ),
    );
  }
}

class _ToolGrid extends StatelessWidget {
  final List<ToolInfo> tools;

  const _ToolGrid({required this.tools});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tools.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final tool = tools[index];
        return GlassCard(
              padding: const EdgeInsets.all(12),
              onTap: () => openTool(context, tool.builder),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.primary.withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          tool.icon,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const Spacer(),
                      if (tool.isNew) const _NewBadge(),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    tr(tool.label),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    tr(tool.description),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: (40 * index).ms, duration: 250.ms)
            .scaleXY(begin: 0.94, end: 1);
      },
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tr('NEW'),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
