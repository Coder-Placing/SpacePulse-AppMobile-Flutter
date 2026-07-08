import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tfmoviles2/service_locator.dart';
import 'package:tfmoviles2/shared/presentation/design/app_colors.dart';
import 'package:tfmoviles2/spaces/application/bloc/SpaceBloc.dart';
import 'package:tfmoviles2/spaces/domain/models/space.dart';
import 'package:tfmoviles2/spaces/domain/repositories/space_repository.dart';

class SpacesView extends StatelessWidget {
  const SpacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SpaceBloc(
        spaceRepository: getIt<SpaceRepository>(),
      )..add(FetchSpacesEvent()), // Default fetching spaces for remodeler
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Espacios Disponibles'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SpaceBloc>().add(FetchSpacesEvent());
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
                      _showSpaceDetailsModal(context, space);
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showSpaceDetailsModal(BuildContext context, Space space) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Área', style: TextStyle(color: AppColors.secondaryText)),
                      Text('${space.dimensionsSquareMeters} m²',
                          style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
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
              ),
              const SizedBox(height: 32),
            ],
          ),
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
                    const Text('Tipo', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                    Text(
                      space.spaceType,
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PUBLISHED':
        return Colors.green;
      case 'COMPLETED':
        return Colors.blue;
      case 'CANCELED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
