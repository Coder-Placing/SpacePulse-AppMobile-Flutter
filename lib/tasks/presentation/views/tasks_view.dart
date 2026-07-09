import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tfmoviles2/service_locator.dart';
import 'package:tfmoviles2/shared/presentation/design/app_colors.dart';
import 'package:tfmoviles2/spaces/domain/models/space.dart';
import 'package:tfmoviles2/tasks/application/bloc/task_bloc.dart';
import 'package:tfmoviles2/tasks/domain/models/task_model.dart';
import 'package:tfmoviles2/tasks/domain/repositories/task_repository.dart';

class TasksView extends StatelessWidget {
  final Space space;

  const TasksView({super.key, required this.space});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskBloc(
        taskRepository: getIt<TaskRepository>(),
      )..add(FetchTasksEvent(spaceId: space.id)),
      child: TasksContentView(space: space),
    );
  }
}

class TasksContentView extends StatefulWidget {
  final Space space;

  const TasksContentView({super.key, required this.space});

  @override
  State<TasksContentView> createState() => _TasksContentViewState();
}

class _TasksContentViewState extends State<TasksContentView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tareas: ${widget.space.title}'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TaskBloc>().add(FetchTasksEvent(spaceId: widget.space.id));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryButton,
        child: const Icon(Icons.add, color: AppColors.white),
        onPressed: () => _showCreateTaskModal(context),
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskActionSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is TaskErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoadingState || state is TaskActionLoadingState) {
            return const Center(child: CircularProgressIndicator(color: AppColors.white));
          } else if (state is TaskErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: AppColors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryButton),
                      onPressed: () {
                        context.read<TaskBloc>().add(FetchTasksEvent(spaceId: widget.space.id));
                      },
                      child: const Text('Reintentar', style: TextStyle(color: AppColors.white)),
                    )
                  ],
                ),
              ),
            );
          } else if (state is TaskLoadedState) {
            final tasks = state.tasks;
            if (tasks.isEmpty) {
              return const Center(
                child: Text('No hay tareas para este espacio.', style: TextStyle(color: AppColors.white)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskCard(context, task);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(task.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getStatusColor(task.status)),
                      ),
                      child: Text(
                        task.status,
                        style: TextStyle(color: _getStatusColor(task.status), fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.secondaryText, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showUpdateProgressTaskModal(context, task),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.description, style: const TextStyle(color: AppColors.secondaryText)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Precio', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                    Text('\$${task.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      context.read<TaskBloc>().add(DeleteTaskEvent(spaceId: widget.space.id, taskId: task.id));
                    },
                    child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      final progressData = {
                        "status": "COMPLETED",
                        "plannedStartDate": task.plannedStartDate?.toUtc().toIso8601String() ?? DateTime.now().toUtc().toIso8601String(),
                        "plannedEndDate": task.plannedEndDate?.toUtc().toIso8601String() ?? DateTime.now().toUtc().toIso8601String(),
                        "price": task.price,
                      };
                      context.read<TaskBloc>().add(UpdateTaskProgressEvent(
                        spaceId: widget.space.id,
                        taskId: task.id,
                        progressData: progressData,
                      ));
                    },
                    child: const Text('Completada', style: TextStyle(color: AppColors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED': return Colors.blue;
      case 'IN_PROGRESS': return Colors.orange;
      case 'PENDING': return Colors.grey;
      default: return Colors.white;
    }
  }

  void _showCreateTaskModal(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (stateContext, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Crear Tarea', style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
                        labelText: 'Título',
                        labelStyle: const TextStyle(color: AppColors.secondaryText),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.5))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryButton)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: const TextStyle(color: AppColors.secondaryText),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.5))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryButton)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        labelStyle: const TextStyle(color: AppColors.secondaryText),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.5))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryButton)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardBackground),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: stateContext,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                setStateModal(() => startDate = date);
                              }
                            },
                            child: Text(startDate == null ? 'Fecha Inicio' : startDate!.toString().split(' ')[0], style: const TextStyle(color: AppColors.white)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardBackground),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: stateContext,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: startDate ?? DateTime.now(),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                setStateModal(() => endDate = date);
                              }
                            },
                            child: Text(endDate == null ? 'Fecha Fin' : endDate!.toString().split(' ')[0], style: const TextStyle(color: AppColors.white)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (titleController.text.isNotEmpty && startDate != null && endDate != null) {
                            final taskData = {
                              "spaceId": widget.space.id,
                              "title": titleController.text,
                              "description": descController.text,
                              "photoUrl": "string",
                              "status": "PENDING",
                              "plannedStartDate": startDate!.toUtc().toIso8601String(),
                              "plannedEndDate": endDate!.toUtc().toIso8601String(),
                              "price": double.tryParse(priceController.text) ?? 0,
                            };
                            context.read<TaskBloc>().add(CreateTaskEvent(spaceId: widget.space.id, taskData: taskData));
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(stateContext).showSnackBar(const SnackBar(content: Text('Complete los campos requeridos')));
                          }
                        },
                        child: const Text('Crear', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUpdateProgressTaskModal(BuildContext context, TaskModel task) {
    final priceController = TextEditingController(text: task.price.toString());
    DateTime? startDate = task.plannedStartDate;
    DateTime? endDate = task.plannedEndDate;
    String status = task.status;
    final List<String> statuses = ['PENDING', 'IN_PROGRESS', 'COMPLETED'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (stateContext, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Editar Plan de Tarea', style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: statuses.contains(status) ? status : 'PENDING',
                      dropdownColor: AppColors.cardBackground,
                      style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        labelStyle: const TextStyle(color: AppColors.secondaryText),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.5))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryButton)),
                      ),
                      items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setStateModal(() => status = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        labelStyle: const TextStyle(color: AppColors.secondaryText),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.5))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryButton)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardBackground),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: stateContext,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) setStateModal(() => startDate = date);
                            },
                            child: Text(startDate == null ? 'Fecha Inicio' : startDate!.toString().split(' ')[0], style: const TextStyle(color: AppColors.white)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardBackground),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: stateContext,
                                initialDate: endDate ?? startDate ?? DateTime.now(),
                                firstDate: startDate ?? DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) setStateModal(() => endDate = date);
                            },
                            child: Text(endDate == null ? 'Fecha Fin' : endDate!.toString().split(' ')[0], style: const TextStyle(color: AppColors.white)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (startDate != null && endDate != null) {
                            final progressData = {
                              "status": status,
                              "plannedStartDate": startDate!.toUtc().toIso8601String(),
                              "plannedEndDate": endDate!.toUtc().toIso8601String(),
                              "price": double.tryParse(priceController.text) ?? 0,
                            };
                            context.read<TaskBloc>().add(UpdateTaskProgressEvent(
                              spaceId: widget.space.id,
                              taskId: task.id,
                              progressData: progressData,
                            ));
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(stateContext).showSnackBar(const SnackBar(content: Text('Fechas requeridas')));
                          }
                        },
                        child: const Text('Actualizar Plan', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
