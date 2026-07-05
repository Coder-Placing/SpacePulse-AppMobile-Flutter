import '../models/iot_device.dart';
import '../models/telemetry_record.dart';

abstract class IotRepository {
  // 1. Obtener la lista de sensores instalados en un espacio específico
  Future<List<IotDevice>> getDevicesBySpace(int spaceId);

  // 2. Registrar/Vincular un nuevo sensor en la obra (Permiso de Remodelador)
  Future<IotDevice> registerDevice({
    required int spaceId,
    required String name,
    required String type,
  });

  // 3. Eliminar un sensor si se malogró o se terminó la obra
  Future<void> deleteDevice(int deviceId);

  // 4. Leer los datos/métricas del sensor para ver las fluctuaciones (Temperatura, Humedad, etc.)
  Future<List<TelemetryRecord>> getDeviceTelemetry(int deviceId);
}