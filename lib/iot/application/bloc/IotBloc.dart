import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/iot_repository.dart';
import 'IotEvent.dart';
import 'IotState.dart';

class IotBloc extends Bloc<IotEvent, IotState> {
  final IotRepository iotRepository;

  IotBloc({required this.iotRepository}) : super(IotInitial()) {

    // 1. Cargar dispositivos
    on<LoadDevicesEvent>((event, emit) async {
      emit(IotLoading());
      try {
        final devices = await iotRepository.getDevicesBySpace(event.spaceId);
        emit(IotDevicesLoaded(devices));
      } catch (e) {
        emit(IotError(e.toString()));
      }
    });

    // 2. Agregar dispositivo
    on<AddDeviceEvent>((event, emit) async {
      emit(IotLoading());
      try {
        await iotRepository.registerDevice(
          spaceId: event.spaceId,
          name: event.name,
          type: event.type,
        );
        // Despues de crear, volvemos a cargar la lista para que aparezca el nuevo
        final devices = await iotRepository.getDevicesBySpace(event.spaceId);
        emit(IotDevicesLoaded(devices));
      } catch (e) {
        emit(IotError(e.toString()));
      }
    });

    // 3. Eliminar dispositivo
    on<DeleteDeviceEvent>((event, emit) async {
      emit(IotLoading());
      try {
        await iotRepository.deleteDevice(event.deviceId);
        // Volvemos a cargar la lista actualizada
        final devices = await iotRepository.getDevicesBySpace(event.spaceId);
        emit(IotDevicesLoaded(devices));
      } catch (e) {
        emit(IotError(e.toString()));
      }
    });

    // 4. Ver datos en vivo (Telemetría)
    on<LoadTelemetryEvent>((event, emit) async {
      emit(IotLoading());
      try {
        final records = await iotRepository.getDeviceTelemetry(event.deviceId);
        emit(IotTelemetryLoaded(records));
      } catch (e) {
        emit(IotError(e.toString()));
      }
    });
  }
}