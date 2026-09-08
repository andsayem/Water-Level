import 'package:flutter/material.dart';

import '../common/admob_helper.dart';
import '../models/saved_reading.dart';
import '../services/history_service.dart';
import '../utils/app_colors.dart';
import '../widgets/neon_text.dart';

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
    _load();
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
    _load();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Clear all readings?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'This will permanently delete every saved reading.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.clearAll();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const NeonText(text: 'History', fontSize: 20),
        actions: [
          if (_readings.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete_sweep_rounded,
                color: AppColors.textSecondary,
              ),
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.textSecondary),
            )
          : _readings.isEmpty
          ? Center(
              child: Text(
                'No saved readings yet.\nUse the Save button on the home screen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textTertiary, fontSize: 15),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _readings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final reading = _readings[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(colors: AppColors.cardGradient),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: .15),
                    ),
                  ),
                  child: Row(
                    children: [
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
                              'X = ${reading.x.toStringAsFixed(1)}°   Y = ${reading.y.toStringAsFixed(1)}°',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatTimestamp(reading.timestamp),
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () => _delete(reading),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(child: AdmobHelper.getBannerAdWidget()),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}  ${two(local.hour)}:${two(local.minute)}';
  }
}
