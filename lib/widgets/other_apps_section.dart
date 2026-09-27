import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_colors.dart';
import '../utils/strings.dart';

class _OtherApp {
  final String name;
  final String description;
  final String icon;
  final String packageId;

  const _OtherApp(this.name, this.description, this.icon, this.packageId);
}

const _otherApps = [
  _OtherApp(
    'Color Mixer',
    'Mix colors and find exact shades',
    'assets/images/other_apps/color_mixer.png',
    'com.andsayem.colormixer',
  ),
  _OtherApp(
    'QR & Barcode Studio',
    'Scan and create QR codes & barcodes',
    'assets/images/other_apps/qr_barcode_studio.png',
    'com.andsayem.qrbarcodestudio',
  ),
  _OtherApp(
    'Medi Finder',
    'Find medicine info quickly',
    'assets/images/other_apps/medi_finder.jpg',
    'com.andsayem.medifinder',
  ),
  _OtherApp(
    'StepUP',
    'Walk & step tracker',
    'assets/images/other_apps/step_up.png',
    'com.andsayem.step_up',
  ),
  _OtherApp(
    'Income & Expense Tracker',
    'Track your daily transactions',
    'assets/images/other_apps/income_expense.png',
    'my.daily.transaction',
  ),
];

/// "Our Other Apps" list; each row opens the app's Play Store page.
class OtherAppsSection extends StatelessWidget {
  const OtherAppsSection({super.key});

  Future<void> _open(BuildContext context, String packageId) async {
    final market = Uri.parse('market://details?id=$packageId');
    final web = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageId',
    );
    try {
      if (await launchUrl(market, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {
      // No Play Store app; fall back to the browser below.
    }
    final opened = await launchUrl(web, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('Could not open link'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 12, left: 4),
          child: Text(
            tr('Our Other Apps'),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final app in _otherApps)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(colors: AppColors.cardGradient),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: .15),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _open(context, app.packageId),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(app.icon, width: 48, height: 48),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.name,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              app.description,
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.download_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
