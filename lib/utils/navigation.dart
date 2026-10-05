import 'package:admob_kit/admob_kit.dart';
import 'package:flutter/material.dart';

/// Opens a tool screen. Opening and closing a tool each count as an action
/// for the interstitial frequency cap (see AdMobSettings in main.dart), so
/// with an interval of 2 the interstitial lands on the way back out of a
/// tool - a natural break - instead of in front of the tool the user just
/// asked for. Navigation itself is never blocked on the ad.
Future<void> openTool(BuildContext context, WidgetBuilder builder) async {
  AdManager.registerAction();
  await Navigator.of(context).push(MaterialPageRoute(builder: builder));
  AdManager.registerAction();
}
