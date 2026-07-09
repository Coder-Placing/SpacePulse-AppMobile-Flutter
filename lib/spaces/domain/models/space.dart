class Space {
  final int id;
  final String title;
  final String description;
  final String location;
  final String homeownerId;
  final String? remodelerId;
  final String spaceType;
  final double dimensionsSquareMeters;
  final double estimatedBudget;
  final double endingPricing;
  final String currency;
  final bool hasIot;
  final List<String> images;
  final String status;
  final DateTime publishedAt;
  final DateTime? acceptedAt;

  Space({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.homeownerId,
    this.remodelerId,
    required this.spaceType,
    required this.dimensionsSquareMeters,
    required this.estimatedBudget,
    required this.endingPricing,
    required this.currency,
    required this.hasIot,
    required this.images,
    required this.status,
    required this.publishedAt,
    this.acceptedAt,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      homeownerId: json['homeownerId'] as String,
      remodelerId: json['remodelerId'] as String?,
      spaceType: json['spaceType'] as String,
      dimensionsSquareMeters: (json['dimensionsSquareMeters'] as num).toDouble(),
      estimatedBudget: (json['estimatedBudget'] as num).toDouble(),
      endingPricing: (json['endingPricing'] as num).toDouble(),
      currency: json['currency'] as String,
      hasIot: json['hasIot'] as bool,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      status: json['status'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'homeownerId': homeownerId,
      'remodelerId': remodelerId,
      'spaceType': spaceType,
      'dimensionsSquareMeters': dimensionsSquareMeters,
      'estimatedBudget': estimatedBudget,
      'endingPricing': endingPricing,
      'currency': currency,
      'hasIot': hasIot,
      'images': images,
      'status': status,
      'publishedAt': publishedAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
    };
  }
}
