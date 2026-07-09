abstract class StorageService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> removeToken();
  Future<void> saveUserData({String? name, String? email, String? phone});
  Future<Map<String, String?>> getUserData();
  Future<void> removeUserData();
}
