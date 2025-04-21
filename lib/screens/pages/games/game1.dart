import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../game_components/game_world.dart';
import '../../../game_components/player.dart';
import '../../../servicios/sevices/player_service.dart';  // Añadimos esta importación

class Game1 extends StatefulWidget {
  final int? userId;  // Añadimos userId como parámetro
  
  const Game1({super.key, this.userId});

  @override
  State<Game1> createState() => _Game1State();
}

class _Game1State extends State<Game1> {
  late GameWorld gameWorld;
  late Player player;
  bool isGameActive = true;
  int timeElapsed = 0;
  final PlayerService _playerService = PlayerService();
  
  // Usamos el userId del widget
  int? get userId => widget.userId;
  int coinsEarned = 0;

  @override
  void initState() {
    super.initState();
    initializeGame();
    startGameLoop();
    // Timer para las monedas cada 30 segundos
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isGameActive) {
        setState(() {
          coinsEarned += 20;
        });
      }
    });
  }

  Future<void> endGame() async {
    isGameActive = false;
    if (userId != null) {  // Solo guardamos si hay userId
      await _playerService.registerGamePlay(
        userId!, 
        1,
        gameWorld.score, 
        timeElapsed
      );
      
      var stats = await _playerService.getPlayerStats(userId!);
      await _playerService.updateCoins(userId!, stats.coins + coinsEarned);
    }
  }

  void initializeGame() {
    player = Player(
      x: 100,
      y: 100,
      speed: 5.0,
      size: 50.0,
    );

    gameWorld = GameWorld(
      worldSize: const Size(800, 600),
      player: player,
    );
  }

  void startGameLoop() {
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!isGameActive) {
        timer.cancel();
        return;
      }

      setState(() {
        gameWorld.update();
        timeElapsed++;
        if (timeElapsed % 60 == 0) {
          gameWorld.level = (timeElapsed ~/ 600) + 1; // Aumenta nivel cada 10 segundos
        }
      });
    });
  }

  void handleTap(TapDownDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    
    double dx = localPosition.dx - player.x;
    double dy = localPosition.dy - player.y;
    
    double distance = math.sqrt(dx * dx + dy * dy);  // Usamos math.sqrt
    if (distance > 0) {
      dx /= distance;
      dy /= distance;
      player.move(dx, dy);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survival Mode'),
        backgroundColor: const Color.fromRGBO(0, 32, 96, 1),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Score: ${gameWorld.score}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTapDown: handleTap,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/imagenes/fondo.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // Jugador
              Positioned(
                left: player.x,
                top: player.y,
                child: Transform.scale(
                  scaleX: player.isFacingRight ? 1 : -1,
                  child: Image.asset(
                    player.getCurrentSprite(),
                    width: player.size,
                    height: player.size,
                  ),
                ),
              ),
              // Enemigos
              ...gameWorld.enemies.map((enemy) => Positioned(
                left: enemy.x,
                top: enemy.y,
                child: Image.asset(
                  enemy.sprite,
                  width: enemy.size,
                  height: enemy.size,
                ),
              )),
              // Power-ups
              ...gameWorld.powerUps.map((powerUp) => Positioned(
                left: powerUp.x,
                top: powerUp.y,
                child: Image.asset(
                  powerUp.sprite,
                  width: powerUp.size,
                  height: powerUp.size,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}