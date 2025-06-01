import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../screens/pages/games/juego1/pages/game1.dart';

class TransicionGame1 extends StatefulWidget {
  final int userId;
  final String username;  // Añadimos la propiedad userId
  
  const TransicionGame1({
    super.key,
    required this.userId, 
    required this.username // Requerimos el userId en el constructor
  });

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
        // Fondo y recursos básicos
        precacheImage(const AssetImage('assets/imagenes/fondo.png'), context),
        precacheImage(const AssetImage('assets/imagenes/logo.png'), context),
        precacheImage(const AssetImage('assets/imagenes/juego.png'), context),
        
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
        
        // Sprites del personaje - Agacharse
        precacheImage(const AssetImage('assets/personajes/principal/agacharse/agacharse1.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/agacharse/agacharse2.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/agacharse/agacharse3.png'), context),
        
        // Sprites del personaje - Andar Agachado
        precacheImage(const AssetImage('assets/personajes/principal/andar_agachado/andar_agachado1.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/andar_agachado/andar_agachado2.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/andar_agachado/andar_agachado3.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/andar_agachado/andar_agachado4.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/andar_agachado/andar_agachado5.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/andar_agachado/andar_agachado6.png'), context),
        
        // Sprites del personaje - Deslizarse Agachado
        precacheImage(const AssetImage('assets/personajes/principal/deslizarse_agachado/deslizarse_agachado1.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/deslizarse_agachado/deslizarse_agachado2.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/deslizarse_agachado/deslizarse_agachado3.png'), context),
        
        // Sprites del personaje - Saltar Agachado
        precacheImage(const AssetImage('assets/personajes/principal/saltar_agachado/saltar_agachado1.png'), context),
        precacheImage(const AssetImage('assets/personajes/principal/saltar_agachado/saltar_agachado2.png'), context),
        
        // Items y objetos del juego
        precacheImage(const AssetImage('assets/personajes/items/monedas/monedacoin.png'), context),
        precacheImage(const AssetImage('assets/personajes/items/monedas/monedasalto.png'), context),
        precacheImage(const AssetImage('assets/personajes/items/monedas/monedavelocidad.png'), context),
        precacheImage(const AssetImage('assets/personajes/items/monedas/monedavelocidad_hitbox.png'), context), // Agregar el hitbox de la moneda
        precacheImage(const AssetImage('assets/personajes/items/casa/casita.png'), context),
        precacheImage(const AssetImage('assets/avatar/defecto.png'), context),
        
        // Objetos del escenario
        precacheImage(const AssetImage('assets/objetos/suelo/suelo.png'), context),
        precacheImage(const AssetImage('assets/objetos/suelo/suelo2.png'), context),
        precacheImage(const AssetImage('assets/objetos/rampa/rampa.png'), context),
        precacheImage(const AssetImage('assets/objetos/rampa/rampa_invertida.png'), context),
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
            pageBuilder: (context, animation, secondaryAnimation) => Game1(
              userId: widget.userId, 
              username: widget.username, // Pasamos el userId al Game1
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
