class AnimacionAndarAgachado {
  static const List<String> sprites = [
    'assets/personajes/principal/andar_agachado/andar_agachado1.png',
    'assets/personajes/principal/andar_agachado/andar_agachado2.png',
    'assets/personajes/principal/andar_agachado/andar_agachado3.png',
    'assets/personajes/principal/andar_agachado/andar_agachado4.png',
    'assets/personajes/principal/andar_agachado/andar_agachado5.png',
    'assets/personajes/principal/andar_agachado/andar_agachado6.png',
  ];
  
  static const double velocidad = 350; // Ajustada proporcionalmente con la velocidad normal
  static const double frameTime = 0.03; // Igualada con la animación normal
  
  // Hitbox dimensions for crouched walking
  static const double hitboxWidth = 0.9;
  static const double hitboxHeight = 0.8;
  static const double hitboxOffsetX = 0.5;
  static const double hitboxOffsetY = 0.35;
}