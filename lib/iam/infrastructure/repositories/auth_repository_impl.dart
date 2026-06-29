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
      print('DEBUG: Intentando login en: \${dio.options.baseUrl}/v1/users/login');
      print('DEBUG: Payload: {email: $email, password: $password}');
      
      final response = await dio.post('/v1/users/login', data: {
        'email': email,
        'password': password,
      });

      print('DEBUG: Status Code: \${response.statusCode}');
      print('DEBUG: Response Data: \${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        // Asumiendo que el backend devuelve un token y datos del usuario
        final token = data['token'];
        if (token != null) {
          await storageService.saveToken(token);
        }

        return User(
          id: data['id']?.toString() ?? '',
          email: data['email'] ?? email,
          name: data['name'],
        );
      }
      return null;
    } catch (e) {
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
      final response = await dio.post('/v1/users/sign-up', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
