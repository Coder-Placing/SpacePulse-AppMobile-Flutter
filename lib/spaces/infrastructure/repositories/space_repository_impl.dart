import 'package:dio/dio.dart';
import '../../domain/models/space.dart';
import '../../domain/repositories/space_repository.dart';

class SpaceRepositoryImpl implements SpaceRepository {
  final Dio dio;

  SpaceRepositoryImpl({required this.dio});

  @override
  Future<List<Space>> getSpaces() async {
    try {
      final response = await dio.get('/v1/space');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Space.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load spaces: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching spaces: $e');
    }
  }

  @override
  Future<List<Space>> getMySpaces() async {
    try {
      final response = await dio.get('/v1/space/my-spaces');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Space.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load my spaces: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching my spaces: $e');
    }
  }

  @override
  Future<void> acceptSpace(int spaceId) async {
    try {
      final response = await dio.post('/v1/space/$spaceId/accept');
      if (response.statusCode != 200 && response.statusCode != 204 && response.statusCode != 201) {
        throw Exception('Failed to accept space: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error accepting space: $e');
    }
  }
}
