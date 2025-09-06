import '../config/mapbox_config.dart';

/// Lightweight access point for map-related configuration.
class MapService {
  static String get accessToken => MapboxConfig.accessToken;
}
