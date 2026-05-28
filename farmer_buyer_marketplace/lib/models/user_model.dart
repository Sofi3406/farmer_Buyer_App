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
        id: json['_id'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
        phone: json['phone'],
        location: json['location'],
        farmDetails: json['farmDetails'],
        profileImage: json['profileImage'],
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