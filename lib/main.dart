import 'dart:async';

import 'package:admob_kit/admob_kit.dart';
import 'package:bubblelevel/providers/level_provider.dart';
import 'package:bubblelevel/services/ad_free_service.dart';
import 'package:flutter/material.dart';
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
    await AdMobService.initialize();
    await AdFreeService.restore();
    // Preload interstitial/rewarded so they're ready by the time a tool is
    // opened; app open ad is preloaded and auto-shown on resume by this call.
    AdManager.preloadAll();
    AppOpenAdManager.initialize();

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
