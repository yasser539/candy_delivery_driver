class DeliveryCaptain {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? position; // 'كابتن توصيل' أو 'مندوب'
  final String? department;
  final String? status; // 'نشط'، 'إجازة'، 'غير نشط'
  final String? location;
  final String? city;
  final String? region;
  final String? description;
  final String? avatar;
  final String? profileImage;
  final int? performance;
  final int? tasks;
  final int? completed;
  final double? rating;
  final int? totalDeliveries;
  final double? totalEarnings;
  final String? vehicleType;
  final String? vehicleModel;
  final String? vehiclePlate;
  final String? vehicleColor;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? idNumber;
  final String? licenseNumber;
  final String? insuranceNumber;
  final DateTime? joinDate;
  final DateTime? contractStartDate;
  final DateTime? contractEndDate;
  final double? salary;
  final double? commissionRate;
  final String? deviceId;
  final String? appVersion;
  final DateTime? lastActive;
  final bool? isVerified;
  final DateTime? verificationDate;
  final String? backgroundCheckStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final String? adminNotes;

  DeliveryCaptain({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.position,
    this.department,
    this.status,
    this.location,
    this.city,
    this.region,
    this.description,
    this.avatar,
    this.profileImage,
    this.performance,
    this.tasks,
    this.completed,
    this.rating,
    this.totalDeliveries,
    this.totalEarnings,
    this.vehicleType,
    this.vehicleModel,
    this.vehiclePlate,
    this.vehicleColor,
    this.emergencyContact,
    this.emergencyPhone,
    this.idNumber,
    this.licenseNumber,
    this.insuranceNumber,
    this.joinDate,
    this.contractStartDate,
    this.contractEndDate,
    this.salary,
    this.commissionRate,
    this.deviceId,
    this.appVersion,
    this.lastActive,
    this.isVerified,
    this.verificationDate,
    this.backgroundCheckStatus,
    this.createdAt,
    this.updatedAt,
    this.notes,
    this.adminNotes,
  });

  factory DeliveryCaptain.fromMap(Map<String, dynamic> map) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return DeliveryCaptain(
      id: map['id'] as String,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      position: map['position'],
      department: map['department'],
      status: map['status'],
      location: map['location'],
      city: map['city'],
      region: map['region'],
      description: map['description'],
      avatar: map['avatar']?.toString(),
      profileImage: map['profile_image'],
      performance: map['performance'],
      tasks: map['tasks'],
      completed: map['completed'],
      rating: toDouble(map['rating']),
      totalDeliveries: map['total_deliveries'],
      totalEarnings: toDouble(map['total_earnings']),
      vehicleType: map['vehicle_type'],
      vehicleModel: map['vehicle_model'],
      vehiclePlate: map['vehicle_plate'],
      vehicleColor: map['vehicle_color'],
      emergencyContact: map['emergency_contact'],
      emergencyPhone: map['emergency_phone'],
      idNumber: map['id_number'],
      licenseNumber: map['license_number'],
      insuranceNumber: map['insurance_number'],
      joinDate: toDate(map['join_date']),
      contractStartDate: toDate(map['contract_start_date']),
      contractEndDate: toDate(map['contract_end_date']),
      salary: toDouble(map['salary']),
      commissionRate: toDouble(map['commission_rate']),
      deviceId: map['device_id'],
      appVersion: map['app_version'],
      lastActive: toDate(map['last_active']),
      isVerified: map['is_verified'] == null
          ? null
          : (map['is_verified'] is bool
                ? map['is_verified'] as bool
                : map['is_verified'].toString().toLowerCase() == 'true'),
      verificationDate: toDate(map['verification_date']),
      backgroundCheckStatus: map['background_check_status'],
      createdAt: toDate(map['created_at']),
      updatedAt: toDate(map['updated_at']),
      notes: map['notes'],
      adminNotes: map['admin_notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'department': department,
      'status': status,
      'location': location,
      'city': city,
      'region': region,
      'description': description,
      'avatar': avatar,
      'profile_image': profileImage,
      'performance': performance,
      'tasks': tasks,
      'completed': completed,
      'rating': rating,
      'total_deliveries': totalDeliveries,
      'total_earnings': totalEarnings,
      'vehicle_type': vehicleType,
      'vehicle_model': vehicleModel,
      'vehicle_plate': vehiclePlate,
      'vehicle_color': vehicleColor,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
      'id_number': idNumber,
      'license_number': licenseNumber,
      'insurance_number': insuranceNumber,
      'join_date': joinDate?.toIso8601String(),
      'contract_start_date': contractStartDate?.toIso8601String(),
      'contract_end_date': contractEndDate?.toIso8601String(),
      'salary': salary,
      'commission_rate': commissionRate,
      'device_id': deviceId,
      'app_version': appVersion,
      'last_active': lastActive?.toIso8601String(),
      'is_verified': isVerified,
      'verification_date': verificationDate?.toIso8601String(),
      'background_check_status': backgroundCheckStatus,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'notes': notes,
      'admin_notes': adminNotes,
    };
  }
}
