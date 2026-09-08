import 'dart:async';

import 'package:admob_kit/admob_kit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_colors.dart';
import '../widgets/neon_text.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const onboardingDoneKey = 'onboarding_done';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2500), _goNext);
  }

  Future<void> _goNext() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(SplashScreen.onboardingDoneKey) ?? false;

    if (!mounted) return;

    // Best-effort: shows immediately if an App Open ad already finished
    // preloading, otherwise resolves right away and we continue normally.
    await AdManager.showAppOpen();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => onboardingDone
            ? const MainShell()
            : const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: AppColors.cardGradient),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.water_drop_rounded,
                color: AppColors.primary,
                size: 64,
              ),
            ),
            const SizedBox(height: 30),
            const NeonText(text: 'Water Level', fontSize: 30),
            const SizedBox(height: 8),
            Text(
              'Precision level in your pocket',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}