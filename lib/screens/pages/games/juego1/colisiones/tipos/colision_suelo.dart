import 'package:oscarruizcode_pingu/dependencias/imports.dart';

/// Clase que gestiona la detección de colisiones entre el jugador y los elementos de suelo.
/// Proporciona métodos para verificar colisiones verticales y calcular alturas.
class ColisionSuelo {
  /// Verifica si existen colisiones verticales entre el jugador y los elementos de suelo.
  /// 
  /// Detecta dos tipos de colisiones:
  /// - Colisión desde arriba (jugador sobre suelo): Ajusta la posición del jugador y emite evento playerLand.
  /// - Colisión desde abajo (jugador contra techo): Ajusta la posición del jugador y emite evento playerCollisionTop.
  /// 
  /// Parámetros:
  /// - [player]: Objeto jugador con su hitbox en coordenadas de pantalla.
  /// - [suelos]: Lista de elementos de suelo para verificar colisiones.
  /// - [worldOffset]: Desplazamiento del mundo para ajustar la posición de los suelos.
  /// 
  /// Retorna [bool] indicando si se detectó alguna colisión.
  bool verificarVertical(Player player, List<dynamic> suelos, double worldOffset) {
    Rect playerHitbox = player.hitbox;
    bool colisionDetectada = false;

    for (var suelo in suelos) {
      Rect sueloHitbox = Rect.fromLTWH(
        suelo.hitbox.left - worldOffset,
        suelo.hitbox.top,
        suelo.hitbox.width,
        suelo.hitbox.height,
      );

      if (playerHitbox.overlaps(sueloHitbox)) {
        // Colisión desde arriba (suelo)
        if (playerHitbox.bottom > sueloHitbox.top &&
            playerHitbox.top < sueloHitbox.top &&
            playerHitbox.bottom - sueloHitbox.top < 8) {
          player.y = sueloHitbox.top - playerHitbox.height / 2 - 1;
          player.velocidadVertical = 0;
          player.isOnGround = true;
          colisionDetectada = true;
          GameEventBus().emit(GameEvents.playerLand);
        }

        // Colisión desde abajo (techo)
        if (playerHitbox.top < sueloHitbox.bottom &&
            playerHitbox.bottom > sueloHitbox.bottom &&
            sueloHitbox.bottom - playerHitbox.top < 10) {
          player.y = sueloHitbox.bottom + playerHitbox.height / 2 + 2;
          player.velocidadVertical = 0;
          colisionDetectada = true;
          GameEventBus().emit(GameEvents.playerCollisionTop);
        }
      }
    }

    return colisionDetectada;
  }

  /// Calcula la altura mínima del suelo debajo del jugador.
  /// 
  /// Útil para determinar la distancia al suelo más cercano cuando el jugador está en el aire.
  /// 
  /// Parámetros:
  /// - [player]: Objeto jugador con su hitbox en coordenadas de pantalla.
  /// - [suelos]: Lista de elementos de suelo para verificar.
  /// - [worldOffset]: Desplazamiento del mundo para ajustar la posición de los suelos.
  /// 
  /// Retorna [double] con la altura del suelo más cercano debajo del jugador.
  /// Si no hay suelo debajo, retorna double.infinity.
  double obtenerAltura(Player player, List<dynamic> suelos, double worldOffset) {
    double alturaMinima = double.infinity;
    Rect playerHitbox = player.hitbox;

    for (var suelo in suelos) {
      Rect sueloHitbox = Rect.fromLTWH(
        suelo.hitbox.left - worldOffset,
        suelo.hitbox.top,
        suelo.hitbox.width,
        suelo.hitbox.height,
      );

      if (playerHitbox.right > sueloHitbox.left &&
          playerHitbox.left < sueloHitbox.right) {
        if (sueloHitbox.top >= playerHitbox.bottom &&
            sueloHitbox.top < alturaMinima) {
          alturaMinima = sueloHitbox.top;
        }
      }
    }

    return alturaMinima;
  }
}
