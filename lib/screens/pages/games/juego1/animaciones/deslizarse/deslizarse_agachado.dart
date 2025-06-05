class AnimacionDeslizarseAgachado {
  static const List<String> sprites = [
    'assets/personajes/principal/deslizarse_agachado/deslizarse_agachado1.png',
    'assets/personajes/principal/deslizarse_agachado/deslizarse_agachado2.png',
    'assets/personajes/principal/deslizarse_agachado/deslizarse_agachado3.png',
  ];
  
  static const double velocidad = 150.0; // Velocidad más lenta cuando está agachado
  static const double distancia = 20.0; // Misma distancia de 20 unidades
  static const double frameTime = 0.04;
  static const double frameTimeUltimo = 0.4;
  
  // Hitbox dimensions for crouched sliding
  static const double hitboxWidth = 0.9;
  static const double hitboxHeight = 0.35;
  static const double hitboxOffsetX = 0.45;
  static const double hitboxOffsetY = 0.15;
}