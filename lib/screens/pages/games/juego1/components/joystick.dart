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
  Offset _currentPosition = Offset.zero;
  bool _isDragging = false;
  final double _maxDistance = 40.0; // Aumentado para mejor control

  void _updatePosition(Offset position) {
    if (_isDragging) {
      setState(() {
        final delta = position - _startPosition;
        final distance = math.sqrt(delta.dx * delta.dx + delta.dy * delta.dy);
        
        if (distance > 0) {
          final normalizedDx = delta.dx / distance;
          final normalizedDy = delta.dy / distance;
          final actualDistance = math.min(distance, _maxDistance);
          _currentPosition = Offset(
            _startPosition.dx + normalizedDx * actualDistance,
            _startPosition.dy + normalizedDy * actualDistance
          );
          
          // Ajustamos la sensibilidad del movimiento
          widget.onDirectionChanged(normalizedDx * 1.5, normalizedDy * 1.5);
        }
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
      return GestureDetector(
          onPanStart: (details) {
              setState(() {
                  _isDragging = true;
                  _startPosition = details.localPosition;
                  _currentPosition = _startPosition;
              });
          },
          onPanUpdate: (details) {
              _updatePosition(details.localPosition);
          },
          onPanEnd: (details) {
              setState(() {
                  _isDragging = false;
                  _currentPosition = _startPosition;
              });
              widget.onDirectionChanged(0, 0);
          },
          child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.blue,
                      width: 2,
                  ),
              ),
              child: Stack(
                  children: [
                      // Círculo interno centrado por defecto
                      Positioned(
                          left: !_isDragging ? 30 : _currentPosition.dx - 20, // Centrado cuando no se arrastra
                          top: !_isDragging ? 30 : _currentPosition.dy - 20,  // Centrado cuando no se arrastra
                          child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(_isDragging ? 0.5 : 0.3),
                                  shape: BoxShape.circle,
                              ),
                          ),
                      ),
                  ],
              ),
          ),
      );
  }
}