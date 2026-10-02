import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/admob_settings.dart';
import '../core/admob_logger.dart';
import '../core/admob_utils.dart';
import '../managers/banner_ad_manager.dart';

/// A self-contained 300x250 (medium rectangle) banner ad, centred in the
/// width it is given.
///
/// ```dart
/// const MediumRectangleAd()
/// ```
///
/// Reserves its 250px height while the first load is in flight so content
/// below it does not jump, then collapses to nothing if ads are disabled,
/// suppressed (e.g. after a "remove ads" purchase) or ultimately fail to
/// load.
class MediumRectangleAd extends StatefulWidget {
  /// Space added above and below the ad when it is shown.
  final EdgeInsetsGeometry padding;

  const MediumRectangleAd({
    super.key,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  State<MediumRectangleAd> createState() => _MediumRectangleAdState();
}

class _MediumRectangleAdState extends State<MediumRectangleAd> {
  BannerAd? _readyAd;
  bool _disposed = false;
  bool _gaveUp = false;
  int _retryCount = 0;

  bool get _enabled =>
      AdMobSettings.enableBanner && AdMobUtils.isSupportedPlatform;

  @override
  void initState() {
    super.initState();
    AdSuppression.changes.addListener(_onSuppressionChanged);
    _load();
  }

  void _onSuppressionChanged() {
    if (_disposed) return;
    if (!AdSuppression.isActive) {
      if (_readyAd == null) _load();
      return;
    }
    final ad = _readyAd;
    _readyAd = null;
    setState(() {});
    ad?.dispose();
  }

  void _load() {
    if (!_enabled) return;
    if (AdSuppression.isActive) {
      final remaining = AdSuppression.remaining;
      if (remaining != null) {
        Future.delayed(remaining + const Duration(seconds: 1), () {
          if (!_disposed) _load();
        });
      }
      return;
    }
    BannerAdManager.loadMediumRectangle(
      onLoaded: (ad) {
        if (_disposed) {
          ad.dispose();
          return;
        }
        setState(() => _readyAd = ad);
      },
      onFailed: (error) {
        if (_disposed) return;
        _retry();
      },
    );
  }

  void _retry() {
    if (_retryCount >= AdMobSettings.maxLoadRetry) {
      setState(() => _gaveUp = true);
      return;
    }
    _retryCount++;
    final delay = Duration(
      seconds: AdMobSettings.retryBaseDelaySeconds * _retryCount,
    );
    AdMobLogger.log(
        'Medium rectangle retry #$_retryCount in ${delay.inSeconds}s');
    Future.delayed(delay, () {
      if (!_disposed) _load();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    AdSuppression.changes.removeListener(_onSuppressionChanged);
    _readyAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _readyAd;
    if (ad == null) {
      if (!_enabled || _gaveUp || AdSuppression.isActive) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: widget.padding,
        child: const SizedBox(height: 250),
      );
    }
    return Padding(
      padding: widget.padding,
      child: Center(
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}
