import 'package:flutter/material.dart';

class Suelo {
  final double x;
  final double y;
  final double width;
  final double height;
  final String sprite;

  Suelo({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.sprite = 'assets/objetos/suelo/suelo.png',
  });

  Rect get hitbox => Rect.fromLTWH(
    x + (width * 0.1),    // Ajuste del ancho desde la izquierda
    y + (height * 0.4),   // Offset vertical para mejor alineación
    width * 0.83,          // Ancho ajustado para mejor colisión
    height * 0.7,         // Altura ajustada para mejor colisión
  );
}
