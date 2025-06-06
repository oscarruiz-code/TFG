import '../../../../../../dependencias/imports.dart';
import 'package:flutter/material.dart';

/// Clase abstracta que define la estructura base para todos los tipos de monedas en el juego.
///
/// Proporciona propiedades comunes como posición, estado de recolección, tamaño y valor,
/// así como métodos para marcar como recolectada, definir hitbox para colisiones y
/// renderizar la moneda en pantalla. Cada subclase debe implementar su propio efecto.
abstract class MonedaBase {
  double x;
  double y;
  bool isCollected;
  final double size;
  final double width;
  final double height;
  final String spritePath;
  final int valor;

  MonedaBase({
    required this.x,
    required this.y,
    this.isCollected = false,
    this.size = 50.0,
    this.width = 50.0,
    this.height = 50.0,
    required this.spritePath,
    this.valor = 1,
  });

  void aplicarEfecto(dynamic player);
  
  // Añadir método markAsCollected
  void markAsCollected() {
    isCollected = true;
  }
  
  Rect get hitbox => Rect.fromLTWH(
    x + (width * 0.1),
    y + (height * 0.2),
    width * 0.8,
    height * 0.6,
  );
  
  String get sprite => spritePath;
  
  Widget build() {
    if (isCollected) {
      return const SizedBox.shrink();
    }
    return Image.asset(
      spritePath,
      width: width,
      height: height,
    );
  }
}
