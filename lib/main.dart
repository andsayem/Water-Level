import 'package:bubblelevel/common/admob_helper.dart';
import 'package:bubblelevel/providers/level_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ Initialize AdMob
  await MobileAds.instance.initialize();

  final adHelper = AdmobHelper();
  WidgetsBinding.instance.addObserver(adHelper);
  // Load and show App Open ad
  adHelper.loadAppOpenAd(
    onLoaded: () {
      Future.delayed(const Duration(seconds: 2), () {
        AdmobHelper.showAppOpenAd();
      });
    },
  );
  // Preload the interstitial so it's ready by the time a tool is opened
  AdmobHelper.loadInterstitialAd();

  runApp(const WaterLevelApp());
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
