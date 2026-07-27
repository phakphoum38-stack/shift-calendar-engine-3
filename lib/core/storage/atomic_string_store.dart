import 'package:shared_preferences/shared_preferences.dart';

/// Minimal string persistence boundary used by atomic payload storage.
abstract interface class StringStore {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);
}

/// Lazy SharedPreferences implementation that remains test-injectable.
class SharedPreferencesStringStore implements StringStore {
  SharedPreferencesAsync? _preferences;

  SharedPreferencesAsync get _instance =>
      _preferences ??= SharedPreferencesAsync();

  @override
  Future<String?> getString(String key) => _instance.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _instance.setString(key, value);
}

/// Controlled staged-storage failure.
class AtomicStorageException implements Exception {
  const AtomicStorageException(this.message);

  final String message;

  @override
  String toString() => 'AtomicStorageException: $message';
}

/// Two-slot payload store that keeps the last active value until verification.
class AtomicStringStore {
  AtomicStringStore({required this.namespace, StringStore? store})
    : store = store ?? SharedPreferencesStringStore();

  final String namespace;
  final StringStore store;

  String get _activeKey => '$namespace.active';
  String _slotKey(String slot) => '$namespace.slot.$slot';

  Future<String?> read() async {
    final active = await store.getString(_activeKey);
    if (active == null) return null;
    if (active != 'a' && active != 'b') {
      throw const AtomicStorageException('Invalid active storage slot.');
    }
    final payload = await store.getString(_slotKey(active));
    if (payload == null) {
      throw const AtomicStorageException('Active payload is missing.');
    }
    return payload;
  }

  Future<void> write(String payload) async {
    final current = await store.getString(_activeKey);
    if (current != null && current != 'a' && current != 'b') {
      throw const AtomicStorageException('Invalid active storage slot.');
    }
    final target = current == 'a' ? 'b' : 'a';
    await store.setString(_slotKey(target), payload);
    final staged = await store.getString(_slotKey(target));
    if (staged != payload) {
      throw const AtomicStorageException('Staged payload verification failed.');
    }
    await store.setString(_activeKey, target);
  }
}
