import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tfmoviles2/shared/domain/services/storage_service.dart';

class SecureStorageService implements StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  @override
  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
