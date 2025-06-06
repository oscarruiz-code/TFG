import 'package:flutter/material.dart';

/// Representa una plataforma de tipo suelo alternativo en el juego.
///
/// Similar a la clase Suelo, pero con diferentes ajustes de hitbox y sprite.
/// Esta variante está diseñada para representar un tipo diferente de plataforma
/// con características de colisión distintas.
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