import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/models/task_model.dart';
import '../../domain/repositories/task_repository.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;

  TaskBloc({required this.taskRepository}) : super(TaskInitialState()) {
    on<FetchTasksEvent>(_onFetchTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskProgressEvent>(_onUpdateTaskProgress);
    on<UpdateTaskContentEvent>(_onUpdateTaskContent);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  FutureOr<void> _onFetchTasks(FetchTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoadingState());
    try {
      final List<TaskModel> tasks = await taskRepository.getTasksBySpace(event.spaceId);
      emit(TaskLoadedState(tasks: tasks));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
    }
  }

  FutureOr<void> _onCreateTask(CreateTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskActionLoadingState());
    try {
      await taskRepository.createTask(event.taskData);
      emit(TaskActionSuccessState(message: 'Tarea creada con éxito'));
      add(FetchTasksEvent(spaceId: event.spaceId));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
      add(FetchTasksEvent(spaceId: event.spaceId));
    }
  }

  FutureOr<void> _onUpdateTaskProgress(UpdateTaskProgressEvent event, Emitter<TaskState> emit) async {
    emit(TaskActionLoadingState());
    try {
      await taskRepository.updateTaskProgress(event.taskId, event.progressData);
      emit(TaskActionSuccessState(message: 'Progreso de la tarea actualizado con éxito'));
      add(FetchTasksEvent(spaceId: event.spaceId));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
      add(FetchTasksEvent(spaceId: event.spaceId));
    }
  }

  FutureOr<void> _onUpdateTaskContent(UpdateTaskContentEvent event, Emitter<TaskState> emit) async {
    emit(TaskActionLoadingState());
    try {
      await taskRepository.updateTaskContent(event.taskId, event.contentData);
      emit(TaskActionSuccessState(message: 'Contenido de la tarea actualizado con éxito'));
      add(FetchTasksEvent(spaceId: event.spaceId));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
      add(FetchTasksEvent(spaceId: event.spaceId));
    }
  }

  FutureOr<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskActionLoadingState());
    try {
      await taskRepository.deleteTask(event.taskId);
      emit(TaskActionSuccessState(message: 'Tarea eliminada/rechazada con éxito'));
      add(FetchTasksEvent(spaceId: event.spaceId));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
      add(FetchTasksEvent(spaceId: event.spaceId));
    }
  }
}
