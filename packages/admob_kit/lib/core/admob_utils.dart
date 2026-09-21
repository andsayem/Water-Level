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

  /// Picks [android] or [ios] based on the current platform. Returns an
  /// empty string on any other platform, or if the platform-appropriate
  /// value is `null` (e.g. an app that only configured Android IDs and
  /// deliberately left [ios] unset).
  static String pick({required String android, String? ios}) {
    if (isAndroid) return android;
    if (isIOS) return ios ?? '';
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

/// Lets a host app temporarily suppress every ad this library would
/// otherwise show on its own initiative - `AdManager.registerAction()`,
/// `AdManager.showInterstitial()`, `AdManager.showAppOpen()` (including
/// its automatic on-resume trigger), and the `AdBanner`/`AdaptiveBannerAd`
/// widgets all check this.
///
/// This is a generic on/off mechanism only - it has no idea *why* a host
/// app suppresses ads (a rewarded "remove ads for 30 minutes" perk, a
/// premium purchase, anything else is entirely the app's business).
/// `AdManager.showRewarded`/`showRewardedInterstitial` deliberately ignore
/// this, since those are ads the app explicitly asked to show - most
/// often exactly how a user earns a suppression window in the first
/// place.
///
/// Most apps should use `AdManager`'s forwarding methods
/// (`isAdsSuppressed`, `suppressAdsFor`, etc.) rather than this class
/// directly.
class AdSuppression {
  AdSuppression._();

  static DateTime? _until;
  static bool _forever = false;
  static final ValueNotifier<int> _changes = ValueNotifier<int>(0);

  /// Fires whenever suppression is explicitly started or cleared (not on
  /// the passive, time-based expiry of a [suppressFor]/[suppressUntil]
  /// window). Lets an already-showing ad widget tear itself down right
  /// away - e.g. right after a "remove ads" purchase - instead of only
  /// checking suppression the next time it would load a fresh ad.
  static Listenable get changes => _changes;

  /// Whether ads are currently suppressed. Clears itself once [_until]
  /// has passed, so callers never need to know to "turn it back on".
  static bool get isActive {
    if (_forever) return true;
    final until = _until;
    if (until == null) return false;
    if (!DateTime.now().isBefore(until)) {
      _until = null;
      return false;
    }
    return true;
  }

  /// Time remaining until suppression lifts, or `null` if not active or
  /// suppressed indefinitely (see [suppressForever]).
  static Duration? get remaining {
    if (_forever) return null;
    final until = _until;
    if (until == null || !isActive) return null;
    return until.difference(DateTime.now());
  }

  static void suppressUntil(DateTime until) {
    _until = until;
    _changes.value++;
  }

  static void suppressFor(Duration duration) {
    _until = DateTime.now().add(duration);
    _changes.value++;
  }

  /// Suppresses ads indefinitely, e.g. after a permanent "remove ads"
  /// purchase. Only [clear] undoes this.
  static void suppressForever() {
    _forever = true;
    _changes.value++;
  }

  static void clear() {
    _until = null;
    _forever = false;
    _changes.value++;
  }
}
