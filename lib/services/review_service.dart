import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_links.dart';

class ReviewService {
  static const _launchCountKey = 'review_launch_count';
  static const _promptedKey = 'review_prompted';

  /// Launch on which the in-app review sheet is requested (once).
  static const _promptOnLaunch = 4;

  /// Counts app launches and asks for an in-app review once the user has
  /// come back a few times.
  static Future<void> registerLaunchAndMaybePrompt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt(_launchCountKey) ?? 0) + 1;
      await prefs.setInt(_launchCountKey, count);

      if (count < _promptOnLaunch || (prefs.getBool(_promptedKey) ?? false)) {
        return;
      }
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await prefs.setBool(_promptedKey, true);
        await review.requestReview();
      }
    } catch (e) {
      debugPrint('In-app review failed: $e');
    }
  }

  /// Opens the Play Store page so the user can rate the app.
  static Future<bool> openStoreListing() async {
    try {
      final market = Uri.parse('market://details?id=${AppLinks.packageId}');
      if (await launchUrl(market, mode: LaunchMode.externalApplication)) {
        return true;
      }
    } catch (_) {
      // No Play Store app; fall back to the browser below.
    }
    return launchUrl(
      Uri.parse(AppLinks.playStoreUrl),
      mode: LaunchMode.externalApplication,
    );
  }
}
