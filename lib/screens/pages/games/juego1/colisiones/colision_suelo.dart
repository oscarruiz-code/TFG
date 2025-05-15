import '../../../../../dependencias/imports.dart';

class GestorColisiones {
  bool verificarColisionSuelo(Player player, List<dynamic> suelos) {
    final playerFeet = player.y + player.size * 0.5;
    final playerCenterX = player.x;
    final playerWidth = player.size * 0.8;
    
    for (var suelo in suelos) {
      if (suelo is Rampa) {
        // Colisión especial para rampas
        if (playerCenterX + playerWidth * 0.4 > suelo.x &&
            playerCenterX - playerWidth * 0.4 < suelo.x + suelo.width) {
          // Calcular altura de la rampa en la posición actual del jugador
          double porcentajeX = (playerCenterX - suelo.x) / suelo.width;
          double alturaRampa;
          
          if (suelo.invertida) {
            // Para rampas invertidas, la altura disminuye de izquierda a derecha
            alturaRampa = suelo.y + (suelo.height * (1 - porcentajeX));
          } else {
            // Para rampas normales, la altura aumenta de izquierda a derecha
            alturaRampa = suelo.y + (suelo.height * porcentajeX);
          }
          
          // Margen de colisión más preciso para rampas
          if (playerFeet >= alturaRampa - 5 && playerFeet <= alturaRampa + 5) {
            return true;
          }
        }
      } else {
        // Colisión con suelos normales y suelo2
        if (playerCenterX + playerWidth * 0.4 > suelo.x &&
            playerCenterX - playerWidth * 0.4 < suelo.x + suelo.width &&
            playerFeet >= suelo.y &&
            playerFeet <= suelo.y + 10) {
          return true;
        }
      }
    }
    return false;
  }

  double obtenerAlturaDelSuelo(Player player, List<dynamic> suelos) {
    final playerCenterX = player.x;
    final playerWidth = player.size * 0.8;
    double alturaMinima = double.infinity;
    
    for (var suelo in suelos) {
      if (playerCenterX + playerWidth * 0.4 > suelo.x &&
          playerCenterX - playerWidth * 0.4 < suelo.x + suelo.width) {
        
        if (suelo is Rampa) {
          // Calcular altura precisa en la rampa
          double porcentajeX = (playerCenterX - suelo.x) / suelo.width;
          double alturaRampa;
          
          if (suelo.invertida) {
            alturaRampa = suelo.y + (suelo.height * (1 - porcentajeX));
          } else {
            alturaRampa = suelo.y + (suelo.height * porcentajeX);
          }
          
          if (alturaRampa < alturaMinima) {
            alturaMinima = alturaRampa;
          }
        } else {
          // Para suelos normales y suelo2
          if (suelo.y < alturaMinima) {
            alturaMinima = suelo.y;
          }
        }
      }
    }
    return alturaMinima;
  }

  bool verificarColisionObstaculo(Player player, Rect obstaculoHitbox) {
    // Colisión más precisa considerando el estado del jugador
    Rect playerHitbox = player.hitbox;
    if (player.isSliding) {
      // Ajustar hitbox cuando el jugador está deslizándose
      playerHitbox = Rect.fromLTWH(
        player.x - (player.size * 0.4),
        player.y - (player.size * 0.25), // Mitad de altura normal
        player.size * 0.8,
        player.size * 0.5,
      );
    }
    return playerHitbox.overlaps(obstaculoHitbox);
  }

  bool verificarColisionItem(Player player, Rect itemHitbox) {
    // Usar el hitbox normal del jugador para items
    return player.hitbox.overlaps(itemHitbox);
  }
  
  bool verificarColisionRampa(Player player, List<Rampa> rampas) {
    final playerFeet = player.y + player.size * 0.5;
    final playerCenterX = player.x;
    final playerWidth = player.size * 0.8;
    
    for (var rampa in rampas) {
      if (playerCenterX + playerWidth * 0.4 > rampa.x &&
          playerCenterX - playerWidth * 0.4 < rampa.x + rampa.width) {
        // Calcular punto exacto de colisión en la rampa
        double porcentajeX = (playerCenterX - rampa.x) / rampa.width;
        double alturaRampa = rampa.invertida ?
          rampa.y + (rampa.height * (1 - porcentajeX)) :
          rampa.y + (rampa.height * porcentajeX);
          
        if (playerFeet >= alturaRampa - 5 && playerFeet <= alturaRampa + 5) {
          return true;
        }
      }
    }
    return false;
  }
}