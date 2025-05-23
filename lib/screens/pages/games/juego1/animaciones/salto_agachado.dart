class AnimacionSaltoAgachado {
  static const List<String> sprites = [
    'assets/personajes/principal/saltar_agachado/saltar_agachado1.png',
    'assets/personajes/principal/saltar_agachado/saltar_agachado2.png',
  ];
  
  static const double fuerzaSalto = 58.0; // Un poco menos que el normal
  static const double gravedad = 40.0;    // Mucho más que antes, para que no flote
  static const double frameTime = 0.04;
  static const double frameTimeCaida = 0.12;
}