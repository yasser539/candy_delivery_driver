class DeliveryCaptain {
  final String id;
  final String fullName;
  final String phone;
  final String password;
  final String position; // 'كابتن توصيل' أو 'مندوب'
  final String status; // 'نشط'، 'إجازة'، 'غير نشط'
  final String? location;
  final String? city;
  final String? region;
  final String? nationalId;
  final DateTime? birthDate;
  final DateTime? startDate;
  final String? vehicleType;
  final String? vehiclePlate;
  final String? licenseNumber;
  final String? profileImageUrl;
  final String? driverAddress;
  final double? driverLatitude;
  final double? driverLongitude;
  final double? driverRating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DeliveryCaptain({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.password,
    required this.position,
    required this.status,
    this.location,
    this.city,
    this.region,
    this.nationalId,
    this.birthDate,
    this.startDate,
    this.vehicleType,
    this.vehiclePlate,
    this.licenseNumber,
  this.profileImageUrl,
  this.driverAddress,
  this.driverLatitude,
  this.driverLongitude,
  this.driverRating,
    this.createdAt,
    this.updatedAt,
  });

  factory DeliveryCaptain.fromMap(Map<String, dynamic> map) {
    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return DeliveryCaptain(
      id: map['id']?.toString() ?? '',
      fullName: (map['full_name'] ?? '').toString(),
  // phone is now stored under driver_phone; keep fallback for backward compatibility
  phone: (map['driver_phone'] ?? map['phone'] ?? '').toString(),
      password: (map['password'] ?? '').toString(),
      position: (map['position'] ?? '').toString(),
      status: (map['status'] ?? '').toString(),
      location: map['location']?.toString(),
      city: map['city']?.toString(),
      region: map['region']?.toString(),
      nationalId: map['national_id']?.toString(),
      birthDate: toDate(map['birth_date']),
      startDate: toDate(map['start_date']),
      vehicleType: map['vehicle_type']?.toString(),
      vehiclePlate: map['vehicle_plate']?.toString(),
      licenseNumber: map['license_number']?.toString(),
      profileImageUrl: map['profile_image_url']?.toString(),
      driverAddress: map['driver_address']?.toString(),
      driverLatitude: toDouble(map['driver_latitude']),
      driverLongitude: toDouble(map['driver_longitude']),
      driverRating: toDouble(map['driver_rating']),
      createdAt: toDate(map['created_at']),
      updatedAt: toDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
  // persist under the new column name
  'driver_phone': phone,
      'password': password,
      'position': position,
      'status': status,
      'location': location,
      'city': city,
      'region': region,
      'national_id': nationalId,
      'birth_date': birthDate?.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'vehicle_type': vehicleType,
      'vehicle_plate': vehiclePlate,
      'license_number': licenseNumber,
      'profile_image_url': profileImageUrl,
      'driver_address': driverAddress,
      'driver_latitude': driverLatitude,
      'driver_longitude': driverLongitude,
      'driver_rating': driverRating,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
