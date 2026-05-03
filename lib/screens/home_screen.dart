import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/level_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/circular_level.dart';
import '../widgets/control_button.dart';
import '../widgets/horizontal_level.dart';
import '../widgets/neon_text.dart';
import '../widgets/vertical_level.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              /// ================= TOP BAR =================
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF232323), Color(0xFF121212)],
                  ),
                  border: Border.all(color: AppColors.primary.withOpacity(.2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(.08),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // GestureDetector(
                    //   onTap: () {
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(
                    //         content: Text("Menu Coming Soon!"),
                    //         backgroundColor: Colors.grey,
                    //         duration: Duration(seconds: 1),
                    //       ),
                    //     );
                    //   },
                    //   child: const Icon(
                    //     Icons.menu_rounded,
                    //     color: Colors.white,
                    //   ),
                    // ),
                    const Spacer(),

                    const NeonText(text: "Water Level", fontSize: 22),

                    const Spacer(),

                    /// CALIBRATION BUTTON (REAL FUNCTION)
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
                              color: AppColors.primary.withOpacity(0.2),
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

              /// ================= HORIZONTAL LEVEL =================
              HorizontalLevel(x: provider.x),

              const SizedBox(height: 25),

              /// ================= CENTER AREA =================
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// CIRCULAR LEVEL (MAIN)
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          /// CENTER GLOW WHEN PERFECT
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isCentered ? 320 : 280,
                            height: isCentered ? 320 : 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: isCentered
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
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

                    /// VERTICAL LEVEL
                    VerticalLevel(y: provider.y),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              /// ================= ANGLE DISPLAY =================
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
                            AppColors.primary.withOpacity(0.2),
                            const Color(0xFF121212),
                          ]
                        : const [Color(0xFF222222), Color(0xFF121212)],
                  ),
                  border: Border.all(
                    color: isCentered
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(.08),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    NeonText(
                      text: "X = ${provider.x.toStringAsFixed(1)}°",
                      fontSize: 22,
                    ),
                    NeonText(
                      text: "Y = ${provider.y.toStringAsFixed(1)}°",
                      fontSize: 22,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              /// ================= CONTROL BUTTONS =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  ControlButton(
                    icon: Icons.palette_rounded,
                    label: "Theme",
                    isActive: true, // Always active
                    onTap: () {
                      provider.toggleTheme();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
