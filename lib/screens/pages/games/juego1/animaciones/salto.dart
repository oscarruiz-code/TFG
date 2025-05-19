class AnimacionSalto {
  static const List<String> sprites = [
    'assets/personajes/principal/saltar/saltar1.png',
    'assets/personajes/principal/saltar/saltar2.png',
    'assets/personajes/principal/saltar/saltar3.png',
  ];
  
  static const double fuerzaSalto = 500.0; // Aumentado para un salto más alto
  static const double gravedad = 1200.0; // Aumentado para una caída más natural
  static const double frameTime = 0.05;
  static const double frameTimeCaida = 0.08;
}