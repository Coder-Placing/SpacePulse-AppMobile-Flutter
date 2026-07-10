class IotDevice {
  final int id;
  final String name;
  final String type;
  final String status;
  final int spaceId;
  final String serialNumber;

  IotDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.spaceId,
    required this.serialNumber,
  });

  factory IotDevice.fromJson(Map<String, dynamic> json) {
    return IotDevice(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'Offline',
      spaceId: json['spaceId'] ?? 0,
      serialNumber: json['serialNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'spaceId': spaceId,
      'serialNumber': serialNumber,
    };
  }
}