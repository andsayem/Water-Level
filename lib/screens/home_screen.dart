import 'package:bubblelevel/widgets/neon_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/circular_level.dart';
import '../widgets/control_button.dart';
import '../widgets/horizontal_level.dart';
import '../models/saved_reading.dart';
import '../screens/tools_screen.dart';
import '../services/history_service.dart';
import '../widgets/vertical_level.dart';
import 'package:admob_kit/admob_kit.dart';
import 'camera_level_screen.dart';
import 'compass_screen.dart';
import 'history_screen.dart';
import 'metrics_screen.dart';
import 'plumb_level_screen.dart';
import 'protractor_screen.dart';
import 'settings_screen.dart';
import 'water_level_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HistoryService _historyService = HistoryService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveReading(LevelProvider provider) async {
    final controller = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Save reading',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Label (e.g. "Shelf in kitchen")',
            hintStyle: TextStyle(color: AppColors.textTertiary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(
              controller.text.trim().isEmpty
                  ? 'Reading'
                  : controller.text.trim(),
            ),
            child: Text('Save', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (label == null) return;

    await _historyService.saveReading(
      SavedReading(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        label: label,
        x: provider.x,
        y: provider.y,
        timestamp: DateTime.now(),
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Reading Saved"),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LevelProvider>(context);

    final isCentered = provider.x.abs() < 0.5 && provider.y.abs() < 0.5;

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              /// TOP BAR
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(colors: AppColors.cardGradient),
                  border: Border.all(color: AppColors.primary.withValues(alpha: .2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .08),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    PopupMenuButton<WidgetBuilder>(
                      tooltip: 'Menu',
                      color: AppColors.card,
                      offset: const Offset(0, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: .2),
                        ),
                      ),
                      itemBuilder: (context) => [
                        for (final entry in _menuEntries)
                          PopupMenuItem<WidgetBuilder>(
                            value: entry.builder,
                            child: Row(
                              children: [
                                Icon(
                                  entry.icon,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  entry.label,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                      onSelected: (builder) {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: builder));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.card,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.grid_view_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const NeonText(text: "Water Level", fontSize: 22),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        provider.calibrate();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Calibrated Successfully"),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      onLongPress: () {
                        provider.reset();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Calibration Reset!"),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.card,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(Icons.tune, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              HorizontalLevel(x: provider.x),

              const SizedBox(height: 25),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),

                            width: isCentered ? 320 : 280,
                            height: isCentered ? 320 : 280,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: isCentered
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 
                                          0.6,
                                        ),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),

                          CircularLevel(x: provider.x, y: provider.y),
                        ],
                      ),
                    ),

                    const SizedBox(width: 18),

                    VerticalLevel(y: provider.y),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Angle display
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: isCentered
                        ? [
                            AppColors.primary.withValues(alpha: 0.2),
                            ...AppColors.panelGradient.skip(1),
                          ]
                        : AppColors.panelGradient,
                  ),
                  border: Border.all(
                    color: isCentered
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: .2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .08),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    NeonText(
                      text: "X = ${provider.formatAngle(provider.x)}",
                      fontSize: 22,
                    ),
                    NeonText(
                      text: "Y = ${provider.formatAngle(provider.y)}",
                      fontSize: 22,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ControlButton(
                      icon: provider.isLocked
                          ? Icons.lock_rounded
                          : Icons.lock_outline_rounded,
                      label: "Lock",
                      isActive: provider.isLocked,
                      onTap: () {
                        provider.toggleLock();
                      },
                    ),
                    const SizedBox(width: 14),
                    ControlButton(
                      icon: provider.isSoundEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      label: "Sound",
                      isActive: provider.isSoundEnabled,
                      onTap: () {
                        provider.toggleSound();
                      },
                    ),
                    const SizedBox(width: 14),
                    ControlButton(
                      icon: provider.isVibrationEnabled
                          ? Icons.vibration_rounded
                          : Icons.mobile_off_rounded,
                      label: "Vibration",
                      isActive: provider.isVibrationEnabled,
                      onTap: () {
                        provider.toggleVibration();
                      },
                    ),
                    const SizedBox(width: 14),
                    ControlButton(
                      icon: Icons.palette_rounded,
                      label: "Theme",
                      isActive: true, // Always active
                      onTap: () {
                        provider.toggleTheme();
                      },
                    ),
                    const SizedBox(width: 14),
                    ControlButton(
                      icon: Icons.bookmark_add_rounded,
                      label: "Save",
                      isActive: true,
                      onTap: () => _saveReading(provider),
                    ),
                    const SizedBox(width: 14),
                    ControlButton(
                      icon: Icons.percent_rounded,
                      label: provider.isPercentGrade ? "% Grade" : "Degrees",
                      isActive: provider.isPercentGrade,
                      onTap: () {
                        provider.toggleUnit();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const AdaptiveBannerAd(),
            ],
          ),
        ),
      ),
    );
  }
}

final List<_MenuEntry> _menuEntries = [
  _MenuEntry(
    icon: Icons.camera_alt_rounded,
    label: 'Camera Level',
    builder: (_) => const CameraLevelScreen(),
  ),
  _MenuEntry(
    icon: Icons.straighten_rounded,
    label: 'Plumb Level',
    builder: (_) => const PlumbLevelScreen(),
  ),
  _MenuEntry(
    icon: Icons.architecture_rounded,
    label: 'Protractor',
    builder: (_) => const ProtractorScreen(),
  ),
  _MenuEntry(
    icon: Icons.explore_rounded,
    label: 'Compass',
    builder: (_) => const CompassScreen(),
  ),
  _MenuEntry(
    icon: Icons.grid_view_rounded,
    label: 'All Tools',
    builder: (_) => const ToolsScreen(),
  ),
  _MenuEntry(
    icon: Icons.history_rounded,
    label: 'History',
    builder: (_) => const HistoryScreen(),
  ),
  _MenuEntry(
    icon: Icons.speed_rounded,
    label: 'Metrics',
    builder: (_) => const MetricsScreen(),
  ),
  _MenuEntry(
    icon: Icons.settings_rounded,
    label: 'Settings',
    builder: (_) => const SettingsScreen(),
  ),
  _MenuEntry(
    icon: Icons.info_outline_rounded,
    label: 'Info',
    builder: (_) => const WaterLevelInfoScreen(),
  ),
];

class _MenuEntry {
  final IconData icon;
  final String label;
  final WidgetBuilder builder;

  _MenuEntry({required this.icon, required this.label, required this.builder});
}
