class AnimacionDeslizarse {
  static const List<String> sprites = [
    'assets/personajes/principal/deslizarse/deslizarse1.png',
    'assets/personajes/principal/deslizarse/deslizarse2.png',
    'assets/personajes/principal/deslizarse/deslizarse3.png',
    'assets/personajes/principal/deslizarse/deslizarse4.png',
  ];
  
  static const double velocidad = 200.0; // Ajustado para deslizamiento de 20 unidades
  static const double distancia = 20.0; // Distancia exacta de 20 unidades
  static const double frameTime = 0.03;
  static const double frameTimeUltimo = 0.3;
  
  // Hitbox dimensions for sliding
  static const double hitboxWidth = 0.9;
  static const double hitboxHeight = 0.35;
  static const double hitboxOffsetX = 0.45;
  static const double hitboxOffsetY = 0.15;
}