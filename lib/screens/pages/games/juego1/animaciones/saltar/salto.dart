class AnimacionSalto {
  static const List<String> sprites = [
    'assets/personajes/principal/saltar/saltar1.png',
    'assets/personajes/principal/saltar/saltar2.png',
    'assets/personajes/principal/saltar/saltar3.png',
  ];
  
  static const double fuerzaSalto = 320.0; // Aumentada de 150.0 para saltos aún más altos
  static const double gravedad = 700.0;    // Aumentada de 300.0 para caídas aún más rápidas
  static const double frameTime = 0.05;
  static const double frameTimeCaida = 0.1;
  
   // Hitbox dimensions for crouched jumping
  static const double hitboxWidth = 0.7;  // Igual que salto agachado
  static const double hitboxHeight = 0.35;  // Igual que salto agachado
  static const double hitboxOffsetY = 0.3;  // Igual que salto agachado
  static const double hitboxOffsetX = 0.4;  
}