class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'farmer', 'buyer', 'admin'
  final String phone;
  final String? location;
  final String? farmDetails;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    this.location,
    this.farmDetails,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'buyer',
      phone: json['phone']?.toString() ?? '',
      location: json['location']?.toString(),
      farmDetails: json['farmDetails']?.toString(),
      profileImage: json['profileImage']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'location': location,
        'farmDetails': farmDetails,
        'profileImage': profileImage,
      };
}