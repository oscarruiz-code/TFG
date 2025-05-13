import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../screens/pages/games/juego1/pages/game1.dart';

class TransicionGame1 extends StatefulWidget {
  const TransicionGame1({super.key});

  @override
  State<TransicionGame1> createState() => _TransicionGame1State();
}

class _TransicionGame1State extends State<TransicionGame1> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  bool _resourcesLoaded = false;
  String _loadingMessage = 'Iniciando carga...';
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      _isFirstBuild = false;
      _loadResources();
    }
  }

  Future<void> _loadResources() async {
    try {
      // Cargar componentes del juego
      setState(() => _loadingMessage = 'Cargando componentes del juego...');
      await Future.wait([
        // Fondo y plataforma
        precacheImage(const AssetImage('assets/imagenes/fondo.png'), context),
        
        // Sprites del personaje - Andar
        precacheImage(const AssetImage('assets/personajes/principal/andar/andar1.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/andar/andar2.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/andar/andar3.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/andar/andar4.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/andar/andar5.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/andar/andar6.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/andar/andar7.png'), context),
        
        // Sprites del personaje - Deslizar
        precacheImage(const AssetImage('assets/personajes/principal/deslizarse/deslizarse1.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/deslizarse/deslizarse2.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/deslizarse/deslizarse3.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/deslizarse/deslizarse4.png'), context),
        
        // Sprites del personaje - Saltar
        precacheImage(const AssetImage('assets/personajes/principal/saltar/saltar1.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/saltar/saltar2.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/saltar/saltar3.png'), context),
      ]);

      // Inicializar componentes del juego
      setState(() => _loadingMessage = 'Inicializando componentes...');
      
      // Marcar como cargado y animar la barra de progreso
      setState(() {
        _resourcesLoaded = true;
        _loadingMessage = '¡Carga completada!';
      });

      await _controller.forward();
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const Game1(),
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
    } catch (e) {
      setState(() => _loadingMessage = 'Error al cargar recursos: $e');
    }
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _resourcesLoaded ? Colors.blue : Colors.blue.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${(_progressAnimation.value * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _loadingMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
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