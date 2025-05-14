import '../../../../../dependencias/imports.dart';

class GestorColisiones {
  bool verificarColisionSuelo(Player player, List<dynamic> suelos) {
    final playerFeet = player.y + player.size * 0.5;
    final playerCenterX = player.x;
    
    for (var suelo in suelos) {
      if (playerCenterX + player.size * 0.4 > suelo.x &&
          playerCenterX - player.size * 0.4 < suelo.x + suelo.width &&
          playerFeet >= suelo.y &&
          playerFeet <= suelo.y + 10) {
        return true;
      }
    }
    return false;
  }

  double obtenerAlturaDelSuelo(Player player, List<dynamic> suelos) {
    final playerCenterX = player.x;
    
    for (var suelo in suelos) {
      if (playerCenterX + player.size * 0.4 > suelo.x &&
          playerCenterX - player.size * 0.4 < suelo.x + suelo.width) {
        return suelo.y;
      }
    }
    return double.infinity;
  }

  bool verificarColisionObstaculo(Player player, Rect obstaculoHitbox) {
    return player.hitbox.overlaps(obstaculoHitbox);
  }

  bool verificarColisionItem(Player player, Rect itemHitbox) {
    return player.hitbox.overlaps(itemHitbox);
  }
  
  bool verificarColisionRampa(Player player, Rect rampaHitbox) {
    return player.hitbox.overlaps(rampaHitbox);
  }
}