import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/iot_repository.dart';
import 'IotEvent.dart';
import 'IotState.dart';

class IotBloc extends Bloc<IotEvent, IotState> {
  final IotRepository iotRepository;

  IotBloc({required this.iotRepository}) : super(IotInitial()) {
    on<LoadDevicesEvent>((event, emit) async {
      emit(IotLoading());
      try {
        final devices = await iotRepository.getDevicesBySpace(event.spaceId);
        emit(IotDevicesLoaded(devices));
      } catch (e) {
        emit(IotError(e.toString()));
      }
    });

    on<AddDeviceEvent>((event, emit) async {
      emit(IotLoading());
      try {
        await iotRepository.registerDevice(
          spaceId: event.spaceId,
          name: event.name,
          type: event.type,
          serialNumber: event.serialNumber,
        );
        final devices = await iotRepository.getDevicesBySpace(event.spaceId);
        emit(IotDevicesLoaded(devices));
      } catch (e) {
        emit(IotError(e.toString()));
      }
    });

    on<UpdateDeviceEvent>((event, emit) async {
      emit(IotLoading());
      try {
        await iotRepository.updateDevice(
          deviceId: event.deviceId,
          name: event.name,
          serialNumber: event.serialNumber,
        );
        
        if (event.spaceId != null) {
          add(LoadDevicesEvent(event.spaceId!));
        } else {
          add(LoadTelemetryEvent(event.deviceId));
        }
      } catch (e) {
        emit(IotError(e.toString()));
      }
    });

    on<DeleteDeviceEvent>((event, emit) async {
      emit(IotLoading());
      try {
        await iotRepository.deleteDevice(event.deviceId);
        final devices = await iotRepository.getDevicesBySpace(event.spaceId);
        emit(IotDevicesLoaded(devices));
      } catch (e) {
        emit(IotError(e.toString()));
      }
    });

    on<LoadTelemetryEvent>((event, emit) async {
      emit(IotLoading());
      try {
        final records = await iotRepository.getDeviceTelemetry(event.deviceId);
        emit(IotTelemetryLoaded(records));
      } catch (e) {
        emit(IotError(e.toString()));
      }
    });

    on<ToggleDevicePowerEvent>((event, emit) async {
      try {
        await iotRepository.toggleDevicePower(event.deviceId);
        add(LoadTelemetryEvent(event.deviceId));
      } catch (e) {
        emit(IotError(e.toString()));
      }
    });
  }
}