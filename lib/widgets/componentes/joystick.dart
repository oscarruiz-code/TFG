import 'package:flutter/material.dart';

class Joystick extends StatefulWidget {
  final Function(double dx, double dy) onDirectionChanged;
  
  const Joystick({
    super.key,
    required this.onDirectionChanged,
  });

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset _startPosition = Offset.zero;
  Offset _currentPosition = Offset.zero;
  bool _isDragging = false;
  final double _joystickRadius = 50.0;
  final double _knobRadius = 20.0;

  void _updatePosition(Offset position) {
    Offset delta = position - _startPosition;
    double distance = delta.distance;
    
    if (distance > _joystickRadius) {
      delta = delta * (_joystickRadius / distance);
    }
    
    setState(() {
      _currentPosition = delta;
    });
    
    // Normalizar valores entre -1 y 1
    double dx = delta.dx / _joystickRadius;
    double dy = delta.dy / _joystickRadius;
    widget.onDirectionChanged(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _joystickRadius * 2,
      width: _joystickRadius * 2,
      child: GestureDetector(
        onPanStart: (details) {
          _isDragging = true;
          _startPosition = details.localPosition;
          _updatePosition(details.localPosition);
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            _updatePosition(details.localPosition);
          }
        },
        onPanEnd: (_) {
          _isDragging = false;
          setState(() {
            _currentPosition = Offset.zero;
          });
          widget.onDirectionChanged(0, 0);
        },
        child: CustomPaint(
          painter: JoystickPainter(
            baseRadius: _joystickRadius,
            knobRadius: _knobRadius,
            knobPosition: _currentPosition,
          ),
        ),
      ),
    );
  }
}

class JoystickPainter extends CustomPainter {
  final double baseRadius;
  final double knobRadius;
  final Offset knobPosition;

  JoystickPainter({
    required this.baseRadius,
    required this.knobRadius,
    required this.knobPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(baseRadius, baseRadius);
    
    // Dibujar base del joystick
    final basePaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius, basePaint);
    
    // Dibujar knob del joystick
    final knobPaint = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      center + knobPosition,
      knobRadius,
      knobPaint,
    );
  }

  @override
  bool shouldRepaint(JoystickPainter oldDelegate) =>
      oldDelegate.knobPosition != knobPosition;
}