part of 'task_bloc.dart';

abstract class TaskState {}

class TaskInitialState extends TaskState {}

class TaskLoadingState extends TaskState {}

class TaskLoadedState extends TaskState {
  final List<TaskModel> tasks;

  TaskLoadedState({required this.tasks});
}

class TaskErrorState extends TaskState {
  final String message;

  TaskErrorState({required this.message});
}

class TaskActionLoadingState extends TaskState {}

class TaskActionSuccessState extends TaskState {
  final String message;

  TaskActionSuccessState({required this.message});
}
