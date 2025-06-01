import '../../../../../../dependencias/imports.dart';

class CollisionResult {
  final double groundLevel;
  final bool isCollidingWithHouse;
  final List<MonedaBase> collidingCoins;
  final bool isInVoid;

  CollisionResult({
    required this.groundLevel,
    required this.isCollidingWithHouse,
    required this.collidingCoins,
    required this.isInVoid,
  });
}

class ColisionManager {
  final Player player;
  final Mapa1 mapa;
  double worldOffset;

  final ColisionSuelo _colisionSuelo = ColisionSuelo();
  final ColisionItem _colisionItem = ColisionItem();
  final ColisionCasa _colisionCasa = ColisionCasa();

  ColisionManager(this.player, this.mapa, this.worldOffset);

  CollisionResult checkCollisions() {
    final objetosCercanos = _getObjetosCercanos();
    final groundLevel = _checkGroundLevel(objetosCercanos);

    return CollisionResult(
      groundLevel: groundLevel,
      isCollidingWithHouse: _checkHouseCollision(),
      collidingCoins: _checkCoinCollisions(),
      isInVoid: _checkVoidCollision(groundLevel),
    );
  }

  
  List<dynamic> _getObjetosCercanos() {
    // Reducir el rango de detección para una respuesta más rápida
    final rangoDeteccion = 200.0;
    
    // Obtener la posición del jugador ajustada al worldOffset
    final playerPosX = player.x + worldOffset;
    
    // Filtrar objetos que estén dentro del rango de detección
    return mapa.objetos.where((objeto) {
      // Verificar si es un objeto con el que podemos colisionar
      if (objeto is! Suelo && objeto is! Suelo2) return false;
      
      // Calcular la distancia horizontal entre el jugador y el objeto
      final objetoPosX = objeto.x;
      final distanciaX = (playerPosX - objetoPosX).abs();
      
      // Devolver true si el objeto está dentro del rango de detección
      return distanciaX <= rangoDeteccion;
    }).toList();
  }


  double _checkGroundLevel(List<dynamic> objetosCercanos) {
    List<double> alturas = [];

    final alturaSuelo = _colisionSuelo.obtenerAltura(
      player,
      objetosCercanos,
      worldOffset,  // Añadir worldOffset como parámetro
    );
    if (alturaSuelo != double.infinity) alturas.add(alturaSuelo);

    if (alturas.isEmpty) return double.infinity;

    // Elegir la altura más baja que esté justo debajo del jugador
    return alturas.reduce((a, b) => a < b ? a : b);
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
        .where(
          (moneda) =>
              !moneda.isCollected &&
              _colisionItem.verificar(player, moneda, worldOffset),
        )
        .toList();
  }

  bool _checkVoidCollision(double groundLevel) {
    return player.y > groundLevel + player.size * 0.5;
  }

  void updateWorldOffset(double newOffset) {
    worldOffset = newOffset;
  }
}
