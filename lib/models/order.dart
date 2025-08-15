import 'location.dart';

class Order {
  final String id;
  final String customerName;
  final String customerPhone;
  final Location pickupLocation;
  final Location deliveryLocation;
  final String? productType;
  final String? productDescription;
  final double amount;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final String? driverId;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? notes;
  final double? rating;
  final String? feedback;

  Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.pickupLocation,
    required this.deliveryLocation,
    this.productType,
    this.productDescription,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.driverId,
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.notes,
    this.rating,
    this.feedback,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      pickupLocation: Location.fromJson(json['pickupLocation']),
      deliveryLocation: Location.fromJson(json['deliveryLocation']),
      productType: json['productType'],
      productDescription: json['productDescription'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${json['paymentMethod']}',
        orElse: () => PaymentMethod.cash,
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      driverId: json['driverId'],
      createdAt: DateTime.parse(json['createdAt']),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      pickedUpAt: json['pickedUpAt'] != null
          ? DateTime.parse(json['pickedUpAt'])
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      notes: json['notes'],
      rating: json['rating']?.toDouble(),
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'pickupLocation': pickupLocation.toJson(),
      'deliveryLocation': deliveryLocation.toJson(),
      'productType': productType,
      'productDescription': productDescription,
      'amount': amount,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'status': status.toString().split('.').last,
      'driverId': driverId,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'notes': notes,
      'rating': rating,
      'feedback': feedback,
    };
  }

  Order copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    Location? pickupLocation,
    Location? deliveryLocation,
    String? productType,
    String? productDescription,
    double? amount,
    PaymentMethod? paymentMethod,
    OrderStatus? status,
    String? driverId,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    String? notes,
    double? rating,
    String? feedback,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      productType: productType ?? this.productType,
      productDescription: productDescription ?? this.productDescription,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
    );
  }

  // Helper methods
  bool get isPending => status == OrderStatus.pending;
  bool get isUnderReview => status == OrderStatus.underReview;
  bool get isApprovedSearching => status == OrderStatus.approvedSearching;
  bool get isOnTheWay => status == OrderStatus.onTheWay;
  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isCompleted =>
      status == OrderStatus.delivered || status == OrderStatus.cancelled;
  bool get isActive =>
      status == OrderStatus.pending || status == OrderStatus.onTheWay;

  String get statusText {
    switch (status) {
      case OrderStatus.underReview:
        return 'قيد المراجعة';
      case OrderStatus.approvedSearching:
        return 'تم الموافقة وجاري البحث عن موصل';
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.onTheWay:
        return 'في الطريق إليك';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
      case OrderStatus.failed:
        return 'فشل التوصيل';
    }
  }

  String get paymentMethodText {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'نقدي';
      case PaymentMethod.card:
        return 'بطاقة ائتمان';
      case PaymentMethod.online:
        return 'دفع إلكتروني';
    }
  }
}

enum OrderStatus {
  underReview, // قيد المراجعة - للمسؤولين فقط
  approvedSearching, // تم الموافقة وجاري البحث عن موصل
  pending, // قيد الانتظار - بعد قبول الموصّل
  onTheWay, // في الطريق إليك
  delivered, // تم التوصيل
  cancelled, // ملغي
  failed, // فشل التوصيل
}

enum PaymentMethod { cash, card, online }
