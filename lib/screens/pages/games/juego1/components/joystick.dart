import 'package:flutter/material.dart';

class Joystick extends StatefulWidget {
  final Function(double dx, double dy) onDirectionChanged;

  const Joystick({Key? key, required this.onDirectionChanged})
    : super(key: key);

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  bool _isDragging = false;
  Offset _currentPosition = Offset.zero;
  final double _joystickRadius = 60.0;
  final double _innerCircleRadius = 25.0;
  final double _maxMovementRatio = 0.8; // 80% del área disponible

  void _updatePosition(Offset position) {
    if (_isDragging) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final localPosition = renderBox.globalToLocal(position);
      final center = Offset(_joystickRadius, _joystickRadius);
      
      final delta = localPosition - center;
      final maxAllowedRadius = (_joystickRadius - _innerCircleRadius) * _maxMovementRatio;
      
      // Calcular distancia desde el centro
      final distance = delta.distance;
      
      // Limitar la distancia al radio máximo permitido
      final clampedDistance = distance.clamp(0.0, maxAllowedRadius);
      
      // Calcular posición final con reducción suave
      final scaleFactor = clampedDistance / (distance > 0 ? distance : 1);
      final adjustedDelta = delta * scaleFactor;
      
      setState(() {
        _currentPosition = adjustedDelta;
      });

      // Normalizar valores (-1 a 1)
      final normalizedDx = adjustedDelta.dx / maxAllowedRadius;
      final normalizedDy = adjustedDelta.dy / maxAllowedRadius;
      
      widget.onDirectionChanged(normalizedDx, normalizedDy);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 40,
      bottom: 40,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
            _updatePosition(details.globalPosition);
          });
        },
        onPanUpdate: (details) {
          _updatePosition(details.globalPosition);
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
            _currentPosition = Offset.zero;
          });
          widget.onDirectionChanged(0, 0);
        },
        child: Container(
          width: _joystickRadius * 2,
          height: _joystickRadius * 2,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.6),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.7),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: _joystickRadius - _innerCircleRadius + _currentPosition.dx,
                top: _joystickRadius - _innerCircleRadius + _currentPosition.dy,
                child: Container(
                  width: _innerCircleRadius * 2,
                  height: _innerCircleRadius * 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}