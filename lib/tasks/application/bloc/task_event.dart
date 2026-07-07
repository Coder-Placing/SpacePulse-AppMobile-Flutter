part of 'task_bloc.dart';

abstract class TaskEvent {}

class FetchTasksEvent extends TaskEvent {
  final int spaceId;

  FetchTasksEvent({required this.spaceId});
}

class CreateTaskEvent extends TaskEvent {
  final int spaceId;
  final Map<String, dynamic> taskData;

  CreateTaskEvent({required this.spaceId, required this.taskData});
}

class UpdateTaskProgressEvent extends TaskEvent {
  final int spaceId;
  final int taskId;
  final Map<String, dynamic> progressData;

  UpdateTaskProgressEvent({required this.spaceId, required this.taskId, required this.progressData});
}

class UpdateTaskContentEvent extends TaskEvent {
  final int spaceId;
  final int taskId;
  final Map<String, dynamic> contentData;

  UpdateTaskContentEvent({required this.spaceId, required this.taskId, required this.contentData});
}

class DeleteTaskEvent extends TaskEvent {
  final int spaceId;
  final int taskId;

  DeleteTaskEvent({required this.spaceId, required this.taskId});
}
