import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'metrics_screen.dart';
import 'tools_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<LevelProvider>(context).isDarkTheme;

    final tabs = const [
      _TabData(icon: Icons.water_drop_rounded, label: 'Home'),
      _TabData(icon: Icons.grid_view_rounded, label: 'Tools'),
      _TabData(icon: Icons.history_rounded, label: 'History'),
      _TabData(icon: Icons.speed_rounded, label: 'Metrics'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          ToolsScreen(),
          HistoryScreen(),
          MetricsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(
            top: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
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
                BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  label: tab.label,
                ),
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
