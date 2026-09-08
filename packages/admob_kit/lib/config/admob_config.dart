import '../core/admob_utils.dart';
import 'admob_settings.dart';

/// The only file most apps need to edit.
///
/// Replace every `YOUR_...` placeholder below with the real App ID / Ad
/// Unit ID from your AdMob console for each platform. Everything else in
/// this library reads its IDs through the getters at the bottom of this
/// class, which automatically:
///
/// * pick the Android or iOS ID for the current platform, and
/// * substitute Google's official test ad unit IDs while
///   `AdMobSettings.useTestAds` is `true`, so you never have to remember
///   to swap IDs in and out while developing.
class AdMobConfig {
  AdMobConfig._();

  // ---------------------------------------------------------------------
  // App IDs (used in AndroidManifest.xml / Info.plist - see README)
  // ---------------------------------------------------------------------
  static const String androidAppId = 'ca-app-pub-1195883693665145~1254577778';
  static const String iosAppId = 'YOUR_IOS_APP_ID';

  // ---------------------------------------------------------------------
  // Banner
  // ---------------------------------------------------------------------
  static const String androidBannerId =
      'ca-app-pub-1195883693665145/1747504588';
  static const String iosBannerId = 'YOUR_IOS_BANNER_ID';

  // ---------------------------------------------------------------------
  // Adaptive banner (this app previously reused its banner unit here too)
  // ---------------------------------------------------------------------
  static const String androidAdaptiveBannerId =
      'ca-app-pub-1195883693665145/1747504588';
  static const String iosAdaptiveBannerId = 'YOUR_IOS_ADAPTIVE_BANNER_ID';

  // ---------------------------------------------------------------------
  // Interstitial
  // ---------------------------------------------------------------------
  static const String androidInterstitialId =
      'ca-app-pub-1195883693665145/7119628061';
  static const String iosInterstitialId = 'YOUR_IOS_INTERSTITIAL_ID';

  // ---------------------------------------------------------------------
  // Rewarded
  // ---------------------------------------------------------------------
  static const String androidRewardedId =
      'ca-app-pub-1195883693665145/5526967493';
  static const String iosRewardedId = 'YOUR_IOS_REWARDED_ID';

  // ---------------------------------------------------------------------
  // Rewarded interstitial
  // ---------------------------------------------------------------------
  static const String androidRewardedInterstitialId =
      'YOUR_ANDROID_REWARDED_INTERSTITIAL_ID';
  static const String iosRewardedInterstitialId =
      'YOUR_IOS_REWARDED_INTERSTITIAL_ID';

  // ---------------------------------------------------------------------
  // Native
  // ---------------------------------------------------------------------
  static const String androidNativeId = 'YOUR_ANDROID_NATIVE_ID';
  static const String iosNativeId = 'YOUR_IOS_NATIVE_ID';

  /// Must match the `factoryId` registered natively via
  /// `registerNativeAdFactory` (Android) / a `FLTNativeAdFactory`
  /// (iOS) - see README "Native Ad setup".
  static const String nativeAdFactoryId = 'adFactoryExample';

  // ---------------------------------------------------------------------
  // App Open
  // ---------------------------------------------------------------------
  static const String androidAppOpenId =
      'ca-app-pub-1195883693665145/3232353948';
  static const String iosAppOpenId = 'YOUR_IOS_APP_OPEN_ID';

  // ---------------------------------------------------------------------
  // Resolved IDs - use these from ad managers/widgets, never the raw
  // constants above directly, so test-ad substitution always applies.
  // ---------------------------------------------------------------------

  static String get appId => AdMobSettings.useTestAds
      ? _TestAdUnitIds.appId
      : AdMobUtils.pick(android: androidAppId, ios: iosAppId);

  static String get bannerId => AdMobSettings.useTestAds
      ? _TestAdUnitIds.banner
      : AdMobUtils.pick(android: androidBannerId, ios: iosBannerId);

  static String get adaptiveBannerId => AdMobSettings.useTestAds
      ? _TestAdUnitIds.adaptiveBanner
      : AdMobUtils.pick(
          android: androidAdaptiveBannerId,
          ios: iosAdaptiveBannerId,
        );

  static String get interstitialId => AdMobSettings.useTestAds
      ? _TestAdUnitIds.interstitial
      : AdMobUtils.pick(
          android: androidInterstitialId,
          ios: iosInterstitialId,
        );

  static String get rewardedId => AdMobSettings.useTestAds
      ? _TestAdUnitIds.rewarded
      : AdMobUtils.pick(android: androidRewardedId, ios: iosRewardedId);

  static String get rewardedInterstitialId => AdMobSettings.useTestAds
      ? _TestAdUnitIds.rewardedInterstitial
      : AdMobUtils.pick(
          android: androidRewardedInterstitialId,
          ios: iosRewardedInterstitialId,
        );

  static String get nativeId => AdMobSettings.useTestAds
      ? _TestAdUnitIds.native
      : AdMobUtils.pick(android: androidNativeId, ios: iosNativeId);

  static String get appOpenId => AdMobSettings.useTestAds
      ? _TestAdUnitIds.appOpen
      : AdMobUtils.pick(android: androidAppOpenId, ios: iosAppOpenId);
}

/// Google's official AdMob test ad unit IDs. These are publicly documented
/// constants (https://developers.google.com/admob/android/test-ads and
/// https://developers.google.com/admob/ios/test-ads) - always safe to use
/// during development, never real ad units.
class _TestAdUnitIds {
  _TestAdUnitIds._();

  static String get appId => AdMobUtils.pick(
        android: 'ca-app-pub-3940256099942544~3347511713',
        ios: 'ca-app-pub-3940256099942544~1458002511',
      );

  static String get banner => AdMobUtils.pick(
        android: 'ca-app-pub-3940256099942544/6300978111',
        ios: 'ca-app-pub-3940256099942544/2934735716',
      );

  static String get adaptiveBanner => AdMobUtils.pick(
        android: 'ca-app-pub-3940256099942544/9214589741',
        ios: 'ca-app-pub-3940256099942544/2435281174',
      );

  static String get interstitial => AdMobUtils.pick(
        android: 'ca-app-pub-3940256099942544/1033173712',
        ios: 'ca-app-pub-3940256099942544/4411468910',
      );

  static String get rewarded => AdMobUtils.pick(
        android: 'ca-app-pub-3940256099942544/5224354917',
        ios: 'ca-app-pub-3940256099942544/1712485313',
      );

  static String get rewardedInterstitial => AdMobUtils.pick(
        android: 'ca-app-pub-3940256099942544/5354046379',
        ios: 'ca-app-pub-3940256099942544/6978759866',
      );

  static String get native => AdMobUtils.pick(
        android: 'ca-app-pub-3940256099942544/2247696110',
        ios: 'ca-app-pub-3940256099942544/3986624511',
      );

  static String get appOpen => AdMobUtils.pick(
        android: 'ca-app-pub-3940256099942544/9257395921',
        ios: 'ca-app-pub-3940256099942544/5662855259',
      );
}
