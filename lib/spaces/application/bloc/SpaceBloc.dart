import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/models/space.dart';
import '../../domain/repositories/space_repository.dart';

part 'SpaceEvent.dart';
part 'SpaceState.dart';

class SpaceBloc extends Bloc<SpaceEvent, SpaceState> {
  final SpaceRepository spaceRepository;

  SpaceBloc({required this.spaceRepository}) : super(SpaceInitialState()) {
    on<FetchSpacesEvent>(_onFetchSpaces);
    on<FetchMySpacesEvent>(_onFetchMySpaces);
    on<AcceptSpaceEvent>(_onAcceptSpace);
  }

  FutureOr<void> _onFetchSpaces(FetchSpacesEvent event, Emitter<SpaceState> emit) async {
    emit(SpaceLoadingState());
    try {
      final List<Space> spaces = await spaceRepository.getSpaces();
      emit(SpaceLoadedState(spaces: spaces));
    } catch (e) {
      emit(SpaceErrorState(message: e.toString()));
    }
  }

  FutureOr<void> _onFetchMySpaces(FetchMySpacesEvent event, Emitter<SpaceState> emit) async {
    emit(SpaceLoadingState());
    try {
      final List<Space> spaces = await spaceRepository.getMySpaces();
      emit(SpaceLoadedState(spaces: spaces, isMySpaces: true));
    } catch (e) {
      emit(SpaceErrorState(message: e.toString()));
    }
  }

  FutureOr<void> _onAcceptSpace(AcceptSpaceEvent event, Emitter<SpaceState> emit) async {
    emit(SpaceActionLoadingState());
    try {
      await spaceRepository.acceptSpace(event.spaceId);
      emit(SpaceActionSuccessState(message: 'Espacio aceptado con éxito'));
      // Reload spaces
      add(FetchSpacesEvent());
    } catch (e) {
      emit(SpaceErrorState(message: e.toString()));
      // Fallback reload spaces to remove error screen
      add(FetchSpacesEvent());
    }
  }
}
