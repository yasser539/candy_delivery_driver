class UserAddress {
  final String id;
  final String userId;
  final String? label;
  final String line1;
  final String? line2;
  final String city;
  final String? state;
  final String? postalCode;
  final String country;
  final double? lat;
  final double? lng;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserAddress({
    required this.id,
    required this.userId,
    required this.label,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.lat,
    required this.lng,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserAddress.fromMap(Map<String, dynamic> m) => UserAddress(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        label: m['label'] as String?,
        line1: m['line1'] as String,
        line2: m['line2'] as String?,
        city: m['city'] as String,
        state: m['state'] as String?,
        postalCode: m['postal_code'] as String?,
        country: (m['country'] as String?) ?? 'US',
        lat: (m['lat'] as num?)?.toDouble(),
        lng: (m['lng'] as num?)?.toDouble(),
        isDefault: (m['is_default'] as bool?) ?? false,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'label': label,
        'line1': line1,
        'line2': line2,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
        'lat': lat,
        'lng': lng,
        'is_default': isDefault,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
