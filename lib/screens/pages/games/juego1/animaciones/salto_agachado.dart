class AnimacionSaltoAgachado {
  static const List<String> sprites = [
    'assets/personajes/principal/saltar_agachado/saltar_agachado1.png',
    'assets/personajes/principal/saltar_agachado/saltar_agachado2.png',
  ];
  
  static const double fuerzaSalto = 270.0; // Aumentada de 130.0 manteniendo proporción
  static const double gravedad = 600.0;    // Igualada a la gravedad del salto normal
  static const double frameTime = 0.04;
  static const double frameTimeCaida = 0.12;
  
  // Hitbox dimensions for crouched jumping
  static const double hitboxWidth = 0.9;
  static const double hitboxHeight = 0.4;  // Match with normal jump
  static const double hitboxOffsetY = 0.4;  // Half of hitboxHeight
  static const double hitboxOffsetX = 0.5;  // Ajustado para alinear con el suelo
}