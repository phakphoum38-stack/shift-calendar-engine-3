import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_store.dart';

class SecureTokenStore implements TokenStore {
  SecureTokenStore({
    FlutterSecureStorage? storage,
    this.storageKey = 'shift_calendar_engine_api_token',
  }) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  final String storageKey;

  @override
  Future<String?> read() {
    return _storage.read(key: storageKey);
  }

  @override
  Future<void> write(String token) {
    return _storage.write(key: storageKey, value: token);
  }

  @override
  Future<void> clear() {
    return _storage.delete(key: storageKey);
  }
}
