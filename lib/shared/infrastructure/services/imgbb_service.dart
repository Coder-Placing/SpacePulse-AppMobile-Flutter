import 'package:dio/dio.dart';
import 'dart:io';

class ImgBBService {
  final Dio _dio = Dio();
  final String _apiKey = 'e50506198b39dafe03e32e9c2a22c069';

  Future<String?> uploadImage(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: 'upload.jpg'),
      });

      final response = await _dio.post(
        'https://api.imgbb.com/1/upload',
        queryParameters: {'key': _apiKey},
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data']['url'];
      }
      return null;
    } catch (e) {
      print('ERROR IMGBB UPLOAD: $e');
      return null;
    }
  }
}
