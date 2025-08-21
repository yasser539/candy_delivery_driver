import 'location.dart';

class Driver {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? profileImage;
  final String? vehicleNumber;
  final String? vehicleType;
  final DriverStatus status;
  final Location? currentLocation;
  final double rating;
  final int totalDeliveries;
  final double totalEarnings;
  final DateTime createdAt;
  final DateTime? lastActive;

  Driver({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.profileImage,
    this.vehicleNumber,
    this.vehicleType,
    required this.status,
    this.currentLocation,
    this.rating = 0.0,
    this.totalDeliveries = 0,
    this.totalEarnings = 0.0,
    required this.createdAt,
    this.lastActive,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      profileImage: json['profileImage'],
      vehicleNumber: json['vehicleNumber'],
      vehicleType: json['vehicleType'],
      status: DriverStatus.values.firstWhere(
        (e) => e.toString() == 'DriverStatus.${json['status']}',
        orElse: () => DriverStatus.offline,
      ),
      currentLocation: json['currentLocation'] != null
          ? Location.fromJson(json['currentLocation'])
          : null,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalDeliveries: json['totalDeliveries'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImage': profileImage,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'status': status.toString().split('.').last,
      'currentLocation': currentLocation?.toJson(),
      'rating': rating,
      'totalDeliveries': totalDeliveries,
      'totalEarnings': totalEarnings,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
    };
  }

  Driver copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? profileImage,
    String? vehicleNumber,
    String? vehicleType,
    DriverStatus? status,
    Location? currentLocation,
    double? rating,
    int? totalDeliveries,
    double? totalEarnings,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

enum DriverStatus { online, offline, busy, onDelivery, maintenance }
