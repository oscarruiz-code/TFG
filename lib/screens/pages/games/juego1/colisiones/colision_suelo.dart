import '../../../../../dependencias/imports.dart';

class ColisionSuelo {
  bool verificar(Player player, List<dynamic> suelos) {
    final playerFeet = player.y + player.size * 0.45;
    final playerCenterX = player.x;
    final playerWidth = player.size * 0.85;

    for (var suelo in suelos) {
      if (suelo is Rampa || suelo is RampaInvertida) {
        if (playerCenterX + playerWidth * 0.5 > suelo.x &&
            playerCenterX - playerWidth * 0.5 < suelo.x + suelo.width) {
          double alturaRampa = suelo.getAlturaEnPunto(playerCenterX);
          if (playerFeet >= alturaRampa - 5 && playerFeet <= alturaRampa + 5) {
            return true;
          }
        }
      } else {
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

  double obtenerAltura(Player player, List<dynamic> suelos) {
    final playerCenterX = player.x;
    final playerWidth = player.size * 0.85;
    double alturaMinima = double.infinity;

    // Primero buscar el suelo inicial más cercano
    for (var suelo in suelos) {
      if (suelo is! Rampa && suelo is! RampaInvertida) {  // Solo suelos normales
        if (playerCenterX + playerWidth * 0.5 > suelo.x &&
            playerCenterX - playerWidth * 0.5 < suelo.x + suelo.width) {
          double alturaSuperficie = suelo.hitbox.top;
          if (alturaSuperficie < alturaMinima) {
            alturaMinima = alturaSuperficie;
          }
        }
      }
    }

    // Si no encontramos ningún suelo, usar la altura del primer suelo del mapa
    if (alturaMinima == double.infinity && suelos.isNotEmpty) {
      for (var suelo in suelos) {
        if (suelo is! Rampa && suelo is! RampaInvertida) {
          return suelo.hitbox.top;
        }
      }
    }

    // Si aún así no hay suelos, usar un valor predeterminado razonable
    return alturaMinima == double.infinity ? 300 : alturaMinima;
  }
}