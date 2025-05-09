class GameEventBus {
  static final GameEventBus _instance = GameEventBus._internal();
  factory GameEventBus() => _instance;
  GameEventBus._internal();

  final _listeners = <String, List<Function>>{}; 

  void emit(String event, [dynamic data]) {
    if (_listeners.containsKey(event)) {
      for (var listener in _listeners[event]!) {
        listener(data);
      }
    }
  }

  void on(String event, Function callback) {
    _listeners[event] ??= [];
    _listeners[event]!.add(callback);
  }

  void off(String event, Function callback) {
    _listeners[event]?.remove(callback);
  }
}