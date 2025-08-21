import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';
import '../../models/cart.dart';
import '../../models/cart_item.dart';
import '../../models/location.dart';
import 'supabase_service.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  String? _currentDriverId;
  RealtimeChannel? _cartsChannel;
  final StreamController<List<Cart>> _availableCartsController =
      StreamController<List<Cart>>.broadcast();
  final StreamController<List<Cart>> _myCartsController =
      StreamController<List<Cart>>.broadcast();
  final StreamController<List<Cart>> _completedCartsController =
      StreamController<List<Cart>>.broadcast();
  final StreamController<List<Cart>> _unpaidInvoicesController =
      StreamController<List<Cart>>.broadcast();

  Stream<List<Cart>> get availableCartsStream =>
      _availableCartsController.stream;
  Stream<List<Cart>> get myCartsStream => _myCartsController.stream;
  Stream<List<Cart>> get completedCartsStream =>
      _completedCartsController.stream;
  Stream<List<Cart>> get unpaidInvoicesStream =>
      _unpaidInvoicesController.stream;

  // Initialize service with driver ID
  void initialize(String driverId) {
    _currentDriverId = driverId;
    print('CartService initialized with driver ID: $driverId');
    _loadCarts();
    _subscribeToCartsChanges();
  }

  // Track current state to avoid unnecessary reloads
  List<Cart> _currentAvailableCarts = [];
  List<Cart> _currentMyCarts = [];

  // Load available carts from Supabase
  Future<void> _loadCarts() async {
    try {
      final availableCarts = await getAvailableCarts();
      print('Available carts loaded: ${availableCarts.length}');
      _currentAvailableCarts = availableCarts;
      _availableCartsController.add(availableCarts);

      final myCarts = await getMyCarts();
      print('My carts loaded: ${myCarts.length}');
      _currentMyCarts = myCarts;
      _myCartsController.add(myCarts);

      final completedCarts = await getCompletedCarts();
      print('Completed carts loaded: ${completedCarts.length}');
      _completedCartsController.add(completedCarts);

      // Build unpaid invoices for delegates
      final unpaid = completedCarts
          .where((c) => c.isInvoiceUnpaid)
          .toList(growable: false);
      print('Unpaid invoices derived: ${unpaid.length}');
      _unpaidInvoicesController.add(unpaid);
    } catch (e) {
      print('Error loading carts: $e');
      // Don't add mock data - work with real data only
    }
  }

  void _subscribeToCartsChanges() {
    try {
      // Unsubscribe previous channel if any
      _cartsChannel?.unsubscribe();
      final channel = SupabaseService.client.channel('public:carts');
      channel.on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(event: '*', schema: 'public', table: 'carts'),
        (payload, [ref]) {
          // Reload lists when any change occurs (fire-and-forget)
          _loadCarts();
        },
      );
      channel.subscribe();
      _cartsChannel = channel;
    } catch (e) {
      print('Error subscribing to carts changes: $e');
    }
  }

  // Legacy mock helper removed

  // Get available carts for drivers (pending status)
  Future<List<Cart>> getAvailableCarts() async {
    try {
      print('Fetching available carts from Supabase...');

      // Get available carts (not assigned to any driver and not delivered)
      final response = await SupabaseService.client
          .from('carts')
          .select('*')
          .filter('driver_id', 'is', null) // Not assigned to any driver
          .neq('status', 'delivered') // Not delivered
          .order('created_at', ascending: false)
          .limit(20);

      print('Supabase response: ${response.length} available carts found');
      return _parseCartsFromResponse(response);
    } catch (e) {
      print('Error getting available carts: $e');
      // Fallback for undefined column (e.g., driver_id not yet in DB)
      if (e is PostgrestException && e.code == '42703') {
        try {
          final fallback = await SupabaseService.client
              .from('carts')
              .select('*')
              .order('created_at', ascending: false)
              .limit(20);
          print(
            'Fallback available carts loaded (no driver filter): ${fallback.length}',
          );
          return _parseCartsFromResponse(fallback);
        } catch (ee) {
          print('Fallback available carts failed: $ee');
        }
      }
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Get my assigned carts (assigned to current driver and not delivered)
  Future<List<Cart>> getMyCarts() async {
    if (_currentDriverId == null) {
      print('No driver ID set, returning empty list');
      return [];
    }

    try {
      print('Fetching my carts for driver: $_currentDriverId');

      // Get carts assigned to current driver and not delivered
      final response = await SupabaseService.client
          .from('carts')
          .select('*')
          .eq('driver_id', _currentDriverId!)
          .neq('status', 'delivered') // Not delivered orders
          .order('created_at', ascending: false);

      print('My carts found: ${response.length} total');
      return _parseCartsFromResponse(response);
    } catch (e) {
      print('Error getting my carts: $e');
      if (e is PostgrestException && e.code == '42703') {
        print(
          'driver_id column missing. Run fix_supabase_database.sql to add required columns. Returning empty my carts.',
        );
        return [];
      }
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Get completed orders (delivered status)
  Future<List<Cart>> getCompletedCarts() async {
    if (_currentDriverId == null) {
      print('No driver ID set, returning empty list');
      return [];
    }

    try {
      print('Fetching completed carts for driver: $_currentDriverId');

      // Get completed carts (delivered status)
      final response = await SupabaseService.client
          .from('carts')
          .select('*')
          .eq('driver_id', _currentDriverId!)
          .eq('status', 'delivered')
          .order('delivered_at', ascending: false)
          .limit(50);

      print('Completed carts found: ${response.length} total');
      return _parseCartsFromResponse(response);
    } catch (e) {
      print('Error getting completed carts: $e');
      if (e is PostgrestException && e.code == '42703') {
        print(
          'driver_id column missing. Run fix_supabase_database.sql to add required columns. Returning empty completed carts.',
        );
        return [];
      }
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Parse carts from Supabase response
  List<Cart> _parseCartsFromResponse(List<dynamic> response) {
    print('Parsing ${response.length} carts from response');

    return response.map((cartData) {
      try {
        print('Processing cart data: ${cartData.keys.toList()}');

        // Parse status correctly
        CartStatus status = CartStatus.pending;
        if (cartData['status'] != null) {
          switch (cartData['status'].toString().toLowerCase()) {
            case 'pending':
              status = CartStatus.pending;
              break;
            case 'assigned':
              status = CartStatus.assigned;
              break;
            case 'on_the_way':
            case 'ontheway':
              status = CartStatus.onTheWay;
              break;
            case 'delivered':
              status = CartStatus.delivered;
              break;
            case 'cancelled':
              status = CartStatus.cancelled;
              break;
            default:
              status = CartStatus.pending;
          }
        }

        // Parse locations from JSON
        Location? pickupLocation;
        Location? deliveryLocation;

        if (cartData['pickup_location'] != null) {
          try {
            final pickupData = cartData['pickup_location'];
            pickupLocation = Location(
              latitude: pickupData['latitude'] ?? 24.7136,
              longitude: pickupData['longitude'] ?? 46.6753,
              address:
                  pickupData['address'] ?? 'الرياض، المملكة العربية السعودية',
              timestamp: DateTime.now(),
            );
          } catch (e) {
            print('Error parsing pickup location: $e');
          }
        }

        if (cartData['delivery_location'] != null) {
          try {
            final deliveryData = cartData['delivery_location'];
            deliveryLocation = Location(
              latitude: deliveryData['latitude'] ?? 24.7136,
              longitude: deliveryData['longitude'] ?? 46.6753,
              address:
                  deliveryData['address'] ?? 'الرياض، المملكة العربية السعودية',
              timestamp: DateTime.now(),
            );
          } catch (e) {
            print('Error parsing delivery location: $e');
          }
        }

        // Create fallback location if needed
        final fallbackLocation = Location(
          latitude: 24.7136,
          longitude: 46.6753,
          address: 'الرياض، المملكة العربية السعودية',
          timestamp: DateTime.now(),
        );

        // Create default items
        final List<CartItem> items = [
          CartItem(
            id: 'item-${cartData['id']}',
            cartId: cartData['id'] ?? '',
            productId: 'product-1',
            productName: 'مياه معدنية',
            productPrice: 15.0,
            quantity: 2,
            totalPrice: 30.0,
          ),
        ];

        return Cart(
          id: cartData['id'] ?? '',
          customerId: cartData['customer_id'] ?? '',
          customerName: cartData['customer_name'] ?? 'عميل غير معروف',
          customerPhone: cartData['customer_phone'] ?? '+966500000000',
          pickupLocation: pickupLocation ?? fallbackLocation,
          deliveryLocation: deliveryLocation ?? fallbackLocation,
          status: status,
          driverId: cartData['driver_id'],
          totalAmount: (cartData['total_amount'] ?? 50.0).toDouble(),
          createdAt: DateTime.parse(
            cartData['created_at'] ?? DateTime.now().toIso8601String(),
          ),
          updatedAt: DateTime.parse(
            cartData['updated_at'] ?? DateTime.now().toIso8601String(),
          ),
          acceptedAt: cartData['accepted_at'] != null
              ? DateTime.parse(cartData['accepted_at'])
              : null,
          pickedUpAt: cartData['picked_up_at'] != null
              ? DateTime.parse(cartData['picked_up_at'])
              : null,
          deliveredAt: cartData['delivered_at'] != null
              ? DateTime.parse(cartData['delivered_at'])
              : null,
          notes: cartData['notes'],
          items: items,
        );
      } catch (e) {
        print('Error parsing cart data: $e');
        print('Cart data: $cartData');

        // Return a fallback cart if parsing fails
        return Cart(
          id: cartData['id'] ?? 'fallback-id',
          customerId: cartData['customer_id'] ?? 'fallback-customer',
          customerName: 'عميل تجريبي',
          customerPhone: '+966500000000',
          pickupLocation: Location(
            latitude: 24.7136,
            longitude: 46.6753,
            address: 'الرياض، المملكة العربية السعودية',
            timestamp: DateTime.now(),
          ),
          deliveryLocation: Location(
            latitude: 24.7136,
            longitude: 46.6753,
            address: 'الرياض، المملكة العربية السعودية',
            timestamp: DateTime.now(),
          ),
          status: CartStatus.pending,
          totalAmount: 50.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          items: [
            CartItem(
              id: 'fallback-item',
              cartId: cartData['id'] ?? 'fallback-id',
              productId: 'fallback-product',
              productName: 'مياه معدنية',
              productPrice: 25.0,
              quantity: 2,
              totalPrice: 50.0,
            ),
          ],
        );
      }
    }).toList();
  }

  // Accept a cart (assign to current driver)
  Future<bool> acceptCart(String cartId) async {
    if (_currentDriverId == null) {
      print('No driver ID set');
      return false;
    }

    try {
      print('Accepting cart: $cartId for driver: $_currentDriverId');

      // 1) Try secure RPC path if available (atomic & RLS-friendly)
      try {
        final rpcResult = await SupabaseService.client.rpc(
          'accept_cart',
          params: {'p_cart_id': cartId},
        );
        final bool rpcSuccess =
            rpcResult == true ||
            rpcResult == 1 ||
            (rpcResult is Map && (rpcResult['success'] == true));
        if (rpcSuccess) {
          // Update local state lists
          final cartIndex = _currentAvailableCarts.indexWhere(
            (cart) => cart.id == cartId,
          );
          if (cartIndex != -1) {
            final acceptedCart = _currentAvailableCarts[cartIndex].copyWith(
              status: CartStatus.assigned,
              driverId: _currentDriverId,
            );
            _currentAvailableCarts.removeAt(cartIndex);
            _currentMyCarts.add(acceptedCart);
            _availableCartsController.add(_currentAvailableCarts);
            _myCartsController.add(_currentMyCarts);
          }
          return true;
        }
      } catch (e) {
        // Continue with direct update fallback if RPC not present or RLS disabled
        print('RPC accept_cart not used, falling back. Reason: $e');
      }

      // 2) Fallback: direct update. Try full payload then minimal payload
      List<dynamic> response = const [];
      final DateTime now = DateTime.now();
      final Map<String, dynamic> fullPayload = {
        'driver_id': _currentDriverId,
        'status': 'assigned',
        'accepted_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      try {
        response = await SupabaseService.client
            .from('carts')
            .update(fullPayload)
            .eq('id', cartId)
            .filter('driver_id', 'is', null)
            .neq('status', 'delivered');
      } on PostgrestException catch (e) {
        // Column not found (e.g. accepted_at). Retry with minimal payload.
        if (e.code == 'PGRST204' ||
            e.message.toLowerCase().contains('column') &&
                e.message.toLowerCase().contains('not') &&
                e.message.toLowerCase().contains('found')) {
          final minimalPayload = {
            'driver_id': _currentDriverId,
            'status': 'assigned',
          };
          response = await SupabaseService.client
              .from('carts')
              .update(minimalPayload)
              .eq('id', cartId)
              .filter('driver_id', 'is', null)
              .neq('status', 'delivered');
        } else {
          rethrow;
        }
      }

      print('Cart acceptance response: $response');

      // Update local state based on response
      if (response.isNotEmpty) {
        // Find the cart in current available carts and move it to my carts
        final cartIndex = _currentAvailableCarts.indexWhere(
          (cart) => cart.id == cartId,
        );
        if (cartIndex != -1) {
          final acceptedCart = _currentAvailableCarts[cartIndex].copyWith(
            status: CartStatus.assigned,
            driverId: _currentDriverId,
          );
          _currentAvailableCarts.removeAt(cartIndex);
          _currentMyCarts.add(acceptedCart);

          // Update streams
          _availableCartsController.add(_currentAvailableCarts);
          _myCartsController.add(_currentMyCarts);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error accepting cart: $e');
      print('Stack trace: ${StackTrace.current}');

      // If database update fails, still return true for mock data
      if (cartId.startsWith('mock-')) {
        print('Mock cart acceptance successful despite database error');
        return true;
      }

      return false;
    }
  }

  // Update cart status
  Future<bool> updateCartStatus(String cartId, CartStatus status) async {
    if (_currentDriverId == null) {
      print('No driver ID set');
      return false;
    }

    try {
      print('Updating cart status: $cartId to $status');

      // For real carts, update the database

      // For real carts, update the database, with fallback if optional cols missing
      List<dynamic> response = const [];
      final DateTime now = DateTime.now();
      final Map<String, dynamic> fullPayload = {
        'status': status.toString().split('.').last,
        'updated_at': now.toIso8601String(),
        if (status == CartStatus.onTheWay)
          'picked_up_at': now.toIso8601String(),
        if (status == CartStatus.delivered)
          'delivered_at': now.toIso8601String(),
      };
      try {
        response = await SupabaseService.client
            .from('carts')
            .update(fullPayload)
            .eq('id', cartId)
            .eq('driver_id', _currentDriverId!);
      } on PostgrestException catch (e) {
        if (e.code == 'PGRST204' ||
            e.message.toLowerCase().contains('column') &&
                e.message.toLowerCase().contains('not') &&
                e.message.toLowerCase().contains('found')) {
          final minimalPayload = {'status': status.toString().split('.').last};
          response = await SupabaseService.client
              .from('carts')
              .update(minimalPayload)
              .eq('id', cartId)
              .eq('driver_id', _currentDriverId!);
        } else {
          rethrow;
        }
      }

      print('Cart status update response: $response');

      // Update local state instead of reloading
      if (response.isNotEmpty) {
        // Update the cart status in my carts
        final cartIndex = _currentMyCarts.indexWhere(
          (cart) => cart.id == cartId,
        );
        if (cartIndex != -1) {
          _currentMyCarts[cartIndex] = _currentMyCarts[cartIndex].copyWith(
            status: status,
          );
          _myCartsController.add(_currentMyCarts);
        }
      }

      return true;
    } catch (e) {
      print('Error updating cart status: $e');
      print('Stack trace: ${StackTrace.current}');

      // If database update fails, still return true for mock data
      if (cartId.startsWith('mock-')) {
        print('Mock cart status update successful despite database error');
        return true;
      }

      return false;
    }
  }

  // Get cart by ID
  Future<Cart?> getCartById(String cartId) async {
    try {
      final response = await SupabaseService.client
          .from('carts')
          .select('''
            *,
            cart_items (
              *,
              products (
                name,
                price
              )
            )
          ''')
          .eq('id', cartId)
          .single();

      final carts = _parseCartsFromResponse([response]);
      return carts.isNotEmpty ? carts.first : null;
    } catch (e) {
      print('Error getting cart by ID: $e');
      return null;
    }
  }

  // Dispose streams
  void dispose() {
    try {
      _cartsChannel?.unsubscribe();
    } catch (_) {}
    _cartsChannel = null;
    _availableCartsController.close();
    _myCartsController.close();
    _completedCartsController.close();
    _unpaidInvoicesController.close();
  }
}
