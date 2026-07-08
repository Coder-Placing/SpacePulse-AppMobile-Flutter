import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/IotBloc.dart';
import '../../application/bloc/IotEvent.dart';
import '../../application/bloc/IotState.dart';
// Asegúrate de que esta ruta apunte correctamente a tu service_locator.dart
import '../../../service_locator.dart';
class IotDeviceDetailView extends StatelessWidget {
  final int deviceId;
  final String deviceName;

  const IotDeviceDetailView({
    Key? key,
    required this.deviceId,
    required this.deviceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Disparamos el evento para pedir los datos (telemetría) de este sensor en específico
      create: (context) => getIt<IotBloc>()..add(LoadTelemetryEvent(deviceId)),
      child: Scaffold(
        backgroundColor: const Color(0xFF121212), // Fondo oscuro
        appBar: AppBar(
          title: Text('Telemetría: $deviceName'),
          backgroundColor: const Color(0xFF2C3E50),
        ),
        body: BlocBuilder<IotBloc, IotState>(
          builder: (context, state) {
            if (state is IotLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is IotError) {
              return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
            } else if (state is IotTelemetryLoaded) {
              final records = state.records;

              if (records.isEmpty) {
                return const Center(child: Text('Aún no hay datos registrados para este sensor.', style: TextStyle(color: Colors.white)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  // Formatear la hora
                  final timeStr = "${record.timestamp.hour}:${record.timestamp.minute.toString().padLeft(2, '0')}";

                  return Card(
                    color: const Color(0xFF1E1E1E),
                    child: ListTile(
                      leading: const Icon(Icons.show_chart, color: Colors.greenAccent),
                      title: Text(
                          'Valor: ${record.value}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                      subtitle: Text(
                          'Actualizado a las: $timeStr',
                          style: const TextStyle(color: Colors.grey)
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class IotMonitoringView extends StatelessWidget {
  final int spaceId; // Necesitamos saber de qué espacio son los sensores

  const IotMonitoringView({Key? key, required this.spaceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Al crear el BLoC, disparamos inmediatamente el evento para cargar los sensores
      create: (context) => getIt<IotBloc>()..add(LoadDevicesEvent(spaceId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Monitoreo IoT'),
          backgroundColor: const Color(0xFF2C3E50), // Tu azul SpacePulse
        ),
        body: BlocBuilder<IotBloc, IotState>(
          builder: (context, state) {
            if (state is IotLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is IotError) {
              return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
            } else if (state is IotDevicesLoaded) {
              final devices = state.devices;

              if (devices.isEmpty) {
                return const Center(child: Text('No hay sensores instalados en este espacio.'));
              }

              return ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(
                          Icons.sensors,
                          color: device.status == 'Active' ? Colors.green : Colors.grey
                      ),
                      title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Tipo: ${device.type} | Estado: ${device.status}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          // Dispara el evento de eliminar
                          context.read<IotBloc>().add(
                              DeleteDeviceEvent(deviceId: device.id, spaceId: spaceId)
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                            context,
                            '/iot/detail',
                            arguments: {
                              'deviceId': device.id,
                              'deviceName': device.name,
                            }
                        );
                      },
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('Inicializando sensores...'));
          },
        ),
        floatingActionButton: Builder(
            builder: (context) {
              return FloatingActionButton(
                backgroundColor: const Color(0xFF2C3E50),
                onPressed: () {
                  // Mostramos el modal inferior
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // Permite que suba si el teclado aparece
                    backgroundColor: const Color(0xFF1E1E1E), // Tono oscuro que usas en tu app
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (bottomSheetContext) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
                          left: 16,
                          right: 16,
                          top: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Registrar Nuevo Sensor',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            // Simulamos los campos
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Nombre del dispositivo (ej. Sensor Cocina)',
                                filled: true,
                                fillColor: Color(0xFF2A2A2A),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Tipo de sensor',
                                filled: true,
                                fillColor: Color(0xFF2A2A2A),
                              ),
                              dropdownColor: const Color(0xFF2A2A2A),
                              style: const TextStyle(color: Colors.white),
                              items: const [
                                DropdownMenuItem(value: 'Temperature', child: Text('Temperatura')),
                                DropdownMenuItem(value: 'Humidity', child: Text('Humedad')),
                                DropdownMenuItem(value: 'Motion', child: Text('Movimiento')),
                              ],
                              onChanged: (value) {},
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C3E50),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () {
                                // TODO: Conectar los controladores de texto reales
                                // context.read<IotBloc>().add(AddDeviceEvent(...));
                                Navigator.pop(bottomSheetContext); // Cierra el modal
                              },
                              child: const Text('Guardar Sensor', style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: const Icon(Icons.add, color: Colors.white),
              );
            }
        ),
      ),
    );
  }
}