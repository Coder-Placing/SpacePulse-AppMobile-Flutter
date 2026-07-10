import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tfmoviles2/iam/domain/models/user_model.dart';
import 'package:tfmoviles2/iam/domain/models/payment_method.dart';
import 'package:tfmoviles2/iam/domain/repositories/auth_repository.dart';
import 'package:tfmoviles2/shared/domain/services/storage_service.dart';
import 'package:tfmoviles2/shared/infrastructure/services/imgbb_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;
  final StorageService storageService;
  final ImgBBService imgBBService;

  AuthRepositoryImpl({
    required this.dio,
    required this.storageService,
    required this.imgBBService,
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
        
        final userId = (data['id'] ?? data['userId'])?.toString() ?? '';

        final fullUser = await getUserById(userId);
        
        if (fullUser != null) {
          await storageService.saveUserData(
            id: fullUser.id,
            name: fullUser.name,
            email: fullUser.email,
            phone: fullUser.phone,
            photoUrl: fullUser.photoUrl,
          );
          return fullUser;
        }

        final userEmail = data['email'] ?? email;
        final userName = (data['fullName'] ?? data['name'])?.toString();
        final userPhone = data['phone']?.toString();
        final userPhoto = data['photo']?.toString();

        await storageService.saveUserData(
          id: userId,
          name: userName,
          email: userEmail,
          phone: userPhone,
          photoUrl: userPhoto,
        );

        return User(
          id: userId,
          email: userEmail,
          name: userName,
          phone: userPhone,
          photoUrl: userPhoto,
        );
      }
      return null;
    } catch (e) {
      print('ERROR LOGIN: $e');
      return null;
    }
  }

  @override
  Future<User?> getUserById(String id) async {
    try {
      if (id.isEmpty) return null;
      final response = await dio.get('/users/$id');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> paymentsJson = data['paymentMethods'] ?? [];
        final payments = paymentsJson.map((p) => PaymentMethod.fromJson(p)).toList();

        return User(
          id: data['id']?.toString() ?? id,
          email: data['email'] ?? '',
          name: (data['fullName'] ?? data['name'])?.toString(),
          phone: data['phone']?.toString(),
          photoUrl: data['photo']?.toString(),
          paymentMethods: payments,
        );
      }
      return null;
    } catch (e) {
      print('ERROR GET USER: $e');
      return null;
    }
  }

@override
Future<bool> register({
required String name,
required String email,
required String phone,
required String password,
String? photo,
}) async {
try {

String photoUrl = '';
if (photo != null && photo.isNotEmpty) {
  final uploadedUrl = await imgBBService.uploadImage(photo);
  if (uploadedUrl != null) {
    photoUrl = uploadedUrl;
  } else {
  }
}


final response = await dio.post('/users/register', data: {
'email': email,
'password': password,
'fullName': name,
'phone': phone,
'role': 'Remodeler',
'photo': photoUrl,
});


return response.statusCode == 200 || response.statusCode == 201;
} catch (e) {
print('ERROR REGISTER: $e');
return false;
}
}

@override
Future<bool> addPaymentMethod(String userId, Map<String, dynamic> paymentData) async {
  try {
    final response = await dio.post('/users/$userId/payment-methods', data: paymentData);
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print('ERROR ADD PAYMENT METHOD: $e');
    return false;
  }
}
}