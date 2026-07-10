import 'package:flutter/material.dart';
import 'package:tfmoviles2/shared/presentation/design/app_colors.dart';
import 'package:tfmoviles2/service_locator.dart';
import 'package:tfmoviles2/spaces/domain/repositories/space_repository.dart';
import 'package:tfmoviles2/spaces/domain/models/space.dart';
import 'package:tfmoviles2/tasks/domain/repositories/task_repository.dart';
import 'package:tfmoviles2/tasks/domain/models/task_model.dart';
import 'package:tfmoviles2/shared/domain/services/storage_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isLoading = true;
  List<Space> _mySpaces = [];
  List<TaskModel> _allTasks = [];
  String _errorMessage = '';
  String _userName = 'Remodelador';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final spaceRepo = getIt<SpaceRepository>();
      final taskRepo = getIt<TaskRepository>();

      final spaces = await spaceRepo.getMySpaces();
      List<TaskModel> allTasks = [];

      for (var space in spaces) {
        try {
          final tasks = await taskRepo.getTasksBySpace(space.id);
          allTasks.addAll(tasks);
        } catch (e) {
          print('Error obteniendo tareas para el espacio ${space.id}: $e');
        }
      }
      
      final userData = await getIt<StorageService>().getUserData();

      setState(() {
        _mySpaces = spaces;
        _allTasks = allTasks;
        _userName = userData['name'] ?? 'Remodelador';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el resumen: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryButton))
            : _errorMessage.isNotEmpty
                ? _buildErrorState()
                : _buildDashboard(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
          const SizedBox(height: 16),
          Text(_errorMessage, style: const TextStyle(color: AppColors.white), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchDashboardData,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryButton),
            child: const Text('Reintentar', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final int activeProjects = _mySpaces.length;
    final int totalTasks = _allTasks.length;
    
    final nextTasks = _allTasks.where((t) => t.status != 'COMPLETED').toList();
    
    final recentSpace = _mySpaces.isNotEmpty ? _mySpaces.first : null;
    int spaceTasksInProgress = 0;
    int spaceTasksPending = 0;
    
    if (recentSpace != null) {
      spaceTasksInProgress = _allTasks.where((t) => t.spaceId == recentSpace.id && t.status == 'IN_PROGRESS').length;
      spaceTasksPending = _allTasks.where((t) => t.spaceId == recentSpace.id && t.status == 'PENDING').length;
    }

    return RefreshIndicator(
      onRefresh: _fetchDashboardData,
      color: AppColors.primaryButton,
      backgroundColor: AppColors.cardBackground,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${_userName.split(' ').first}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gestiona tus proyectos',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            const Text(
              'Resumen de hoy',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSummaryCard(activeProjects.toString(), 'Proyecto activo')),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard(totalTasks.toString(), 'Tareas asignadas')),
              ],
            ),
            const SizedBox(height: 32),

            const Text(
              'Proyectos asignados',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (recentSpace != null)
              _buildProjectCard(
                title: recentSpace.title,
                status: 'aceptado',
                progressText: '$spaceTasksInProgress en proceso - $spaceTasksPending pendiente',
              )
            else
              const Text('No tienes proyectos asignados', style: TextStyle(color: AppColors.secondaryText)),

            const SizedBox(height: 32),

            const Text(
              'Tareas próximas',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (nextTasks.isNotEmpty)
              _buildTaskCard(
                title: nextTasks.first.title,
                status: nextTasks.first.status == 'IN_PROGRESS' ? 'En proceso' : 'Pendiente',
              )
            else
              const Text('No hay tareas próximas', style: TextStyle(color: AppColors.secondaryText)),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardBackground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _fetchDashboardData();
                },
                child: const Text(
                  'Actualizar avance',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String count, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryText.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard({required String title, required String status, required String progressText}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryText.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Estado: $status',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            progressText,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard({required String title, required String status}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
