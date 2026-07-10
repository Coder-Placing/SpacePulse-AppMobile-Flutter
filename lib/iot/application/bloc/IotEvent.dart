abstract class IotEvent {}

class LoadDevicesEvent extends IotEvent {
  final int spaceId;
  LoadDevicesEvent(this.spaceId);
}

class AddDeviceEvent extends IotEvent {
  final int spaceId;
  final String name;
  final String type;
  final String serialNumber;

  AddDeviceEvent({
    required this.spaceId,
    required this.name,
    required this.type,
    required this.serialNumber,
  });
}

class UpdateDeviceEvent extends IotEvent {
  final int deviceId;
  final String name;
  final String serialNumber;
  final int? spaceId;

  UpdateDeviceEvent({
    required this.deviceId,
    required this.name,
    required this.serialNumber,
    this.spaceId,
  });
}

class DeleteDeviceEvent extends IotEvent {
  final int deviceId;
  final int spaceId;

  DeleteDeviceEvent({
    required this.deviceId,
    required this.spaceId,
  });
}

class LoadTelemetryEvent extends IotEvent {
  final int deviceId;
  LoadTelemetryEvent(this.deviceId);
}

class ToggleDevicePowerEvent extends IotEvent {
  final int deviceId;
  ToggleDevicePowerEvent(this.deviceId);
}