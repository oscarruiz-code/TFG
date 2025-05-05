import '../../dependencias/imports.dart';

class ComponentesJuego {
  late Player player;
  // Aquí puedes agregar más componentes como enemigos, ítems, etc.

  ComponentesJuego({required double groundLevel, required Size size}) {
    player = Player(
      x: size.width * 0.1,
      y: groundLevel - (Player.defaultHeight * 0.45),
      speed: 3.0,
      size: Player.defaultWidth * 0.42,
    );
    // Inicializa otros componentes aquí
  }
}