part of 'SpaceBloc.dart';

abstract class SpaceEvent {}

class FetchSpacesEvent extends SpaceEvent {}

class FetchMySpacesEvent extends SpaceEvent {}

class AcceptSpaceEvent extends SpaceEvent {
  final int spaceId;

  AcceptSpaceEvent({required this.spaceId});
}
