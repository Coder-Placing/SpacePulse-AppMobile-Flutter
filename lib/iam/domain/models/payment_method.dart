class PaymentMethod {
  final String id;
  final String type;
  final String lastFourDigits;
  final String expiry;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.lastFourDigits,
    required this.expiry,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      lastFourDigits: json['lastFourDigits'] ?? '',
      expiry: json['expiry'] ?? '',
    );
  }
}
