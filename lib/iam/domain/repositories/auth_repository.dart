import 'package:tfmoviles2/iam/domain/models/user_model.dart';

abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
}
