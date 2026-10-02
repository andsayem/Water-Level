import 'package:flutter/material.dart';

import '../services/review_service.dart';
import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/ui_kit.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'metrics_screen.dart';
import 'tools_screen.dart';

class MainShell extends StatefulWidget {
  /// Whether the App Open ad was just shown (and has now closed) on this
  /// cold start, so the Home tab should offer the Remove Ads popup shortly
  /// after appearing.
  final bool offerRemoveAdsAfterOpenAd;

  const MainShell({super.key, this.offerRemoveAdsAfterOpenAd = false});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Delay so the review sheet never competes with the App Open ad.
    Future.delayed(
      const Duration(seconds: 20),
      ReviewService.registerLaunchAndMaybePrompt,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watchAppSettings();
    final isDark = AppColors.isDark;

    final tabs = [
      _TabData(icon: Icons.water_drop_rounded, label: tr('Home')),
      _TabData(icon: Icons.grid_view_rounded, label: tr('Tools')),
      _TabData(icon: Icons.history_rounded, label: tr('History')),
      _TabData(icon: Icons.speed_rounded, label: tr('Metrics')),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            offerRemoveAdsAfterOpenAd: widget.offerRemoveAdsAfterOpenAd,
            onOpenAllTools: () => setState(() => _currentIndex = 1),
          ),
          const ToolsScreen(),
          const HistoryScreen(),
          const MetricsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(
            top: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 20,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDark
                ? Colors.white54
                : AppColors.textTertiary,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: [
              for (final tab in tabs)
                BottomNavigationBarItem(icon: Icon(tab.icon), label: tab.label),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabData {
  final IconData icon;
  final String label;

  const _TabData({required this.icon, required this.label});
}
