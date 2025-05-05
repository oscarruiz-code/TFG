import '../../dependencias/imports.dart';

class GestorColisiones {
  // Aquí puedes recibir los componentes y comprobar colisiones
  bool colisionaConSuelo(Player player, double groundLevel) {
    // Ejemplo simple: el jugador no puede bajar del suelo
    return player.y >= groundLevel - (player.size * 0.5);
  }
}