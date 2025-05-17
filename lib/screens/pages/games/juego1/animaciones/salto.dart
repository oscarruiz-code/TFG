class AnimacionSalto {
  static const List<String> sprites = [
    'assets/personajes/principal/saltar/saltar1.png',
    'assets/personajes/principal/saltar/saltar2.png',
    'assets/personajes/principal/saltar/saltar3.png',
  ];
  
  static const double fuerzaSalto = 550.0; // Aumentada para un salto más pronunciado
  static const double gravedad = 1200.0; // Reducida para caída más natural
  static const double frameTime = 0.06; // Más rápido para mejor respuesta
  static const double frameTimeCaida = 0.1; // Ajustado para mejor transición
}