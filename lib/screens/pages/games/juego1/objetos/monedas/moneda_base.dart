import 'package:flutter/material.dart';

abstract class MonedaBase {
  double x;
  double y;
  bool isCollected;
  final double size;
  final double width;
  final double height;
  final String spritePath;

  MonedaBase({
    required this.x,
    required this.y,
    this.isCollected = false,
    this.size = 30,
    this.width = 30,
    this.height = 30,
    required this.spritePath,
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