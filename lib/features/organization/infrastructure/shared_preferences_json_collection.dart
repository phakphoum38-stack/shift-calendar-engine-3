import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Versioned JSON collection stored atomically under one preferences key.
final class SharedPreferencesJsonCollection {
  SharedPreferencesJsonCollection({
    required SharedPreferences preferences,
    required String key,
    this.schemaVersion = 1,
  })  : _preferences = preferences,
        _key = key;

  final SharedPreferences _preferences;
  final String _key;
  final int schemaVersion;

  List<Map<String, Object?>> read() {
    final source = _preferences.getString(_key);
    if (source == null || source.trim().isEmpty) return const [];

    final root = jsonDecode(source);
    if (root is! Map<String, Object?>) {
      throw const FormatException('Collection root must be a JSON object.');
    }
    final version = root['schemaVersion'];
    if (version is! int || version > schemaVersion) {
      throw FormatException('Unsupported schema version: $version');
    }
    final records = root['records'];
    if (records is! List) {
      throw const FormatException('Collection records must be a JSON array.');
    }
    return records
        .whereType<Map>()
        .map((item) => item.cast<String, Object?>())
        .toList(growable: false);
  }

  Future<void> write(Iterable<Map<String, Object?>> records) async {
    final payload = jsonEncode({
      'schemaVersion': schemaVersion,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'records': records.toList(growable: false),
    });
    final saved = await _preferences.setString(_key, payload);
    if (!saved) throw StateError('Could not persist collection $_key.');
  }
}
