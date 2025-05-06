import 'package:flutter/material.dart';

class AnimacionRevelado extends StatefulWidget {
  final Widget child;
  final int filas;
  final int columnas;
  final Duration duracion;

  const AnimacionRevelado({
    super.key,
    required this.child,
    this.filas = 10,
    this.columnas = 20,
    this.duracion = const Duration(milliseconds: 1200),
  });

  @override
  State<AnimacionRevelado> createState() => _AnimacionReveladoState();
}

class _AnimacionReveladoState extends State<AnimacionRevelado> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duracion)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ReveladoPainter(
                progress: _controller.value,
                filas: widget.filas,
                columnas: widget.columnas,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ReveladoPainter extends CustomPainter {
  final double progress;
  final int filas;
  final int columnas;

  _ReveladoPainter({
    required this.progress,
    required this.filas,
    required this.columnas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final anchoBloque = size.width / columnas;
    final altoBloque = size.height / filas;
    final bloquesVisibles = (columnas * progress).ceil();

    for (int col = 0; col < columnas; col++) {
      if (col < bloquesVisibles) continue;
      for (int fila = 0; fila < filas; fila++) {
        final rect = Rect.fromLTWH(
          col * anchoBloque,
          fila * altoBloque,
          anchoBloque,
          altoBloque,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ReveladoPainter oldDelegate) =>
      oldDelegate.progress != progress;
}