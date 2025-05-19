import '../../../../../dependencias/imports.dart';

class GestorColisiones {
  bool verificarColisionSuelo(Player player, List<dynamic> suelos) {
    final playerFeet = player.y + player.size * 0.45; // Ajustado para mejor precisión
    final playerCenterX = player.x;
    final playerWidth = player.size * 0.85; // Aumentado para mejor cobertura
    
    for (var suelo in suelos) {
      if (suelo is Rampa || suelo is RampaInvertida) {
        // Verificación de colisión con rampas
        if (playerCenterX + playerWidth * 0.5 > suelo.x &&
            playerCenterX - playerWidth * 0.5 < suelo.x + suelo.width) {
          double alturaRampa;
          
          if (suelo is RampaInvertida) {
            alturaRampa = suelo.getAlturaEnPunto(playerCenterX);
          } else if (suelo is Rampa) {
            alturaRampa = suelo.getAlturaEnPunto(playerCenterX);
          } else {
            continue;
          }
          
          // Margen de tolerancia ajustado para mejor detección
          if (playerFeet >= alturaRampa - 5 && playerFeet <= alturaRampa + 5) {
            return true;
          }
        }
      } else {
        // Verificación de colisión con suelos normales
        Rect sueloHitbox = suelo.hitbox;
        if (playerCenterX + playerWidth * 0.5 > sueloHitbox.left &&
            playerCenterX - playerWidth * 0.5 < sueloHitbox.right &&
            playerFeet >= sueloHitbox.top &&
            playerFeet <= sueloHitbox.top + 5) {
          return true;
        }
      }
    }
    return false;
  }

  double obtenerAlturaDelSuelo(Player player, List<dynamic> suelos) {
    final playerCenterX = player.x;
    final playerWidth = player.size * 0.85;
    double alturaMinima = double.infinity;
    double alturaActual = player.y + player.size * 0.5;
    
    for (var suelo in suelos) {
      if (playerCenterX + playerWidth * 0.5 > suelo.x &&
          playerCenterX - playerWidth * 0.5 < suelo.x + suelo.width) {
        
        double alturaSuperficie;
        if (suelo is Rampa) {
          alturaSuperficie = suelo.getAlturaEnPunto(playerCenterX);
        } else if (suelo is RampaInvertida) {
          alturaSuperficie = suelo.getAlturaEnPunto(playerCenterX);
        } else {
          alturaSuperficie = suelo.hitbox.top;
        }
        
        // Solo considerar superficies que estén debajo del jugador
        if (alturaSuperficie > player.y && alturaSuperficie < alturaMinima) {
          alturaMinima = alturaSuperficie;
        }
        
        // Si encontramos una superficie válida justo debajo del jugador
        if (alturaSuperficie >= alturaActual && alturaSuperficie < alturaMinima) {
          alturaMinima = alturaSuperficie;
        }
      }
    }
    
    return alturaMinima == double.infinity ? 1000 : alturaMinima;
  }

  bool verificarColisionObstaculo(Player player, Rect obstaculoHitbox) {
    // Ajuste del hitbox según el estado del jugador
    Rect playerHitbox = player.isSliding 
        ? Rect.fromLTWH(
            player.x - (player.size * 0.425),
            player.y - (player.size * 0.2),
            player.size * 0.85,
            player.size * 0.4,
          )
        : player.isCrouching
            ? Rect.fromLTWH(
                player.x - (player.size * 0.425),
                player.y - (player.size * 0.3),
                player.size * 0.85,
                player.size * 0.6,
              )
            : player.hitbox;
    
    return playerHitbox.overlaps(obstaculoHitbox);
  }

  bool verificarColisionCasa(Player player, Casa casa) {
    // Ajuste del hitbox según el estado del jugador, similar a verificarColisionObstaculo
    Rect playerHitbox = player.isSliding 
        ? Rect.fromLTWH(
            player.x - (player.size * 0.425),
            player.y - (player.size * 0.2),
            player.size * 0.85,
            player.size * 0.4,
          )
        : player.isCrouching
            ? Rect.fromLTWH(
                player.x - (player.size * 0.425),
                player.y - (player.size * 0.3),
                player.size * 0.85,
                player.size * 0.6,
              )
            : player.hitbox;
    
    return playerHitbox.overlaps(casa.hitbox);
  }

  bool verificarColisionItem(Player player, Rect itemHitbox) {
    // Usar el hitbox del jugador directamente para items
    return player.hitbox.overlaps(itemHitbox);
  }
}