import 'package:admob_kit/admob_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/neon_text.dart';
import '../utils/strings.dart';
import '../widgets/other_apps_section.dart';
import 'camera_level_screen.dart';
import 'compass_screen.dart';
import 'height_meter_screen.dart';
import 'history_screen.dart';
import 'metal_detector_screen.dart';
import 'metrics_screen.dart';
import 'plumb_level_screen.dart';
import 'protractor_screen.dart';
import 'ruler_screen.dart';
import 'settings_screen.dart';
import 'slope_screen.dart';
import 'sound_meter_screen.dart';
import 'surface_level_screen.dart';
import 'water_level_info_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the provider so this screen rebuilds when the theme toggles.
    context.watch<LevelProvider>();

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
        icon: Icons.blur_circular_rounded,
        label: 'Surface Level',
        builder: (_) => const SurfaceLevelScreen(),
      ),
      _ToolEntry(
        icon: Icons.roofing_rounded,
        label: 'Slope / Roof Pitch',
        builder: (_) => const SlopeScreen(),
      ),
      _ToolEntry(
        icon: Icons.square_foot_rounded,
        label: 'Ruler',
        builder: (_) => const RulerScreen(),
      ),
      _ToolEntry(
        icon: Icons.height_rounded,
        label: 'Height Meter',
        builder: (_) => const HeightMeterScreen(),
      ),
      _ToolEntry(
        icon: Icons.graphic_eq_rounded,
        label: 'Sound Meter',
        builder: (_) => const SoundMeterScreen(),
      ),
      _ToolEntry(
        icon: Icons.sensors_rounded,
        label: 'Metal Detector',
        builder: (_) => const MetalDetectorScreen(),
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
        icon: Icons.settings_rounded,
        label: 'Settings',
        builder: (_) => const SettingsScreen(),
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
        title: NeonText(text: tr('Tools'), fontSize: 20),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tools.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final tool = tools[index];
                    return GestureDetector(
                      onTap: () {
                        // Shows an interstitial every 3rd tool opened (see
                        // AdMobSettings.interstitialActionInterval), subject
                        // to cooldown - navigation itself is never blocked
                        // on the ad.
                        AdManager.registerAction();
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: tool.builder));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: AppColors.cardGradient,
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
                            Icon(tool.icon, color: AppColors.primary, size: 30),
                            const SizedBox(height: 8),
                            Text(
                              tr(tool.label),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const OtherAppsSection(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const AdaptiveBannerAd(),
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
