abstract class StorageService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> removeToken();
  Future<void> saveUserData({String? id, String? name, String? email, String? phone, String? photoUrl});
  Future<Map<String, String?>> getUserData();
  Future<void> removeUserData();
}
