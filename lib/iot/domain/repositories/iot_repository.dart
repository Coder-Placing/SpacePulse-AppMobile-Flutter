import '../models/iot_device.dart';
import '../models/telemetry_record.dart';

abstract class IotRepository {
  Future<List<IotDevice>> getDevicesBySpace(int spaceId);

  Future<IotDevice> registerDevice({
    required int spaceId,
    required String name,
    required String type,
    required String serialNumber,
  });

  Future<void> updateDevice({
    required int deviceId,
    required String name,
    required String serialNumber,
  });

  Future<void> deleteDevice(int deviceId);

  Future<void> toggleDevicePower(int deviceId);

  Future<List<TelemetryRecord>> getDeviceTelemetry(int deviceId);
}