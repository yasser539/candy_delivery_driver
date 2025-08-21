import 'dart:async';
import '../../models/order.dart';
import '../../models/location.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  // Stream controllers for real-time updates
  final StreamController<List<Order>> _availableOrdersController =
      StreamController<List<Order>>.broadcast();
  final StreamController<List<Order>> _myOrdersController =
      StreamController<List<Order>>.broadcast();
  final StreamController<List<Order>> _adminOrdersController =
      StreamController<List<Order>>.broadcast();

  // Streams for different order types
  Stream<List<Order>> get availableOrdersStream =>
      _availableOrdersController.stream;
  Stream<List<Order>> get myOrdersStream => _myOrdersController.stream;
  Stream<List<Order>> get adminOrdersStream => _adminOrdersController.stream;

  // Mock data - في التطبيق الحقيقي ستأتي من قاعدة البيانات
  final List<Order> _allOrders = [];
  String? _currentDriverId;

  // Initialize with mock data
  void initialize(String driverId) {
    _currentDriverId = driverId;
    _loadMockData();
    _updateStreams();
  }

  void _loadMockData() {
    if (_allOrders.isEmpty) {
      _allOrders.addAll([
        Order(
          id: '001',
          customerName: 'أحمد محمد',
          customerPhone: '+966501234567',
          pickupLocation: Location(
            latitude: 24.7136,
            longitude: 46.6753,
            address: 'شارع الملك فهد، الرياض',
            timestamp: DateTime.now(),
          ),
          deliveryLocation: Location(
            latitude: 24.7136,
            longitude: 46.6753,
            address: 'شارع التحلية، الرياض',
            timestamp: DateTime.now(),
          ),
          productType: 'مياه',
          productDescription: 'مياه معدنية - 5 لتر، مياه غازية - 2 لتر',
          amount: 45.0,
          paymentMethod: PaymentMethod.cash,
          status: OrderStatus.approvedSearching, // متاح للموصّلين
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        Order(
          id: '002',
          customerName: 'فاطمة علي',
          customerPhone: '+966507654321',
          pickupLocation: Location(
            latitude: 24.7136,
            longitude: 46.6753,
            address: 'شارع العليا، الرياض',
            timestamp: DateTime.now(),
          ),
          deliveryLocation: Location(
            latitude: 24.7136,
            longitude: 46.6753,
            address: 'شارع النزهة، الرياض',
            timestamp: DateTime.now(),
          ),
          productType: 'مياه',
          productDescription: 'مياه معدنية - 10 لتر',
          amount: 30.0,
          paymentMethod: PaymentMethod.online,
          status: OrderStatus.approvedSearching, // متاح للموصّلين
          createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        Order(
          id: '003',
          customerName: 'خالد عبدالله',
          customerPhone: '+966509876543',
          pickupLocation: Location(
            latitude: 24.7136,
            longitude: 46.6753,
            address: 'شارع الملك عبدالله، الرياض',
            timestamp: DateTime.now(),
          ),
          deliveryLocation: Location(
            latitude: 24.7136,
            longitude: 46.6753,
            address: 'شارع الأمير محمد، الرياض',
            timestamp: DateTime.now(),
          ),
          productType: 'مياه',
          productDescription: 'مياه معدنية - 3 لتر، مياه غازية - 1 لتر',
          amount: 25.0,
          paymentMethod: PaymentMethod.cash,
          status: OrderStatus.pending, // مخصص للموصّل الحالي
          driverId: _currentDriverId,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          acceptedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
      ]);
    }
  }

  // Get available orders for drivers (approvedSearching status)
  List<Order> getAvailableOrders() {
    return _allOrders
        .where((order) => order.status == OrderStatus.approvedSearching)
        .toList();
  }

  // Get my orders (assigned to current driver)
  List<Order> getMyOrders() {
    return _allOrders
        .where((order) =>
            order.driverId == _currentDriverId &&
            (order.status == OrderStatus.pending ||
                order.status == OrderStatus.onTheWay ||
                order.status == OrderStatus.delivered))
        .toList();
  }

  // Get admin orders (underReview status)
  List<Order> getAdminOrders() {
    return _allOrders
        .where((order) => order.status == OrderStatus.underReview)
        .toList();
  }

  // Accept order by driver
  Future<bool> acceptOrder(String orderId) async {
    final orderIndex = _allOrders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) return false;

    final order = _allOrders[orderIndex];

    // Check if order is available for acceptance
    if (order.status != OrderStatus.approvedSearching) {
      return false;
    }

    // Update order status and assign to driver
    _allOrders[orderIndex] = order.copyWith(
      status: OrderStatus.pending,
      driverId: _currentDriverId,
      acceptedAt: DateTime.now(),
    );

    _updateStreams();
    return true;
  }

  // Update order status by driver
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final orderIndex = _allOrders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) return false;

    final order = _allOrders[orderIndex];

    // Check if current driver owns this order
    if (order.driverId != _currentDriverId) {
      return false;
    }

    // Validate status transition
    if (!_isValidStatusTransition(order.status, newStatus)) {
      return false;
    }

    // Update order status
    _allOrders[orderIndex] = order.copyWith(
      status: newStatus,
      pickedUpAt:
          newStatus == OrderStatus.onTheWay ? DateTime.now() : order.pickedUpAt,
      deliveredAt: newStatus == OrderStatus.delivered
          ? DateTime.now()
          : order.deliveredAt,
    );

    _updateStreams();
    return true;
  }

  // Admin approves order
  Future<bool> approveOrder(String orderId) async {
    final orderIndex = _allOrders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) return false;

    final order = _allOrders[orderIndex];

    // Check if order is under review
    if (order.status != OrderStatus.underReview) {
      return false;
    }

    // Update order status to approved and searching for driver
    _allOrders[orderIndex] = order.copyWith(
      status: OrderStatus.approvedSearching,
    );

    _updateStreams();
    return true;
  }

  // Create new order (admin only)
  Future<bool> createOrder(Order order) async {
    // Set initial status to under review
    final newOrder = order.copyWith(
      status: OrderStatus.underReview,
      createdAt: DateTime.now(),
    );

    _allOrders.add(newOrder);
    _updateStreams();
    return true;
  }

  // Validate status transition
  bool _isValidStatusTransition(
      OrderStatus currentStatus, OrderStatus newStatus) {
    switch (currentStatus) {
      case OrderStatus.pending:
        return newStatus == OrderStatus.onTheWay ||
            newStatus == OrderStatus.cancelled;
      case OrderStatus.onTheWay:
        return newStatus == OrderStatus.delivered ||
            newStatus == OrderStatus.failed;
      default:
        return false;
    }
  }

  // Update all streams
  void _updateStreams() {
    if (!_availableOrdersController.isClosed) {
      _availableOrdersController.add(getAvailableOrders());
    }
    if (!_myOrdersController.isClosed) {
      _myOrdersController.add(getMyOrders());
    }
    if (!_adminOrdersController.isClosed) {
      _adminOrdersController.add(getAdminOrders());
    }
  }

  // Dispose streams
  void dispose() {
    _availableOrdersController.close();
    _myOrdersController.close();
    _adminOrdersController.close();
  }
}
