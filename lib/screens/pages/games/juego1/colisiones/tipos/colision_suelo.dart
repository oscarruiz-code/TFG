import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class ColisionSuelo {
  // Método principal que verifica tanto colisiones verticales como laterales

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
            playerHitbox.bottom - sueloHitbox.top < 8) {  // Ajustado de 10 a 8
          player.y = sueloHitbox.top - playerHitbox.height / 2 - 1;  // Añadido -1 para separación adicional
          player.velocidadVertical = 0;
          player.isOnGround = true;
          colisionDetectada = true;
          GameEventBus().emit(GameEvents.playerLand);
        }

        // Colisión desde abajo (techo)
        if (playerHitbox.top < sueloHitbox.bottom &&
            playerHitbox.bottom > sueloHitbox.bottom &&
            sueloHitbox.bottom - playerHitbox.top < 10) {
          player.y = sueloHitbox.bottom + playerHitbox.height / 2 + 2;  // Aumentado de +1 a +2 para mayor separación
          player.velocidadVertical = 0;
          colisionDetectada = true;
          GameEventBus().emit(GameEvents.playerCollisionTop);
        }
      }
    }

    return colisionDetectada;
  }

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
