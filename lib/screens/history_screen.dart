import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:admob_kit/admob_kit.dart';
import '../models/saved_reading.dart';
import '../services/history_service.dart';
import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../widgets/neon_text.dart';
import '../widgets/ui_kit.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _service = HistoryService();
  List<SavedReading> _readings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    HistoryService.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    HistoryService.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final readings = await _service.loadReadings();
    if (!mounted) return;
    setState(() {
      _readings = readings;
      _loading = false;
    });
  }

  Future<void> _delete(SavedReading reading) async {
    await _service.deleteReading(reading.id);
  }

  Future<void> _exportCsv() async {
    String cell(String v) => '"${v.replaceAll('"', '""')}"';
    final rows = [
      'Label,X (deg),Y (deg),Date',
      for (final r in _readings)
        [
          cell(r.label),
          r.x.toStringAsFixed(2),
          r.y.toStringAsFixed(2),
          cell(_formatTimestamp(r.timestamp)),
        ].join(','),
    ];
    final bytes = Uint8List.fromList(utf8.encode(rows.join('\n')));
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes,
            mimeType: 'text/csv',
            name: 'water_level_readings.csv',
          ),
        ],
        fileNameOverrides: ['water_level_readings.csv'],
        subject: 'Water Level readings',
      ),
    );
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          tr('Clear all readings?'),
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          tr('This will permanently delete every saved reading.'),
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(tr('Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              tr('Clear'),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watchAppSettings();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ScreenHeader(
                title: tr('History'),
                subtitle: tr('Your saved readings'),
                showBack: Navigator.of(context).canPop(),
                actions: [
                  if (_readings.isNotEmpty)
                    GlowIconButton(
                      icon: Icons.ios_share_rounded,
                      tooltip: tr('Export CSV'),
                      onTap: _exportCsv,
                    ),
                  if (_readings.isNotEmpty)
                    GlowIconButton(
                      icon: Icons.delete_sweep_rounded,
                      tooltip: tr('Clear'),
                      onTap: _clearAll,
                    ),
                ],
              ),
              Expanded(
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.textSecondary,
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        children: [
                          _SummaryCard(readings: _readings),
                          const MediumRectangleAd(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          if (_readings.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                tr(
                                  'No saved readings yet.\nUse the Save button on the home screen.',
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          for (final reading in _readings)
                            _ReadingTile(
                              reading: reading,
                              timestamp: _formatTimestamp(reading.timestamp),
                              onDelete: () => _delete(reading),
                            ),
                        ],
                      ),
              ),
              const AdaptiveBannerAd(),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}  ${two(local.hour)}:${two(local.minute)}';
  }
}

class _SummaryCard extends StatelessWidget {
  final List<SavedReading> readings;

  const _SummaryCard({required this.readings});

  @override
  Widget build(BuildContext context) {
    final levelCount = readings
        .where((r) => r.x.abs() < 0.5 && r.y.abs() < 0.5)
        .length;
    Widget stat(String label, String value) => Expanded(
      child: Column(
        children: [
          NeonText(text: value, fontSize: 24),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
        ],
      ),
    );
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: Row(
        children: [
          stat(tr('Saved'), '${readings.length}'),
          stat(tr('Level'), '$levelCount'),
          stat(tr('Tilted'), '${readings.length - levelCount}'),
        ],
      ),
    );
  }
}

class _ReadingTile extends StatelessWidget {
  final SavedReading reading;
  final String timestamp;
  final VoidCallback onDelete;

  const _ReadingTile({
    required this.reading,
    required this.timestamp,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLevel = reading.x.abs() < 0.5 && reading.y.abs() < 0.5;
    final color = isLevel ? AppColors.primary : Colors.orangeAccent;
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
            ),
            child: Icon(
              isLevel ? Icons.check_rounded : Icons.screen_rotation_alt,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reading.label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'X = ${_deg(reading.x)}   Y = ${_deg(reading.y)}',
                  style: TextStyle(color: AppColors.primary, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  timestamp,
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.textTertiary,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

/// One decimal place, without printing "-0.0" for tiny negative values.
String _deg(double v) => '${(v.abs() < 0.05 ? 0.0 : v).toStringAsFixed(1)}°';
