class AnimacionAndar {
  static const List<String> sprites = [
    'assets/personajes/principal/andar/andar1.png',
    'assets/personajes/principal/andar/andar2.png',
    'assets/personajes/principal/andar/andar3.png',
    'assets/personajes/principal/andar/andar4.png',
    'assets/personajes/principal/andar/andar5.png',
    'assets/personajes/principal/andar/andar6.png',
    'assets/personajes/principal/andar/andar7.png',
  ];
  
  static const double velocidad = 350; // Aumentada de 150 a 250
  static const double frameTime = 0.04; // Reducido para una animación más rápida
  
  // Hitbox dimensions for normal walking
  static const double hitboxWidth = 0.85;
  static const double hitboxHeight = 0.94;
  static const double hitboxOffsetX = 0.425;
  static const double hitboxOffsetY = 0.47;
}