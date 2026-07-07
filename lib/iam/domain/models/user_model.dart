class User {
  final String id;
  final String email;
  final String? name;
  final String? phone;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
  });
}
