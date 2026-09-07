import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_reading.dart';

class HistoryService {
  static const _key = 'saved_readings';

  Future<List<SavedReading>> loadReadings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final readings = raw
        .map((e) => SavedReading.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    return readings.reversed.toList();
  }

  Future<void> saveReading(SavedReading reading) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(reading.toJson()));
    await prefs.setStringList(_key, raw);
  }

  Future<void> deleteReading(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) {
      final json = jsonDecode(e) as Map<String, dynamic>;
      return json['id'] == id;
    });
    await prefs.setStringList(_key, raw);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
