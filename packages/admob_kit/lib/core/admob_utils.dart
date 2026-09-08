import 'package:flutter/foundation.dart';

/// Platform detection that is safe to call on every Flutter target,
/// including web and desktop - unlike `dart:io`'s `Platform`, reading
/// these getters never throws or fails to compile on an unsupported
/// platform, so this library can be included in a project that also
/// targets web/desktop without breaking its build.
class AdMobUtils {
  AdMobUtils._();

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// AdMob (via `google_mobile_ads`) only supports Android and iOS.
  static bool get isSupportedPlatform => isAndroid || isIOS;

  /// Picks [android] or [ios] based on the current platform, or an empty
  /// string on any other platform.
  static String pick({required String android, required String ios}) {
    if (isAndroid) return android;
    if (isIOS) return ios;
    return '';
  }
}

/// Prevents more than one full-screen ad (interstitial, rewarded,
/// rewarded interstitial, app open) from being shown at the same time.
///
/// Every full-screen ad manager checks [isShowing] before presenting and
/// calls [markShowing]/[markDismissed] around the presentation, so host
/// apps get this protection for free just by going through `AdManager`.
class FullScreenAdGuard {
  FullScreenAdGuard._();

  static bool _isShowing = false;

  static bool get isShowing => _isShowing;

  static void markShowing() => _isShowing = true;

  static void markDismissed() => _isShowing = false;
}
