import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tfmoviles2/shared/domain/services/storage_service.dart';

class SecureStorageService implements StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _phoneKey = 'user_phone';

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

  @override
  Future<void> saveUserData({String? name, String? email, String? phone}) async {
    if (name != null) await _storage.write(key: _nameKey, value: name);
    if (email != null) await _storage.write(key: _emailKey, value: email);
    if (phone != null) await _storage.write(key: _phoneKey, value: phone);
  }

  @override
  Future<Map<String, String?>> getUserData() async {
    return {
      'name': await _storage.read(key: _nameKey),
      'email': await _storage.read(key: _emailKey),
      'phone': await _storage.read(key: _phoneKey),
    };
  }

  @override
  Future<void> removeUserData() async {
    await _storage.delete(key: _nameKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _phoneKey);
  }
}
