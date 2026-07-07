import '../models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getTasksBySpace(int spaceId);
  Future<void> createTask(Map<String, dynamic> taskData);
  Future<void> updateTaskContent(int taskId, Map<String, dynamic> contentData);
  Future<void> updateTaskProgress(int taskId, Map<String, dynamic> progressData);
  Future<void> deleteTask(int taskId);
}
