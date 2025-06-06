import 'package:flutter/material.dart';

/// Representa la meta o punto final del nivel en el juego.
///
/// Esta clase define las propiedades físicas y visuales de la casa que sirve como
/// objetivo para que el jugador complete el nivel. Incluye su posición, dimensiones
/// y un hitbox para la detección de colisiones.
class Casa {
  final double x;
  final double y;
  final double width;
  final double height;
  final String sprite = 'assets/personajes/items/casa/casita.png';

  Casa({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Rect get hitbox => Rect.fromLTWH(
    x + (width * 0.1),
    y + (height * 0.1),
    width * 0.8,
    height * 0.8,
  );
}