import 'package:dio/dio.dart';
import '../../domain/models/task_model.dart';
import '../../domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final Dio dio;

  TaskRepositoryImpl({required this.dio});

  @override
  Future<List<TaskModel>> getTasksBySpace(int spaceId) async {
    try {
      final response = await dio.get('/v1/monitoring/tasks/space/$spaceId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TaskModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  @override
  Future<void> createTask(Map<String, dynamic> taskData) async {
    try {
      final response = await dio.post('/v1/monitoring/tasks/plan', data: taskData);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating task: $e');
    }
  }

  @override
  Future<void> updateTaskContent(int taskId, Map<String, dynamic> contentData) async {
    try {
      final response = await dio.put('/v1/monitoring/tasks/$taskId/content', data: contentData);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update task content: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating task content: $e');
    }
  }

  @override
  Future<void> updateTaskProgress(int taskId, Map<String, dynamic> progressData) async {
    try {
      final response = await dio.put('/v1/monitoring/tasks/$taskId/progress', data: progressData);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

  @override
  Future<void> deleteTask(int taskId) async {
    try {
      final response = await dio.delete('/v1/monitoring/tasks/$taskId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }
}
