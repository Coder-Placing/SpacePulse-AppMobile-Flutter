class IotDevice {
  final int id;
  final String name; // ej: "Sensor de Pared Norte"
  final String type; // ej: "Temperature", "Humidity", "Motion"
  final String status; // ej: "Active", "Offline"
  final int spaceId;

  IotDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.spaceId,
  });

  // Este factory es vital para que Dio convierta el JSON del Swagger a nuestro objeto
  factory IotDevice.fromJson(Map<String, dynamic> json) {
    return IotDevice(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'Offline',
      spaceId: json['spaceId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'spaceId': spaceId,
    };
  }
}