import 'package:flutter/material.dart';

import '../common/admob_helper.dart';
import '../utils/app_colors.dart';
import '../widgets/neon_text.dart';
import 'camera_level_screen.dart';
import 'compass_screen.dart';
import 'history_screen.dart';
import 'metrics_screen.dart';
import 'plumb_level_screen.dart';
import 'protractor_screen.dart';
import 'water_level_info_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  static int _navigationCount = 0;

  @override
  Widget build(BuildContext context) {
    final tools = <_ToolEntry>[
      _ToolEntry(
        icon: Icons.camera_alt_rounded,
        label: 'Camera Level',
        builder: (_) => const CameraLevelScreen(),
      ),
      _ToolEntry(
        icon: Icons.straighten_rounded,
        label: 'Plumb Level',
        builder: (_) => const PlumbLevelScreen(),
      ),
      _ToolEntry(
        icon: Icons.architecture_rounded,
        label: 'Protractor',
        builder: (_) => const ProtractorScreen(),
      ),
      _ToolEntry(
        icon: Icons.explore_rounded,
        label: 'Compass',
        builder: (_) => const CompassScreen(),
      ),
      _ToolEntry(
        icon: Icons.history_rounded,
        label: 'History',
        builder: (_) => const HistoryScreen(),
      ),
      _ToolEntry(
        icon: Icons.speed_rounded,
        label: 'Metrics',
        builder: (_) => const MetricsScreen(),
      ),
      _ToolEntry(
        icon: Icons.info_outline_rounded,
        label: 'Info',
        builder: (_) => const WaterLevelInfoScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const NeonText(text: 'Tools', fontSize: 20),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                itemCount: tools.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final tool = tools[index];
                  return GestureDetector(
                    onTap: () {
                      void openTool() {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: tool.builder));
                      }

                      _navigationCount++;
                      // Show an interstitial every 3rd tool opened, so ads don't
                      // interrupt every single navigation.
                      if (_navigationCount % 3 == 0) {
                        AdmobHelper.showInterstitialAd(onAdDismissed: openTool);
                      } else {
                        openTool();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF232323), Color(0xFF121212)],
                        ),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: .2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .08),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(tool.icon, color: AppColors.primary, size: 34),
                          const SizedBox(height: 12),
                          Text(
                            tool.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          AdmobHelper.getBannerAdWidget(),
        ],
      ),
    );
  }
}

class _ToolEntry {
  final IconData icon;
  final String label;
  final WidgetBuilder builder;

  _ToolEntry({required this.icon, required this.label, required this.builder});
}
