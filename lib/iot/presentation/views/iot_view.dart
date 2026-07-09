import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../spaces/domain/repositories/space_repository.dart';
import '../../../spaces/domain/models/space.dart';
import '../../application/bloc/IotBloc.dart';
import '../../application/bloc/IotEvent.dart';
import '../../application/bloc/IotState.dart';
import '../../../service_locator.dart';
import 'iot_device_detail_view.dart'; // Importamos la vista de detalles

class IotView extends StatefulWidget {
  const IotView({Key? key}) : super(key: key);

  @override
  State<IotView> createState() => _IotViewState();
}

class _IotViewState extends State<IotView> {
  late Future<List<Space>> _spacesFuture;
  Space? _selectedSpace;
  late IotBloc _iotBloc;

  @override
  void initState() {
    super.initState();
    _iotBloc = getIt<IotBloc>();

    _spacesFuture = getIt<SpaceRepository>().getMySpaces().then((spaces) {
      if (spaces.isNotEmpty) {
        setState(() {
          _selectedSpace = spaces.first;
        });
        _iotBloc.add(LoadDevicesEvent(_selectedSpace!.id));
      }
      return spaces;
    });
  }

  void _showAddDeviceModal(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    String selectedType = 'Temperature';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del dispositivo (ej. Sensor Cocina)',
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF2A2A2A),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de sensor',
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF2A2A2A),
                      border: OutlineInputBorder(),
                    ),
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'Temperature', child: Text('Temperatura')),
                      DropdownMenuItem(value: 'Humidity', child: Text('Humedad')),
                      DropdownMenuItem(value: 'Motion', child: Text('Movimiento')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (nameController.text.isNotEmpty && _selectedSpace != null) {
                        _iotBloc.add(AddDeviceEvent(
                          spaceId: _selectedSpace!.id,
                          name: nameController.text,
                          type: selectedType,
                        ));
                        Navigator.pop(bottomSheetContext);
                      }
                    },
                    child: const Text('Guardar Sensor', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _iotBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text('Monitoreo IoT', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF2C3E50),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: FutureBuilder<List<Space>>(
          future: _spacesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No tienes espacios asignados.', style: TextStyle(color: Colors.white)));
            }

            final spaces = snapshot.data!;

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: const Color(0xFF1E1E1E),
                  child: Row(
                    children: [
                      const Icon(Icons.business, color: Colors.blueAccent),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Space>(
                            dropdownColor: const Color(0xFF2A2A2A),
                            value: _selectedSpace,
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            items: spaces.map((Space space) {
                              return DropdownMenuItem<Space>(
                                value: space,
                                child: Text(space.title),
                              );
                            }).toList(),
                            onChanged: (Space? newValue) {
                              if (newValue != null && newValue != _selectedSpace) {
                                setState(() {
                                  _selectedSpace = newValue;
                                });
                                _iotBloc.add(LoadDevicesEvent(newValue.id));
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: BlocBuilder<IotBloc, IotState>(
                    builder: (context, state) {
                      if (state is IotLoading) {
                        return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                      } else if (state is IotError) {
                        return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                      } else if (state is IotDevicesLoaded) {
                        final devices = state.devices;
                        if (devices.isEmpty) {
                          return const Center(child: Text('No hay sensores en este espacio.', style: TextStyle(color: Colors.white)));
                        }

                        return ListView.builder(
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            return Card(
                              color: const Color(0xFF1E1E1E),
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: Icon(
                                  Icons.sensors,
                                  color: device.status == 'Active' ? Colors.greenAccent : Colors.grey,
                                ),
                                title: Text(device.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                subtitle: Text('Tipo: ${device.type}', style: const TextStyle(color: Colors.grey)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () {
                                    if (_selectedSpace != null) {
                                      _iotBloc.add(DeleteDeviceEvent(deviceId: device.id, spaceId: _selectedSpace!.id));
                                    }
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => IotDeviceDetailView(
                                        deviceId: device.id,
                                        deviceName: device.name,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: _selectedSpace == null ? null : FloatingActionButton(
          backgroundColor: const Color(0xFF2C3E50),
          onPressed: () => _showAddDeviceModal(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}