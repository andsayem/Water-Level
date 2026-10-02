import 'dart:async';

import 'package:admob_kit/admob_kit.dart';
import 'package:bubblelevel/providers/level_provider.dart';
import 'package:bubblelevel/services/ad_free_service.dart';
import 'package:bubblelevel/services/purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';
import 'utils/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sensor axes are read in portrait; rotating the UI would swap them.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Catch all framework-level errors so they never crash the app.
  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exception}');
    debugPrint(details.stack.toString());
  };

  // Catch all unhandled async errors that would otherwise be fatal.
  runZonedGuarded(
    () async {
      final purchaseService = PurchaseService();
      // Read saved preferences before the first frame so the chosen theme
      // and language are applied without a flash of the defaults.
      final prefs = await SharedPreferences.getInstance();
      await AppStrings.load(LevelProvider.savedLanguage(prefs));

      await AdMobService.initialize();
      await AdFreeService.restore();
      await purchaseService.restore();
      // Preload interstitial/rewarded so they're ready by the time a tool is
      // opened; app open ad is preloaded and auto-shown on resume by this call.
      AdManager.preloadAll();
      AppOpenAdManager.initialize();
      // Connects to the store and loads product details; not awaited so it
      // never delays first paint.
      purchaseService.initialize();

      runApp(WaterLevelApp(purchaseService: purchaseService, prefs: prefs));
    },
    (error, stackTrace) {
      debugPrint('Unhandled async error: $error');
      debugPrint(stackTrace.toString());
    },
  );
}

class WaterLevelApp extends StatelessWidget {
  final PurchaseService purchaseService;
  final SharedPreferences prefs;

  const WaterLevelApp({
    super.key,
    required this.purchaseService,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LevelProvider(prefs)),
        ChangeNotifierProvider.value(value: purchaseService),
      ],
      // Only theme/language changes should rebuild the app root - not every
      // sensor sample the provider publishes.
      child: Selector<LevelProvider, (bool, String)>(
        selector: (_, p) => (p.isDarkTheme, p.languageCode),
        builder: (context, settings, child) {
          final isDark = settings.$1;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            locale: AppStrings.locale,
            supportedLocales: [
              for (final language in AppStrings.languages) language.locale,
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
