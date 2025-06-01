import '../../../../../../dependencias/imports.dart';

class ColisionSuelo {
  bool verificar(Player player, List<dynamic> suelos, double worldOffset) {
    Rect playerHitbox = player.hitbox;

    for (var suelo in suelos) {
      Rect sueloHitbox = Rect.fromLTWH(
        suelo.hitbox.left - worldOffset,
        suelo.hitbox.top,
        suelo.hitbox.width,
        suelo.hitbox.height
      );
      
      if (playerHitbox.overlaps(sueloHitbox)) {
        double overlapTop = playerHitbox.bottom - sueloHitbox.top;
        double overlapBottom = sueloHitbox.bottom - playerHitbox.top;
        double overlapLeft = playerHitbox.right - sueloHitbox.left;
        double overlapRight = sueloHitbox.right - playerHitbox.left;

        double minOverlap = [overlapTop, overlapBottom, overlapLeft, overlapRight]
            .reduce((a, b) => a < b ? a : b);

        if (minOverlap == overlapTop && player.velocidadVertical >= 0) {
            // Colisión desde arriba
            player.y = sueloHitbox.top - playerHitbox.height / 2;
            player.velocidadVertical = 0;
            player.isOnGround = true;
            return true;
        } else {
            // Efecto de rebote
            final double fuerzaRebote = 5.0;
            
            if (minOverlap == overlapLeft) {
                // Colisión izquierda
                player.x = sueloHitbox.left - playerHitbox.width / 2;
                player.lastMoveDirection = -fuerzaRebote; // Rebote hacia la izquierda
            } else if (minOverlap == overlapRight) {
                // Colisión derecha
                player.x = sueloHitbox.right + playerHitbox.width / 2;
                player.lastMoveDirection = fuerzaRebote; // Rebote hacia la derecha
            } else if (minOverlap == overlapBottom) {
                // Colisión desde abajo
                player.y = sueloHitbox.bottom + playerHitbox.height / 2;
                player.velocidadVertical = player.velocidadVertical.abs() * 0.5; // Rebote hacia abajo
            }
        }
      }
    }
    return false;
  }

  double obtenerAltura(Player player, List<dynamic> suelos, double worldOffset) {
    Rect playerHitbox = player.hitbox;
    double alturaMinima = double.infinity;

    for (var suelo in suelos) {
      Rect sueloHitbox = Rect.fromLTWH(
        suelo.hitbox.left - worldOffset,
        suelo.hitbox.top,
        suelo.hitbox.width,
        suelo.hitbox.height
      );
      
      // Verificar si el jugador está alineado horizontalmente con el suelo
      if (playerHitbox.left < sueloHitbox.right &&
          playerHitbox.right > sueloHitbox.left) {
        // Solo considerar suelos que estén debajo del jugador
        if (sueloHitbox.top > playerHitbox.top &&
            sueloHitbox.top < alturaMinima) {
          alturaMinima = sueloHitbox.top;
        }
      }
    }

    return alturaMinima;
  }
}