import '../../../../../../dependencias/imports.dart';

/// Clase que encapsula los resultados de la detección de colisiones.
///
/// Contiene información sobre el nivel del suelo, colisiones con casas,
/// monedas recolectadas, detección de vacío y colisiones verticales.
class CollisionResult {
  final double groundLevel;
  final bool isCollidingWithHouse;
  final List<MonedaBase> collidingCoins;
  final bool isInVoid;
  final bool isCollidingTop;
  final bool isCollidingBottom;

  CollisionResult({
    required this.groundLevel,
    required this.isCollidingWithHouse,
    required this.collidingCoins,
    required this.isInVoid,
    required this.isCollidingTop,
    required this.isCollidingBottom,
  });
}

/// Clase que gestiona todas las colisiones del juego.
///
/// Coordina la detección de colisiones entre el jugador y los diferentes elementos
/// del mapa (suelo, casas, monedas, vacío). Utiliza clases especializadas para cada
/// tipo de colisión y emite eventos cuando se detectan colisiones.
class ColisionManager {
  /// Referencia al jugador para detectar sus colisiones.
  final Player player;
  
  /// Referencia al mapa del juego que contiene los objetos colisionables.
  final Mapa1 mapa;
  
  /// Desplazamiento del mundo para ajustar las coordenadas de colisión.
  double worldOffset;
  
  /// Detector de colisiones con el suelo.
  final ColisionSuelo _colisionSuelo = ColisionSuelo();
  
  /// Detector de colisiones con items (monedas).
  final ColisionItem _colisionItem = ColisionItem();
  
  /// Detector de colisiones con casas.
  final ColisionCasa _colisionCasa = ColisionCasa();
  
  /// Bus de eventos para notificar colisiones detectadas.
  final GameEventBus _eventBus = GameEventBus();

  ColisionManager(this.player, this.mapa, this.worldOffset);

  /// Verifica todas las colisiones posibles y devuelve un objeto CollisionResult
  /// con la información de las colisiones detectadas.
  ///
  /// Emite eventos correspondientes a cada tipo de colisión detectada.
  CollisionResult checkCollisions() {
    final objetosCercanos = _getObjetosCercanos();
    final groundLevel = _checkGroundLevel(objetosCercanos);

    bool isCollidingTop = false;
    bool isCollidingBottom = false;

    bool colisionVerticalDetectada = _colisionSuelo.verificarVertical(
      player,
      objetosCercanos,
      worldOffset,
    );

    if (colisionVerticalDetectada) {
      if (player.velocidadVertical >= 0) isCollidingTop = true;
      if (player.velocidadVertical < 0) isCollidingBottom = true;
    }

    final isInVoid = _checkVoidCollision(groundLevel);
    final isCollidingWithHouse = _checkHouseCollision();
    final collidingCoins = _checkCoinCollisions();

    // Emitir eventos según colisiones detectadas
    if (isCollidingTop) _eventBus.emit(GameEvents.playerCollisionTop, {'groundLevel': groundLevel});
    if (isCollidingBottom) _eventBus.emit(GameEvents.playerCollisionBottom);
    if (isInVoid) _eventBus.emit(GameEvents.playerInVoid);
    if (isCollidingWithHouse) _eventBus.emit(GameEvents.playerCollisionWithHouse);
    for (var moneda in collidingCoins) {
      _eventBus.emit(GameEvents.coinCollected, moneda);
    }

    return CollisionResult(
      groundLevel: groundLevel,
      isCollidingWithHouse: isCollidingWithHouse,
      collidingCoins: collidingCoins,
      isInVoid: isInVoid,
      isCollidingTop: isCollidingTop,
      isCollidingBottom: isCollidingBottom,
    );
  }

  /// Obtiene los objetos cercanos al jugador para optimizar
  /// la detección de colisiones.
  ///
  /// @return Lista de objetos de tipo Suelo o Suelo2 dentro del rango de detección.
  List<dynamic> _getObjetosCercanos() {
    final rangoDeteccion = 500.0;
    final playerPosX = player.x + worldOffset;

    return mapa.objetos.where((objeto) {
      if (objeto is! Suelo && objeto is! Suelo2) return false;

      final objetoPosX = objeto.x;
      final distanciaX = (playerPosX - objetoPosX).abs();
      return distanciaX <= rangoDeteccion;
    }).toList();
  }

  /// Determina la altura del suelo más cercano bajo el jugador.
  ///
  /// @param objetosCercanos Lista de objetos cercanos al jugador.
  /// @return La altura del suelo más cercano o double.infinity si no hay suelo.
  double _checkGroundLevel(List<dynamic> objetosCercanos) {
    return _colisionSuelo.obtenerAltura(player, objetosCercanos, worldOffset);
  }

  /// Verifica si el jugador está colisionando con alguna casa.
  ///
  /// @return true si hay colisión con alguna casa, false en caso contrario.
  bool _checkHouseCollision() {
    for (var casa in mapa.casas) {
      if (_colisionCasa.verificar(player, casa, worldOffset)) {
        return true;
      }
    }
    return false;
  }

  /// Verifica colisiones con monedas y devuelve las monedas con las que
  /// el jugador ha colisionado.
  ///
  /// @return Lista de monedas con las que el jugador ha colisionado.
  List<MonedaBase> _checkCoinCollisions() {
    return mapa.monedas
        .where((moneda) =>
            !moneda.isCollected &&
            _colisionItem.verificar(player, moneda, worldOffset))
        .toList();
  }

  /// Verifica si el jugador ha caído al vacío.
  ///
  /// Considera tres casos:
  /// 1. El jugador ha caído fuera de los límites de la pantalla.
  /// 2. No hay suelo debajo del jugador (groundLevel es infinito).
  /// 3. El jugador está cayendo y está significativamente por debajo del nivel del suelo.
  ///
  /// @param groundLevel La altura del suelo más cercano.
  /// @return true si el jugador ha caído al vacío, false en caso contrario.
  bool _checkVoidCollision(double groundLevel) {
    // Verificar si el jugador ha caído fuera de los límites de la pantalla
    if (player.y > 800) {
      return true;
    }
    
    // Verificar caída al vacío normal
    if (groundLevel == double.infinity) {
      // Verificar si el jugador está cayendo y ha caído más allá de un umbral
      return player.velocidadVertical > 0 && player.y > 400; 
    }
    
    // Aumentar el margen para evitar falsos positivos
    return player.y > groundLevel + player.size * 0.8 && player.velocidadVertical > 0;
  }

  /// Actualiza el desplazamiento del mundo.
  ///
  /// @param newOffset El nuevo valor de desplazamiento.
  void updateWorldOffset(double newOffset) {
    worldOffset = newOffset;
  }
}
