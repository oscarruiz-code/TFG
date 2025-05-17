import 'package:flutter/material.dart';

class RampaInvertida {
  final double x;
  final double y;
  final double width;
  final double height;
  
  String get sprite => 'assets/objetos/rampa/rampa_invertida.png';
  
  RampaInvertida({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Rect get hitbox => Rect.fromLTWH(
    x + (width * 0.15),
    y + (height * 0.1),
    width * 0.7,
    height * 0.85,
  );

  // Método para calcular la altura en un punto específico de la rampa
  double getAlturaEnPunto(double puntoX) {
    double porcentajeX = (puntoX - x) / width;
    // Para rampas invertidas, la altura disminuye de izquierda a derecha
    return y + (height * (1 - porcentajeX));
  }
}