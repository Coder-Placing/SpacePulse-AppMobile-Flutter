import 'package:tfmoviles2/iam/domain/models/payment_method.dart';

class User {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? photoUrl;
  final List<PaymentMethod> paymentMethods;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.photoUrl,
    this.paymentMethods = const [],
  });
}
