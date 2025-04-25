import 'package:oscarruizcode_pingu/dependencias/imports.dart';
import 'dart:ui';
import 'dart:math' as math;

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 15.0,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: child,
        ),
      ),
    );
  }
}

class CrackClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final random = math.Random(42); // Semilla fija para consistencia
    
    path.moveTo(0, 0);
    
    // Crear puntos de "rotura" aleatorios
    final numPoints = 8;
    List<Offset> points = [];
    
    for (int i = 0; i < numPoints; i++) {
      points.add(Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      ));
    }
    
    // Dibujar líneas irregulares entre los puntos
    for (int i = 0; i < points.length; i++) {
      final current = points[i];
      final next = points[(i + 1) % points.length];
      
      path.lineTo(current.dx, current.dy);
      
      // Agregar puntos de control para crear líneas irregulares
      final controlPoint = Offset(
        (current.dx + next.dx) / 2 + random.nextDouble() * 20 - 10,
        (current.dy + next.dy) / 2 + random.nextDouble() * 20 - 10,
      );
      
      path.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        next.dx,
        next.dy,
      );
    }
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}