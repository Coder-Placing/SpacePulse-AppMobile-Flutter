import '../models/space.dart';

abstract class SpaceRepository {
  Future<List<Space>> getSpaces();
  Future<List<Space>> getMySpaces();
  Future<void> acceptSpace(int spaceId);
}
