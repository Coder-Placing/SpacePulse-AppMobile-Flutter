import '../../domain/models/iot_device.dart';
import '../../domain/models/telemetry_record.dart';

abstract class IotState {}

class IotInitial extends IotState {}

class IotLoading extends IotState {}

class IotDevicesLoaded extends IotState {
  final List<IotDevice> devices;
  IotDevicesLoaded(this.devices);
}

class IotTelemetryLoaded extends IotState {
  final List<TelemetryRecord> records;
  IotTelemetryLoaded(this.records);
}

class IotError extends IotState {
  final String message;
  IotError(this.message);
}