import 'package:flutter/material.dart';

// Events
abstract class AppEvent {}

class SetCurrentIndexEvent extends AppEvent {
  final int index;
  SetCurrentIndexEvent(this.index);
}

class UpdateCartItemCountEvent extends AppEvent {
  final int count;
  UpdateCartItemCountEvent(this.count);
}

class UpdateOnlineStatusEvent extends AppEvent {
  final bool isOnline;
  UpdateOnlineStatusEvent(this.isOnline);
}

class SetDarkModeEvent extends AppEvent {
  final bool isDark;
  SetDarkModeEvent(this.isDark);
}

// States
abstract class AppState {}

class AppInitialState extends AppState {}

class AppLoadedState extends AppState {
  final int currentIndex;
  final int cartItemCount;
  final bool isOnline;
  final int pendingOrdersCount;
  final int activeOrdersCount;
  final bool isDarkMode;

  AppLoadedState({
    required this.currentIndex,
    this.cartItemCount = 0,
    this.isOnline = true,
    this.pendingOrdersCount = 0,
    this.activeOrdersCount = 0,
    this.isDarkMode = false,
  });

  AppLoadedState copyWith({
    int? currentIndex,
    int? cartItemCount,
    bool? isOnline,
    int? pendingOrdersCount,
    int? activeOrdersCount,
    bool? isDarkMode,
  }) {
    return AppLoadedState(
      currentIndex: currentIndex ?? this.currentIndex,
      cartItemCount: cartItemCount ?? this.cartItemCount,
      isOnline: isOnline ?? this.isOnline,
      pendingOrdersCount: pendingOrdersCount ?? this.pendingOrdersCount,
      activeOrdersCount: activeOrdersCount ?? this.activeOrdersCount,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

// Bloc
class AppBloc extends ChangeNotifier {
  AppState _state = AppInitialState();
  AppState get state => _state;

  // Current state values
  int _currentIndex = 2; // Default to home (index 2)
  int _cartItemCount = 0;
  bool _isOnline = true;
  int _pendingOrdersCount = 0;
  int _activeOrdersCount = 0;
  bool _isDarkMode = false;

  // Getters
  int get currentIndex => _currentIndex;
  int get cartItemCount => _cartItemCount;
  bool get isOnline => _isOnline;
  int get pendingOrdersCount => _pendingOrdersCount;
  int get activeOrdersCount => _activeOrdersCount;
  bool get isDarkMode => _isDarkMode;

  void add(AppEvent event) {
    if (event is SetCurrentIndexEvent) {
      _currentIndex = event.index;
      _updateState();
    } else if (event is UpdateCartItemCountEvent) {
      _cartItemCount = event.count;
      _updateState();
    } else if (event is UpdateOnlineStatusEvent) {
      _isOnline = event.isOnline;
      _updateState();
    } else if (event is SetDarkModeEvent) {
      _isDarkMode = event.isDark;
      _updateState();
    }
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    _updateState();
  }

  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    _updateState();
  }

  void updateOrdersCount({int? pending, int? active}) {
    if (pending != null) _pendingOrdersCount = pending;
    if (active != null) _activeOrdersCount = active;
    _updateState();
  }

  void _updateState() {
    _state = AppLoadedState(
      currentIndex: _currentIndex,
      cartItemCount: _cartItemCount,
      isOnline: _isOnline,
      pendingOrdersCount: _pendingOrdersCount,
      activeOrdersCount: _activeOrdersCount,
      isDarkMode: _isDarkMode,
    );
    notifyListeners();
  }
}
