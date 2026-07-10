import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/IotBloc.dart';
import '../../application/bloc/IotEvent.dart';
import '../../application/bloc/IotState.dart';
import '../../../service_locator.dart';

class IotDeviceDetailView extends StatefulWidget {
  final int deviceId;
  final String deviceName;

  const IotDeviceDetailView({
    Key? key,
    required this.deviceId,
    required this.deviceName,
  }) : super(key: key);

  @override
  State<IotDeviceDetailView> createState() => _IotDeviceDetailViewState();
}

class _IotDeviceDetailViewState extends State<IotDeviceDetailView> {
  late IotBloc _detailBloc;

  @override
  void initState() {
    super.initState();
    _detailBloc = getIt<IotBloc>();
    _detailBloc.add(LoadTelemetryEvent(widget.deviceId));
  }

  @override
  void dispose() {
    _detailBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _detailBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: BlocBuilder<IotBloc, IotState>(
            builder: (context, state) {
              String title = widget.deviceName;
              if (state is IotTelemetryLoaded && state.records.isNotEmpty) {
                title = state.records.first.name;
              }
              return Text(title, style: const TextStyle(color: Colors.white));
            },
          ),
          backgroundColor: const Color(0xFF2C3E50),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<IotBloc, IotState>(
          builder: (context, state) {
            if (state is IotLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
            } else if (state is IotError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            } else if (state is IotTelemetryLoaded) {
              final records = state.records;

              if (records.isEmpty) {
                return const Center(
                  child: Text('Aún no hay lecturas registradas para este sensor.',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  final dateStr = "${record.timestamp.day.toString().padLeft(2, '0')}/${record.timestamp.month.toString().padLeft(2, '0')}/${record.timestamp.year}";
                  final timeStr = "${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}";
                  return Card(
                    color: const Color(0xFF1E1E1E),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: record.isInAlertState ? Colors.redAccent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                record.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  record.isOn ? Icons.power_settings_new : Icons.power_off,
                                  color: record.isOn ? Colors.greenAccent : Colors.redAccent,
                                  size: 30,
                                ),
                                onPressed: () {
                                  _detailBloc.add(ToggleDevicePowerEvent(widget.deviceId));
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Serial: ${record.serialNumber} | Métrica: ${record.metricName}',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const Divider(color: Colors.white24, height: 40, thickness: 1),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  '${record.value} ${record.unit}',
                                  style: TextStyle(
                                    color: record.isInAlertState ? Colors.redAccent : Colors.white,
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (record.isInAlertState)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '¡ALERTA: FUERA DE RANGO!',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white24, height: 40, thickness: 1),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Text('Mínimo', style: TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${record.minThreshold} ${record.unit}',
                                    style: const TextStyle(color: Colors.white, fontSize: 18),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 40, color: Colors.white24),
                              Column(
                                children: [
                                  const Text('Máximo', style: TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${record.maxThreshold} ${record.unit}',
                                    style: const TextStyle(color: Colors.white, fontSize: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Text(
                              'Actualizado: $dateStr a las $timeStr',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ],
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