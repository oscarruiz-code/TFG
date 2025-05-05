import 'package:oscarruizcode_pingu/dependencias/imports.dart';
import 'package:flutter/services.dart';

class Game1 extends StatefulWidget {
  const Game1({super.key});

  @override
  State<Game1> createState() => _Game1State();
}

class _Game1State extends State<Game1> {
  late Player player;
  double groundLevel = 100.0;
  bool isGameActive = true;
  bool isInitialized = false;
  late ComponentesJuego componentesJuego;
  late GestorColisiones gestorColisiones;

  @override
  void initState() {
    super.initState();
    // Forzar orientación horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final size = MediaQuery.of(context).size;
      const double platformHeight = 50;
      groundLevel = size.height - platformHeight;
      componentesJuego = ComponentesJuego(
        groundLevel: groundLevel,
        size: size,
      );
      gestorColisiones = GestorColisiones();
      isInitialized = true;
      startGameLoop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Fondo
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/imagenes/fondo.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Plataforma (suelo)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      color: Colors.lightBlue[900]?.withAlpha(179),
                    ),
                  ),
                  // Jugador
                  Positioned(
                    left: componentesJuego.player.x,
                    top: componentesJuego.player.y,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(
                        componentesJuego.player.isFacingRight ? 1 : -1,
                        1,
                        1,
                      ),
                      child: Image.asset(
                        componentesJuego.player.getCurrentSprite(),
                        width: componentesJuego.player.size,
                        height: componentesJuego.player.size,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Joystick
            Positioned(
              left: 50,
              bottom: 50,
              child: Joystick(
                onDirectionChanged: (dx, dy) {
                  setState(() {
                    if (dx != 0) {
                      componentesJuego.player.move(dx, 0, groundLevel: groundLevel);
                      if (componentesJuego.player.currentState != PenguinPlayerState.walking) {
                        componentesJuego.player.currentState = PenguinPlayerState.walking;
                        componentesJuego.player.currentFrame = 0;
                        componentesJuego.player.animationTime = 0;
                      }
                    } else {
                      if (componentesJuego.player.currentState != PenguinPlayerState.idle) {
                        componentesJuego.player.currentState = PenguinPlayerState.idle;
                        componentesJuego.player.currentFrame = 0;
                        componentesJuego.player.animationTime = 0;
                      }
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startGameLoop() {
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!isGameActive) {
        timer.cancel();
        return;
      }

      setState(() {
        componentesJuego.player.updateAnimation(0.016);
      });
    });
  }
}
