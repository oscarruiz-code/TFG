import '../../../../../../dependencias/imports.dart';
import 'package:flutter/material.dart';

abstract class MonedaBase {
  double x;
  double y;
  bool isCollected;
  final double size;
  final double width;
  final double height;
  final String spritePath;
  final int valor; // <-- Agrega esto

  MonedaBase({
    required this.x,
    required this.y,
    this.isCollected = false,
    this.size = 50.0,    // Tamaño estándar
    this.width = 50.0,   // Ancho estándar
    this.height = 50.0,  // Alto estándar
    required this.spritePath,
    this.valor = 1,
  });

  void aplicarEfecto(dynamic player);
  
  Rect get hitbox => Rect.fromLTWH(
    x,
    y,
    width,
    height,
  );
  
  String get sprite => spritePath;
  
  Widget build() {
    return isCollected ? const SizedBox() : Image.asset(
      spritePath,
      width: width,
      height: height,
    );
  }
}