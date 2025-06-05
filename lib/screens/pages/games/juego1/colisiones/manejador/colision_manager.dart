import '../../../../../../dependencias/imports.dart';

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

class ColisionManager {
  final Player player;
  final Mapa1 mapa;
  double worldOffset;

  final ColisionSuelo _colisionSuelo = ColisionSuelo();
  final ColisionItem _colisionItem = ColisionItem();
  final ColisionCasa _colisionCasa = ColisionCasa();
  final GameEventBus _eventBus = GameEventBus(); // Ya es singleton por diseño

  ColisionManager(this.player, this.mapa, this.worldOffset);

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

  List<dynamic> _getObjetosCercanos() {
    final rangoDeteccion = 500.0; // Aumentado de 300.0 a 500.0
    final playerPosX = player.x + worldOffset;

    return mapa.objetos.where((objeto) {
      if (objeto is! Suelo && objeto is! Suelo2) return false;

      final objetoPosX = objeto.x;
      final distanciaX = (playerPosX - objetoPosX).abs();
      return distanciaX <= rangoDeteccion;
    }).toList();
  }

  double _checkGroundLevel(List<dynamic> objetosCercanos) {
    return _colisionSuelo.obtenerAltura(player, objetosCercanos, worldOffset);
  }

  bool _checkHouseCollision() {
    for (var casa in mapa.casas) {
      if (_colisionCasa.verificar(player, casa, worldOffset)) {
        return true;
      }
    }
    return false;
  }

  List<MonedaBase> _checkCoinCollisions() {
    return mapa.monedas
        .where((moneda) =>
            !moneda.isCollected &&
            _colisionItem.verificar(player, moneda, worldOffset))
        .toList();
  }

  bool _checkVoidCollision(double groundLevel) {
    // Verificar si el jugador ha caído fuera de los límites de la pantalla
    if (player.y > 800) { // Ajustar este valor según la altura de tu pantalla
      return true;
    }
    
    // Verificar caída al vacío normal
    if (groundLevel == double.infinity) {
      // Verificar si el jugador está cayendo y ha caído más allá de un umbral
      return player.velocidadVertical > 0 && player.y > 400; // Ajustar este valor según sea necesario
    }
    
    // Aumentar el margen para evitar falsos positivos
    return player.y > groundLevel + player.size * 0.8 && player.velocidadVertical > 0;
  }

  void updateWorldOffset(double newOffset) {
    worldOffset = newOffset;
  }
}
