class AnimacionSaltoAgachado {
  static const List<String> sprites = [
    'assets/personajes/principal/saltar_agachado/saltar_agachado1.png',
    'assets/personajes/principal/saltar_agachado/saltar_agachado2.png',
  ];
  
  static const double fuerzaSalto = 350.0; // Aumentado ligeramente para mejor respuesta
  static const double gravedad = 900.0; // Aumentada para caída más rápida
  static const double frameTime = 0.04; // Reducido para animación más fluida
  static const double frameTimeCaida = 0.12; // Ajustado para mejor transición
}