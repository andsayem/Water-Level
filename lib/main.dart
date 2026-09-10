import 'dart:async';

import 'package:bubblelevel/common/admob_helper.dart';
import 'package:bubblelevel/providers/level_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch all framework-level errors so they never crash the app.
  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exception}');
    debugPrint(details.stack.toString());
  };

  // Catch all unhandled async errors that would otherwise be fatal.
  runZonedGuarded(() async {
    // Initialize AdMob (never block startup if it fails)
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('AdMob initialization failed: $e');
    }

    final adHelper = AdmobHelper();
    WidgetsBinding.instance.addObserver(adHelper);
    // Preload the App Open ad so it's ready when the app resumes from
    // background. It is only shown via didChangeAppLifecycleState(resumed);
    // showing it during the very first launch can overlap the splash screen
    // navigation and cause issues during automated review.
    adHelper.loadAppOpenAd();
    // Preload the interstitial so it's ready by the time a tool is opened
    AdmobHelper.loadInterstitialAd();

    runApp(const WaterLevelApp());
  }, (error, stackTrace) {
    debugPrint('Unhandled async error: $error');
    debugPrint(stackTrace.toString());
  });
}

class WaterLevelApp extends StatelessWidget {
  const WaterLevelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LevelProvider())],
      child: Consumer<LevelProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.isDarkTheme
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
