import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart' as gl;
import '../../core/config/mapbox_config.dart';
import '../../core/design_system/design_system.dart';
import '../../data/repositories/customers_repository.dart';
import '../../data/repositories/orders_repository.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.customerPhone, this.orderId});

  final String? customerPhone; // if provided, focus tracking on this phone
  final String? orderId; // optional, for UI display only

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  mbx.MapboxMap? _mapboxMap;
  bool _showMap = false; // defer heavy MapWidget to next frame
  final _customersRepo = CustomersRepository();
  final _ordersRepo = OrdersRepository();
  String? _customerAddress; // fetched from customers table
  mbx.PointAnnotationManager? _customerAnnMgr;
  mbx.PointAnnotation? _customerAnn;
  mbx.PolylineAnnotationManager? _routeAnnMgr;
  mbx.PolylineAnnotation? _routeAnn;
  double? _custLat;
  double? _custLng;
  bool _follow = false; // camera follow toggle
  StreamSubscription<gl.Position>? _followPosSub;

  // Default camera over Riyadh, SA
  static final mbx.Point _defaultCenter =
      mbx.Point(coordinates: mbx.Position(46.6753, 24.7136));
  static const double _defaultZoom = 12.0;
  static const String _customStyle =
      'mapbox://styles/yasser2030/cmf15su7z00c501pl4r29cvvw';

  Future<void> _onMapCreated(mbx.MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    // Initial camera (token is provided natively via AndroidManifest/Info.plist)
    await _mapboxMap!.setCamera(
      mbx.CameraOptions(center: _defaultCenter, zoom: _defaultZoom),
    );
    // Tweak gestures for responsiveness
    await _mapboxMap!.gestures.updateSettings(
      mbx.GesturesSettings(
        rotateEnabled: true,
        pinchToZoomEnabled: true,
        quickZoomEnabled: true,
        scrollEnabled: true,
  simultaneousRotateAndPinchToZoomEnabled: true,
  pitchEnabled: true,
      ),
    );

    // Enable default blue puck for the driver location
    await _mapboxMap!.location.updateSettings(
      mbx.LocationComponentSettings(
        enabled: true,
      ),
    );

  // Center once on current user. Camera will not auto-follow; user can tap the button to re-center.
  await _centerOnUser();

  // Try to fetch provided phone first, else latest order, then resolve customer address
  _prefetchCustomerAddress();
  }

  @override
  void initState() {
    super.initState();
    // Set token once from Dart to avoid any native lookup cost.
    // Safe even if also provided natively.
    mbx.MapboxOptions.setAccessToken(MapboxConfig.accessToken);
    // Defer MapWidget creation to avoid jank during navigation transition.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _showMap = true);
    });
  }

  Future<void> _zoomDelta(double delta) async {
  if (_mapboxMap == null) return;
  final state = await _mapboxMap!.getCameraState();
  final z = (state.zoom) + delta;
  await _mapboxMap!.setCamera(mbx.CameraOptions(zoom: z));
  }

  Future<void> _centerOnUser() async {
    if (_mapboxMap == null) return;
    gl.LocationPermission perm = await gl.Geolocator.checkPermission();
    if (perm == gl.LocationPermission.denied || perm == gl.LocationPermission.deniedForever) {
      perm = await gl.Geolocator.requestPermission();
      if (perm == gl.LocationPermission.denied || perm == gl.LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى منح إذن الموقع')), 
        );
        return;
      }
    }
    if (!await gl.Geolocator.isLocationServiceEnabled()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فعّل خدمات الموقع على جهازك')), 
      );
      return;
    }
  final pos = await gl.Geolocator.getCurrentPosition();
  await _mapboxMap!.setCamera(
      mbx.CameraOptions(
        center: mbx.Point(coordinates: mbx.Position(pos.longitude, pos.latitude)),
        zoom: 14,
      ),
    );
  }

  // Camera is intentionally decoupled from the location puck (no continuous follow).

  Future<void> _prefetchCustomerAddress() async {
    try {
      // Prefer an explicitly provided customer phone, else fall back to latest order
      String? phone = widget.customerPhone;
      if (phone == null || phone.isEmpty) {
        final orders = await _ordersRepo.getMyAssignedOrders(limit: 1);
        if (orders.isNotEmpty) {
          phone = orders.first['customerPhone']?.toString();
        }
      }

      if (phone != null && phone.isNotEmpty) {
        final c = await _customersRepo.getModelByPhone(phone);
        if (c != null && mounted) {
          setState(() {
            _customerAddress = c.address;
          });
          if (c.lat != null && c.lng != null) {
            await _mapboxMap?.setCamera(mbx.CameraOptions(
              center: mbx.Point(coordinates: mbx.Position(c.lng!, c.lat!)),
              zoom: 14,
            ));
            await _showCustomerMarker(c.lat!, c.lng!);
            _custLat = c.lat;
            _custLng = c.lng;
            await _updateRouteToCustomer();
          } else if ((c.address ?? '').isNotEmpty) {
            final pos = await _geocodeAddress(c.address!);
            if (pos != null) {
              await _mapboxMap?.setCamera(mbx.CameraOptions(
                center: mbx.Point(coordinates: mbx.Position(pos.$2, pos.$1)),
                zoom: 14,
              ));
              await _showCustomerMarker(pos.$1, pos.$2);
              _custLat = pos.$1;
              _custLng = pos.$2;
              await _updateRouteToCustomer();
            }
          }
        }
      }
    } catch (_) {
      // ignore errors silently for now
    }
  }

  // Returns (lat, lng) if found
  Future<(double, double)?> _geocodeAddress(String address) async {
    try {
      final token = MapboxConfig.accessToken;
      if (token.isEmpty) return null;
      final url = Uri.parse(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(address)}.json?access_token=$token&limit=1&language=ar');
      final res = await http.get(url);
      if (res.statusCode != 200) return null;
      final data = json.decode(res.body) as Map<String, dynamic>;
      final feats = (data['features'] as List?) ?? const [];
      if (feats.isEmpty) return null;
      final first = feats.first as Map<String, dynamic>;
      final center = (first['center'] as List?)?.cast<num>();
      if (center == null || center.length < 2) return null;
      final lng = center[0].toDouble();
      final lat = center[1].toDouble();
      return (lat, lng);
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureCustomerAnnMgr() async {
    if (_mapboxMap == null) return;
    _customerAnnMgr ??= await _mapboxMap!.annotations.createPointAnnotationManager();
  }

  Future<void> _showCustomerMarker(double lat, double lng) async {
    if (_mapboxMap == null) return;
    await _ensureCustomerAnnMgr();
    if (_customerAnnMgr == null) return;
    // Build marker image once
    final bytes = await _buildCustomerPin();
    final opts = mbx.PointAnnotationOptions(
      geometry: mbx.Point(coordinates: mbx.Position(lng, lat)),
      image: bytes,
      iconSize: 1.0,
    );
    // Update or create (recreate for simplicity)
    if (_customerAnn != null) {
      await _customerAnnMgr!.delete(_customerAnn!);
    }
    _customerAnn = await _customerAnnMgr!.create(opts);
  }

  Future<Uint8List> _buildCustomerPin({int size = 72}) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..isAntiAlias = true;

    final w = size.toDouble();
    final h = size.toDouble();
    final center = ui.Offset(w / 2, h / 2);
    final radius = w * 0.28;

    // Drop-shadow
    paint
      ..color = const ui.Color(0x33000000)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6);
    canvas.drawCircle(center.translate(0, 2), radius, paint);

    // Pin body
    paint
      ..maskFilter = null
      ..color = const ui.Color(0xFFE53935);
    canvas.drawCircle(center, radius, paint);

    // White border
    paint
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const ui.Color(0xFFFFFFFF);
    canvas.drawCircle(center, radius, paint);

    // Inner dot
    paint
      ..style = ui.PaintingStyle.fill
      ..color = const ui.Color(0xFFFFFFFF);
    canvas.drawCircle(center, radius * 0.35, paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size, size);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // (driver uses default blue puck; no custom driver marker)

  Future<void> _ensureRouteAnnMgr() async {
    if (_mapboxMap == null) return;
    _routeAnnMgr ??= await _mapboxMap!.annotations.createPolylineAnnotationManager();
  }

  Future<void> _showRouteLine(List<mbx.Position> positions) async {
    if (_mapboxMap == null) return;
    await _ensureRouteAnnMgr();
    if (_routeAnnMgr == null) return;
    final line = mbx.LineString(coordinates: positions);
    final opts = mbx.PolylineAnnotationOptions(
      geometry: line,
      lineWidth: 5.0,
      lineColor: 0xFF1E88E5,
      lineOpacity: 0.85,
    );
    if (_routeAnn != null) {
      await _routeAnnMgr!.delete(_routeAnn!);
    }
    _routeAnn = await _routeAnnMgr!.create(opts);
  }

  Future<void> _updateRouteToCustomer() async {
    if (_custLat == null || _custLng == null) return;
    try {
      final p = await gl.Geolocator.getCurrentPosition();
      final route = await _fetchDirections(
        fromLat: p.latitude,
        fromLng: p.longitude,
        toLat: _custLat!,
        toLng: _custLng!,
      );
      if (route != null && route.isNotEmpty) {
        await _showRouteLine(route);
      }
      _startRouteUpdateStream();
    } catch (_) {
      // ignore
    }
  }

  StreamSubscription<gl.Position>? _routePosSub;
  void _startRouteUpdateStream() {
    _routePosSub ??= gl.Geolocator.getPositionStream(
      locationSettings: const gl.LocationSettings(
        accuracy: gl.LocationAccuracy.best,
        distanceFilter: 25,
      ),
    ).listen((p) async {
      if (_custLat == null || _custLng == null) return;
      final route = await _fetchDirections(
        fromLat: p.latitude,
        fromLng: p.longitude,
        toLat: _custLat!,
        toLng: _custLng!,
      );
      if (route != null && route.isNotEmpty) {
        await _showRouteLine(route);
      }
      if (_follow && _mapboxMap != null) {
        try {
          final cs = await _mapboxMap!.getCameraState();
          await _mapboxMap!.setCamera(
            mbx.CameraOptions(
              center: mbx.Point(
                coordinates: mbx.Position(p.longitude, p.latitude),
              ),
              bearing: (p.heading >= 0) ? p.heading : cs.bearing,
              zoom: cs.zoom, // preserve current zoom
            ),
          );
        } catch (_) {}
      }
    });
  }

  void _toggleFollow() async {
    final newVal = !_follow;
    setState(() => _follow = newVal);
    if (newVal) {
      // Snap camera to current user immediately when enabling follow
      try {
        final pos = await gl.Geolocator.getCurrentPosition();
        await _mapboxMap?.setCamera(
          mbx.CameraOptions(
            center: mbx.Point(
              coordinates: mbx.Position(pos.longitude, pos.latitude),
            ),
            zoom: 16.0,
            pitch: 45.0,
            bearing: pos.heading >= 0 ? pos.heading : null,
          ),
        );
      } catch (_) {}
      _startFollowStream();
    } else {
      _stopFollowStream();
    }
  }

  void _startFollowStream() {
    _followPosSub?.cancel();
    _followPosSub = gl.Geolocator.getPositionStream(
      locationSettings: const gl.LocationSettings(
        accuracy: gl.LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((p) async {
      if (!_follow || _mapboxMap == null) return;
      try {
        final cs = await _mapboxMap!.getCameraState();
        final targetZoom = _zoomForSpeed(p.speed);
        final smoothZoom = cs.zoom + (targetZoom - cs.zoom) * 0.2;
        await _mapboxMap!.setCamera(
          mbx.CameraOptions(
            center: mbx.Point(coordinates: mbx.Position(p.longitude, p.latitude)),
            bearing: (p.heading >= 0) ? p.heading : cs.bearing,
            pitch: 45.0,
            zoom: smoothZoom,
          ),
        );
      } catch (_) {}
    });
  }

  void _stopFollowStream() {
    _followPosSub?.cancel();
    _followPosSub = null;
  }

  double _zoomForSpeed(double speedMetersPerSec) {
    final s = speedMetersPerSec.isNaN ? 0.0 : speedMetersPerSec;
    if (s < 1.0) return 16.5;        // walking / idle
    if (s < 5.0) return 16.0;        // city slow
    if (s < 15.0) return 15.5;       // urban driving
    if (s < 25.0) return 15.0;       // fast urban
    return 14.5;                      // highway
  }

  // Fetch a route polyline from Mapbox Directions API and return positions as [lng, lat]
  Future<List<mbx.Position>?> _fetchDirections({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final token = MapboxConfig.accessToken;
      if (token.isEmpty) return null;
      final url = Uri.parse(
          'https://api.mapbox.com/directions/v5/mapbox/driving-traffic/'
          '$fromLng,$fromLat;$toLng,$toLat?geometries=geojson&overview=full&language=ar&access_token=$token');
      final res = await http.get(url);
      if (res.statusCode != 200) return null;
      final data = json.decode(res.body) as Map<String, dynamic>;
      final routes = (data['routes'] as List?) ?? const [];
      if (routes.isEmpty) return null;
      final geom = (routes.first as Map<String, dynamic>)['geometry'] as Map<String, dynamic>?;
      final coords = (geom?['coordinates'] as List?)?.cast<List?>();
      if (coords == null || coords.isEmpty) return null;
      return [
        for (final c in coords)
          if (c != null && c.length >= 2)
            mbx.Position((c[0] as num).toDouble(), (c[1] as num).toDouble()),
      ];
    } catch (_) {
      return null;
    }
  }
  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? DesignSystem.darkBackground
            : DesignSystem.background,
        body: SafeArea(
          child: Stack(
            children: [
              // ========== Mapbox Map ==========
              Positioned.fill(
                child: _showMap
                    ? mbx.MapWidget(
                        key: const ValueKey('mapbox_map'),
                        cameraOptions: mbx.CameraOptions(
                            center: _defaultCenter, zoom: _defaultZoom),
                        styleUri: _customStyle,
                        onMapCreated: _onMapCreated,
                      )
                    : const SizedBox.shrink(),
              ),

              // Simple top-right title
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    'تتبع الطلب',
                    style: DesignSystem.headlineLarge.copyWith(
                      color: isDark
                          ? DesignSystem.textInverse
                          : DesignSystem.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              // Customer address chip (from customers table) if available
              if (_customerAddress != null && _customerAddress!.isNotEmpty)
                Positioned(
                  top: 64,
                  left: 16,
                  right: 16,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? DesignSystem.darkSurface : DesignSystem.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _customerAddress!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Header removed per request (no gradient, no location icon, no online chip)

              // ========== Floating Controls ==========
              Positioned(
                bottom: 100,
                right: 16,
                child: RepaintBoundary(
                  child: Column(
                    children: [
                      _mapActionButton(
                        icon: _follow ? Icons.gps_fixed : Icons.gps_not_fixed,
                        onTap: _toggleFollow,
                        color: isDark
                            ? DesignSystem.darkSurface
                            : DesignSystem.surface,
                        iconColor: _follow ? DesignSystem.primary : Colors.white,
                      ),
                      const SizedBox(height: 16),
                      _mapActionButton(
                        icon: Icons.my_location,
                        onTap: _centerOnUser,
                        color: isDark
                            ? DesignSystem.darkSurface
                            : DesignSystem.surface,
                        iconColor: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      _mapActionButton(
                        icon: Icons.add,
                        onTap: () => _zoomDelta(1.0),
                        color: isDark
                            ? DesignSystem.darkSurface
                            : DesignSystem.surface,
                        iconColor: DesignSystem.primary,
                      ),
                      const SizedBox(height: 16),
                      _mapActionButton(
                        icon: Icons.remove,
                        onTap: () => _zoomDelta(-1.0),
                        color: isDark
                            ? DesignSystem.darkSurface
                            : DesignSystem.surface,
                        iconColor: DesignSystem.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    Color? iconColor,
  Gradient? backgroundGradient,
  }) {
    return Material(
      shape: const CircleBorder(),
      color: Colors.transparent,
      elevation: 0, // remove shadow to reduce overdraw
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundGradient == null
                ? (color ?? DesignSystem.surface)
                : null,
            gradient: backgroundGradient,
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor ?? DesignSystem.primary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  // (old placeholder helpers removed)
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
  _customerAnnMgr?.deleteAll();
  _routeAnnMgr?.deleteAll();
  _routePosSub?.cancel();
  _stopFollowStream();
    super.dispose();
  }
}
