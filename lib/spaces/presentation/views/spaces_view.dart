import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tfmoviles2/service_locator.dart';
import 'package:tfmoviles2/shared/presentation/design/app_colors.dart';
import 'package:tfmoviles2/spaces/application/bloc/SpaceBloc.dart';
import 'package:tfmoviles2/spaces/domain/models/space.dart';
import 'package:tfmoviles2/spaces/domain/repositories/space_repository.dart';
import 'package:tfmoviles2/tasks/presentation/views/tasks_view.dart';

class SpacesView extends StatelessWidget {
  const SpacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SpaceBloc(
        spaceRepository: getIt<SpaceRepository>(),
      )..add(FetchSpacesEvent()),
      child: const SpacesContentView(),
    );
  }
}

class SpacesContentView extends StatefulWidget {
  const SpacesContentView({super.key});

  @override
  State<SpacesContentView> createState() => _SpacesContentViewState();
}

class _SpacesContentViewState extends State<SpacesContentView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Espacios'),
          backgroundColor: AppColors.background,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: AppColors.primaryButton,
            labelColor: AppColors.primaryButton,
            unselectedLabelColor: AppColors.secondaryText,
            onTap: (index) {
              if (index == 0) {
                context.read<SpaceBloc>().add(FetchSpacesEvent());
              } else {
                context.read<SpaceBloc>().add(FetchMySpacesEvent());
              }
            },
            tabs: const [
              Tab(text: 'Disponibles'),
              Tab(text: 'Mis Espacios'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final tabController = DefaultTabController.of(context);
                if (tabController.index == 0) {
                  context.read<SpaceBloc>().add(FetchSpacesEvent());
                } else {
                  context.read<SpaceBloc>().add(FetchMySpacesEvent());
                }
              },
            ),
          ],
        ),
        body: BlocConsumer<SpaceBloc, SpaceState>(
        listener: (context, state) {
          if (state is SpaceActionSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is SpaceErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is SpaceLoadingState || state is SpaceActionLoadingState) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.white),
            );
          } else if (state is SpaceErrorState) {
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                      ),
                      onPressed: () {
                        context.read<SpaceBloc>().add(FetchSpacesEvent());
                      },
                      child: const Text('Reintentar', style: TextStyle(color: AppColors.white)),
                    )
                  ],
                ),
              ),
            );
          } else if (state is SpaceLoadedState) {
            final spaces = state.spaces;

            if (spaces.isEmpty) {
              return const Center(
                child: Text('No hay espacios disponibles.', style: TextStyle(color: AppColors.white)),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<SpaceBloc>().add(FetchSpacesEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: spaces.length,
                itemBuilder: (context, index) {
                  final space = spaces[index];
                  return SpaceCard(
                    space: space,
                    onViewDetails: () {
                      _showSpaceDetailsModal(context, space, state.isMySpaces);
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      ),
    );
  }

  void _showSpaceDetailsModal(BuildContext context, Space space, bool isMySpaces) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (space.images.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        space.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.cardBackground,
                          child: const Icon(Icons.broken_image, color: AppColors.secondaryText, size: 50),
                        ),
                      ),
                    ),
                  ),
                Text(
                  space.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.secondaryText, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    space.location,
                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Descripción', style: TextStyle(color: AppColors.secondaryText)),
              const SizedBox(height: 4),
              Text(space.description, style: const TextStyle(color: AppColors.white, fontSize: 16)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Presupuesto', style: TextStyle(color: AppColors.secondaryText)),
                      Text('${space.currency} ${space.estimatedBudget.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Precio Final', style: TextStyle(color: AppColors.secondaryText)),
                      Text('${space.currency} ${space.endingPricing.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Área', style: TextStyle(color: AppColors.secondaryText)),
                      Text('${space.dimensionsSquareMeters} m²',
                          style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (!isMySpaces)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Rechazar', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          context.read<SpaceBloc>().add(AcceptSpaceEvent(spaceId: space.id));
                          Navigator.pop(context);
                        },
                        child: const Text('Aceptar', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => TasksView(space: space)));
                        },
                        child: const Text('Ver Tareas', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (space.status.toUpperCase() == 'COMPLETED' || space.status.toUpperCase() == 'FINISHED')
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[800],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('¡Cobro realizado con éxito! El pago ha sido procesado.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: const Text('Cobrar', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 32),
            ],
          ),
          )
        );
      },
    );
  }
}

class SpaceCard extends StatelessWidget {
  final Space space;
  final VoidCallback onViewDetails;

  const SpaceCard({
    super.key,
    required this.space,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (space.images.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                space.images.first,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.black,
                  child: const Icon(Icons.image_not_supported, color: AppColors.secondaryText, size: 50),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        space.title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(space.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getStatusColor(space.status)),
                      ),
                      child: Text(
                        space.status,
                        style: TextStyle(color: _getStatusColor(space.status), fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.secondaryText, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      space.location,
                      style: const TextStyle(color: AppColors.secondaryText),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  space.description,
                  style: const TextStyle(color: AppColors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Presupuesto', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                        Text(
                          '${space.currency} ${space.estimatedBudget.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Precio Final', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                        Text(
                          '${space.currency} ${space.endingPricing.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Área', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                        Text(
                          '${space.dimensionsSquareMeters} m²',
                          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onViewDetails,
                    child: const Text('Ver Detalles', style: TextStyle(color: AppColors.white)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PUBLISHED':
        return Colors.green;
      case 'COMPLETED':
      case 'FINISHED':
        return Colors.blue;
      case 'CANCELED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
