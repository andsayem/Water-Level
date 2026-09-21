import 'package:admob_kit/admob_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lets the user watch a rewarded ad to temporarily remove all ads.
/// Persists the ad-free window so it survives an app restart.
class AdFreeService {
  AdFreeService._();

  static const _prefsKey = 'ad_free_until_millis';
  static const rewardDuration = Duration(minutes: 30);

  /// Restores any still-active ad-free window from a previous session.
  /// Call once at startup, after `AdMobService.initialize()`.
  static Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_prefsKey);
    if (millis == null) return;

    final until = DateTime.fromMillisecondsSinceEpoch(millis);
    if (until.isAfter(DateTime.now())) {
      AdManager.suppressAdsUntil(until);
    } else {
      await prefs.remove(_prefsKey);
    }
  }

  /// Shows a rewarded ad; on reward, suppresses ads for [rewardDuration]
  /// and persists that window.
  static Future<AdShowResult> watchToRemoveAds() {
    return AdManager.showRewarded(
      onReward: () {
        final until = DateTime.now().add(rewardDuration);
        AdManager.suppressAdsUntil(until);
        SharedPreferences.getInstance().then((prefs) {
          prefs.setInt(_prefsKey, until.millisecondsSinceEpoch);
        });
      },
    );
  }
}
