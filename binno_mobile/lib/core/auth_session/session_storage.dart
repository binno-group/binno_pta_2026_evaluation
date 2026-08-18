import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SessionStorage {
  Future<String?> readRefreshToken();
  Future<void> writeRefreshToken(String token);
  Future<void> clear();
}

final class SecureSessionStorage implements SessionStorage {
  const SecureSessionStorage(this.storage);

  static const _refreshTokenKey = 'binno_refresh_token';
  final FlutterSecureStorage storage;

  @override
  Future<String?> readRefreshToken() => storage.read(key: _refreshTokenKey);

  @override
  Future<void> writeRefreshToken(String token) {
    return storage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<void> clear() => storage.delete(key: _refreshTokenKey);
}
