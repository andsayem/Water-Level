import 'package:admob_kit/admob_kit.dart';
import 'package:flutter/material.dart';

/// Opens a tool screen. Every tool opened counts as an action for the
/// interstitial frequency cap (see AdMobSettings.interstitialActionInterval);
/// navigation itself is never blocked on the ad.
void openTool(BuildContext context, WidgetBuilder builder) {
  AdManager.registerAction();
  Navigator.of(context).push(MaterialPageRoute(builder: builder));
}
