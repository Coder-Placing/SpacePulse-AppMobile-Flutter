class TaskModel {
  final int id;
  final int spaceId;
  final String createdByUserId;
  final String title;
  final String description;
  final String? photoUrl;
  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final double price;
  final String status;
  final DateTime? createdAt;
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.spaceId,
    required this.createdByUserId,
    required this.title,
    required this.description,
    this.photoUrl,
    this.plannedStartDate,
    this.plannedEndDate,
    required this.price,
    required this.status,
    this.createdAt,
    this.completedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      spaceId: json['spaceId'],
      createdByUserId: json['createdByUserId'],
      title: json['title'],
      description: json['description'],
      photoUrl: json['photoUrl'],
      plannedStartDate: json['plannedStartDate'] != null ? DateTime.parse(json['plannedStartDate']) : null,
      plannedEndDate: json['plannedEndDate'] != null ? DateTime.parse(json['plannedEndDate']) : null,
      price: (json['price'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spaceId': spaceId,
      'createdByUserId': createdByUserId,
      'title': title,
      'description': description,
      'photoUrl': photoUrl,
      'plannedStartDate': plannedStartDate?.toIso8601String(),
      'plannedEndDate': plannedEndDate?.toIso8601String(),
      'price': price,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
