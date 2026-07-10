import 'package:dio/dio.dart';
import '../../domain/models/iot_device.dart';
import '../../domain/models/telemetry_record.dart';
import '../../domain/repositories/iot_repository.dart';

class IotRepositoryImpl implements IotRepository {
  final Dio dio;

  IotRepositoryImpl({required this.dio});

  @override
  Future<List<IotDevice>> getDevicesBySpace(int spaceId) async {
    try {
      final response = await dio.get('/v1/monitoring/io-t-devices/space/$spaceId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => IotDevice.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener los dispositivos del espacio');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception('Error de red: ${e.message}');
    }
  }

  @override
  Future<IotDevice> registerDevice({
    required int spaceId,
    required String name,
    required String type,
    required String serialNumber,
  }) async {
    try {
      final response = await dio.post('/v1/monitoring/io-t-devices', data: {
        'spaceId': spaceId,
        'name': name,
        'type': type,
        'serialNumber': serialNumber,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return IotDevice.fromJson(response.data);
      } else {
        throw Exception('Error del servidor: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error ${e.response?.statusCode}: ${e.response?.data}');
      }
      throw Exception('Error de red: ${e.message}');
    }
  }

  @override
  Future<void> updateDevice({
    required int deviceId,
    required String name,
    required String serialNumber,
  }) async {
    try {
      final response = await dio.put('/v1/monitoring/io-t-devices/$deviceId', data: {
        'name': name,
        'serialNumber': serialNumber,
      });

      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
        throw Exception('Error al actualizar el dispositivo');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error ${e.response?.statusCode}: ${e.response?.data}');
      }
      throw Exception('Error de red: ${e.message}');
    }
  }

  @override
  Future<void> deleteDevice(int deviceId) async {
    try {
      final response = await dio.delete('/v1/monitoring/io-t-devices/$deviceId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar el dispositivo');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  @override
  Future<void> toggleDevicePower(int deviceId) async {
    try {
      final response = await dio.put('/v1/monitoring/io-t-devices/$deviceId/toggle');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al cambiar el estado del dispositivo');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  @override
  Future<List<TelemetryRecord>> getDeviceTelemetry(int deviceId) async {
    try {
      final response = await dio.get('/v1/monitoring/readings/device/$deviceId');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final List<dynamic> data = response.data;
          return data.map((json) => TelemetryRecord.fromJson(json)).toList();
        }
        else if (response.data is Map) {
          final Map<String, dynamic> mapData = response.data;

          if (mapData.containsKey('data') || mapData.containsKey('items')) {
            final List<dynamic> data = mapData['data'] ?? mapData['items'] ?? [];
            return data.map((json) => TelemetryRecord.fromJson(json)).toList();
          }
          else if (mapData.containsKey('value') && mapData.containsKey('timestamp')) {
            return [TelemetryRecord.fromJson(mapData)];
          }
        }
        return [];
      } else {
        throw Exception('Error al obtener las lecturas');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception('Error de red: ${e.message}');
    }

  }
}