/// Sistema de eventos del juego implementado como Singleton.
///
/// Permite la comunicación entre componentes del juego mediante un patrón
/// publicador/suscriptor (pub/sub). Los componentes pueden emitir eventos
/// y suscribirse a eventos emitidos por otros componentes.
class GameEventBus {
  static final GameEventBus _instance = GameEventBus._internal();
  factory GameEventBus() => _instance;
  GameEventBus._internal();

  final _listeners = <String, List<Function>>{};

  /// Emite un evento con datos opcionales a todos los suscriptores.
  ///
  /// @param event Nombre del evento a emitir.
  /// @param data Datos opcionales asociados al evento.
  void emit(String event, [dynamic data]) {
    if (_listeners.containsKey(event)) {
      for (var listener in _listeners[event]!) {
        listener(data);
      }
    }
  }

  /// Suscribe una función callback a un evento específico.
  ///
  /// @param event Nombre del evento al que suscribirse.
  /// @param callback Función que se ejecutará cuando se emita el evento.
  void on(String event, Function callback) {
    _listeners[event] ??= [];
    _listeners[event]!.add(callback);
  }

  /// Elimina una suscripción específica a un evento.
  ///
  /// @param event Nombre del evento.
  /// @param callback Función callback a eliminar de los suscriptores.
  void off(String event, Function callback) {
    _listeners[event]?.remove(callback);
  }

  /// Elimina todas las suscripciones a un evento específico.
  ///
  /// @param event Nombre del evento del que eliminar todos los suscriptores.
  void offAll(String event) {
    _listeners.remove(event);
  }

  /// Limpia todas las suscripciones a todos los eventos.
  ///
  /// Útil para liberar recursos cuando el juego finaliza.
  void dispose() {
    _listeners.clear();
  }
}
