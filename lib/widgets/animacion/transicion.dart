import 'package:flutter/services.dart';
import 'package:oscarruizcode_pingu/dependencias/imports.dart';

/// Widget de transición que muestra una pantalla de carga antes de iniciar el juego.
///
/// Presenta una animación de progreso con un indicador de porcentaje y un mensaje
/// de carga mientras se preparan los recursos del juego. Al completarse, navega
/// automáticamente a la pantalla del juego.
///
/// Parámetros:
/// * [userId] - ID del usuario que iniciará el juego.
/// * [username] - Nombre del usuario que iniciará el juego.
class TransicionGame1 extends StatefulWidget {
  final int userId;
  final String username;
  
  const TransicionGame1({
    super.key,
    required this.userId, 
    required this.username
  });

  @override
  State<TransicionGame1> createState() => _TransicionGame1State();
}

class _TransicionGame1State extends State<TransicionGame1> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  String _loadingMessage = 'Preparando juego...';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
    
    // Iniciar la animación automáticamente
    _controller.forward();
    
    // Navegar al juego cuando termine la animación
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => Game1(
              userId: widget.userId, 
              username: widget.username,
              savedGameData: null,
              precargado: true, 
            ),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/personajes/principal/andar/andar1.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${(_progressAnimation.value * 100).toInt()}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _loadingMessage,
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
