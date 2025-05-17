import 'package:flutter/material.dart';
import 'dart:math' as math;

class Joystick extends StatefulWidget {
  final Function(double dx, double dy) onDirectionChanged;

  const Joystick({
    Key? key,
    required this.onDirectionChanged,
  }) : super(key: key);

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset _startPosition = Offset.zero;
  bool _isDragging = false;

  void _updatePosition(Offset position) {
    if (_isDragging) {
      final delta = position - _startPosition;
      final distance = math.sqrt(delta.dx * delta.dx + delta.dy * delta.dy);
      if (distance > 0) {
        final normalizedDx = delta.dx / distance;
        final normalizedDy = delta.dy / distance;
        widget.onDirectionChanged(normalizedDx, normalizedDy);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _isDragging = true;
        _startPosition = details.localPosition;
      },
      onPanUpdate: (details) {
        _updatePosition(details.localPosition);
      },
      onPanEnd: (details) {
        _isDragging = false;
        widget.onDirectionChanged(0, 0);
      },
      child: Container(
        width: 100, // Reducido de 120 a 100
        height: 100, // Reducido de 120 a 100
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.7),
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            width: 50, // Reducido de 60 a 50
            height: 50, // Reducido de 60 a 50
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}