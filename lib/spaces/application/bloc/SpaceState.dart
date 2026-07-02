part of 'SpaceBloc.dart';

abstract class SpaceState {}

class SpaceInitialState extends SpaceState {}

class SpaceLoadingState extends SpaceState {}

class SpaceLoadedState extends SpaceState {
  final List<Space> spaces;

  SpaceLoadedState({required this.spaces});
}

class SpaceErrorState extends SpaceState {
  final String message;

  SpaceErrorState({required this.message});
}

class SpaceActionLoadingState extends SpaceState {}

class SpaceActionSuccessState extends SpaceState {
  final String message;

  SpaceActionSuccessState({required this.message});
}
