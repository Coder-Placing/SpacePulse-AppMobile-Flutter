import 'package:dio/dio.dart';
import '../../domain/models/iot_device.dart';
import '../../domain/models/telemetry_record.dart'; // Aunque tu backend le diga Readings, internamente lo llamamos TelemetryRecord
import '../../domain/repositories/iot_repository.dart';

class IotRepositoryImpl implements IotRepository {
  final Dio dio;

  IotRepositoryImpl({required this.dio});

  @override
  Future<List<IotDevice>> getDevicesBySpace(int spaceId) async {
    try {
      // Ruta corregida según Swagger: /api/v1/monitoring/io-t-devices/space/{spaceId}
      final response = await dio.get('/v1/monitoring/io-t-devices/space/$spaceId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => IotDevice.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener los dispositivos del espacio');
      }
    } on DioException catch (e) {
      // Si el backend devuelve 404 porque la lista está vacía, no lanzamos error, devolvemos lista vacía
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
  }) async {
    try {
      final response = await dio.post('/v1/monitoring/io-t-devices', data: {
        'spaceId': spaceId,
        'name': name,
        'type': type,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return IotDevice.fromJson(response.data);
      } else {
        // Ahora capturamos el mensaje exacto del servidor
        throw Exception('Error del servidor: ${response.data}');
      }
    } on DioException catch (e) {
      // Si es un error 400 (Bad Request), mostramos qué campo está mal
      if (e.response != null) {
        throw Exception('Error ${e.response?.statusCode}: ${e.response?.data}');
      }
      throw Exception('Error de red: ${e.message}');
    }
  }

  @override
  Future<void> deleteDevice(int deviceId) async {
    try {
      // Ruta corregida según Swagger: DELETE /api/v1/monitoring/io-t-devices/{id}
      final response = await dio.delete('/v1/monitoring/io-t-devices/$deviceId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar el dispositivo');
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

          // Caso 1: El backend devuelve un objeto envuelto en una lista { "data": [ ... ] }
          if (mapData.containsKey('data') || mapData.containsKey('items')) {
            final List<dynamic> data = mapData['data'] ?? mapData['items'] ?? [];
            return data.map((json) => TelemetryRecord.fromJson(json)).toList();
          }
          // Caso 2 (¡TU CASO!): El backend devuelve el objeto suelto directamente
          else if (mapData.containsKey('value') && mapData.containsKey('timestamp')) {
            // Lo envolvemos en una lista para que la interfaz lo pueda dibujar
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