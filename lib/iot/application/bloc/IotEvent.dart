abstract class IotEvent {}

// Al entrar a la vista del espacio
class LoadDevicesEvent extends IotEvent {
  final int spaceId;
  LoadDevicesEvent(this.spaceId);
}

// Al presionar el botón "Agregar Sensor"
class AddDeviceEvent extends IotEvent {
  final int spaceId;
  final String name;
  final String type;

  AddDeviceEvent({
    required this.spaceId,
    required this.name,
    required this.type,
  });
}

// Al presionar el ícono del basurero para quitar un sensor
class DeleteDeviceEvent extends IotEvent {
  final int deviceId;
  final int spaceId; // Lo necesitamos para recargar la lista de ese espacio tras borrar

  DeleteDeviceEvent({
    required this.deviceId,
    required this.spaceId,
  });
}

// Al darle tap a un sensor para ver sus datos en vivo
class LoadTelemetryEvent extends IotEvent {
  final int deviceId;
  LoadTelemetryEvent(this.deviceId);
}