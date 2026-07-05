class TelemetryRecord {
  final int id;
  final int spaceId;
  final String type;
  final String name;
  final String serialNumber;
  final String metricName;
  final double value;
  final String unit;
  final DateTime timestamp;
  final bool isOn;
  final double minThreshold;
  final double maxThreshold;
  final bool isInAlertState;

  TelemetryRecord({
    required this.id,
    required this.spaceId,
    required this.type,
    required this.name,
    required this.serialNumber,
    required this.metricName,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.isOn,
    required this.minThreshold,
    required this.maxThreshold,
    required this.isInAlertState,
  });

  factory TelemetryRecord.fromJson(Map<String, dynamic> json) {
    return TelemetryRecord(
      id: json['id'] ?? 0,
      spaceId: json['spaceId'] ?? 0,
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      metricName: json['metricName'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isOn: json['isOn'] ?? false,
      minThreshold: (json['minThreshold'] ?? 0).toDouble(),
      maxThreshold: (json['maxThreshold'] ?? 0).toDouble(),
      isInAlertState: json['isInAlertState'] ?? false,
    );
  }
}