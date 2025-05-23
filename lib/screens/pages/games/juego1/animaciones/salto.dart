class AnimacionSalto {
  static const List<String> sprites = [
    'assets/personajes/principal/saltar/saltar1.png',
    'assets/personajes/principal/saltar/saltar2.png',
    'assets/personajes/principal/saltar/saltar3.png',
  ];
  
  static const double fuerzaSalto = 68.0; // Más fuerza para subir más rápido
  static const double gravedad = 50.0;    // Más gravedad para caer más rápido
  static const double frameTime = 0.05;
  static const double frameTimeCaida = 0.1;
}