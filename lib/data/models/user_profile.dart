class UserProfile {
  final String userId;
  final String? fullName;
  final String? phone;
  final String role; // user_role
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        userId: m['user_id'] as String,
        fullName: m['full_name'] as String?,
        phone: m['phone'] as String?,
        role: m['role'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'full_name': fullName,
        'phone': phone,
        'role': role,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
