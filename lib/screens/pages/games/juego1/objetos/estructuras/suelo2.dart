import 'package:flutter/material.dart';

class Suelo2 {
  final double x;
  final double y;
  final double width;
  final double height;
  final String sprite;

  Suelo2({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.sprite = 'assets/objetos/suelo/suelo2.png',
  });

  Rect get hitbox => Rect.fromLTWH(
    x + (width * 0.025),    // Ajuste del ancho desde la izquierda
    y + (height * 0.33),  // Pequeño offset vertical para mejor alineación
    width * 0.95,          // Ancho ajustado para mejor colisión
    height * 0.45,         // Altura ajustada para mejor colisión
  );
}