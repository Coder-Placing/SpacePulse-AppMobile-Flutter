import 'package:dio/dio.dart';
import 'package:tfmoviles2/iam/domain/models/user_model.dart';
import 'package:tfmoviles2/iam/domain/repositories/auth_repository.dart';
import 'package:tfmoviles2/shared/domain/services/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.dio,
    required this.storageService,
  });

  @override
  Future<User?> login(String email, String password) async {
    try {
      print('DEBUG: Intentando login en: ${dio.options.baseUrl}/users/login');
      print('DEBUG: Payload: {email: $email, password: $password}');

      final response = await dio.post('/users/login', data: {
        'email': email,
        'password': password,
      });

      print('DEBUG: Status Code: ${response.statusCode}');
      print('DEBUG: Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        final token = data['token'];
        if (token != null) {
          await storageService.saveToken(token);
        }

        return User(
          id: data['userId']?.toString() ?? '',
          email: data['email'] ?? email,
          name: data['fullName'],
        );
      }

      return null;
    } catch (e) {
      print('ERROR LOGIN: $e');
      return null;
    }
  }

@override
Future<bool> register({
required String name,
required String email,
required String phone,
required String password,
}) async {
try {
print('DEBUG: Intentando registro en: ${dio.options.baseUrl}/users/register');

final response = await dio.post('/users/register', data: {
'email': email,
'password': password,
'fullName': name,
'phone': phone,
'role': 'Remodeler',
'photo': '',
});

print('DEBUG: Status Code: ${response.statusCode}');
print('DEBUG: Response Data: ${response.data}');

return response.statusCode == 200 || response.statusCode == 201;
} catch (e) {
print('ERROR REGISTER: $e');
return false;
}
}
}