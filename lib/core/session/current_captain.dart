import '../../models/delivery_captain.dart';

class CurrentCaptain {
  static DeliveryCaptain? _captain;

  static DeliveryCaptain? get value => _captain;
  static set value(DeliveryCaptain? c) => _captain = c;

  static bool get isLoggedIn => _captain != null;
  static void signOut() => _captain = null;
}
