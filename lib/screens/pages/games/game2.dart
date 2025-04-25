import 'package:oscarruizcode_pingu/dependencias/imports.dart';
import 'dart:math' as math;  

class Game2 extends StatefulWidget {
  final int? userId;  // Añadimos userId como parámetro
  
  const Game2({super.key, this.userId});

  @override
  State<Game2> createState() => _Game2State();
}

class _Game2State extends State<Game2> {
  late GameWorld gameWorld;
  late Player player;
  bool isGameActive = true;
  int timeRemaining = 120; // 2 minutos
  int enemiesDefeated = 0;
  final PlayerService _playerService = PlayerService();
  
  // Usamos el userId del widget
  int? get userId => widget.userId;
  int coinsEarned = 0;

  @override
  void initState() {
    super.initState();
    initializeGame();
    startGameLoop();
  }

  void handleEnemyDefeat() {
    enemiesDefeated++;
    coinsEarned += 50;  // 50 monedas por foca
    gameWorld.score += 100;
  }

  Future<void> endGame() async {
    isGameActive = false;
    if (userId != null) {  // Solo guardamos si hay userId
      await _playerService.registerGamePlay(
        userId!, 
        2,
        gameWorld.score, 
        120 - timeRemaining
      );
      
      var stats = await _playerService.getPlayerStats(userId!);
      await _playerService.updateCoins(userId!, stats.coins + coinsEarned);
    }
  }

  void initializeGame() {
    player = Player(
      x: 100,
      y: 100,
      speed: 6.0, // Más rápido que en modo supervivencia
      size: 50.0,
    );

    gameWorld = GameWorld(
      worldSize: const Size(800, 600),
      player: player,
    );
  }

  void startGameLoop() {
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!isGameActive || timeRemaining <= 0) {
        timer.cancel();
        return;
      }

      setState(() {
        gameWorld.update();
        if (timeRemaining > 0 && DateTime.now().second != lastSecond) {
          timeRemaining--;
          lastSecond = DateTime.now().second;
        }
      });
    });
  }

  int lastSecond = DateTime.now().second;

  void handleTap(TapDownDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    
    double dx = localPosition.dx - player.x;
    double dy = localPosition.dy - player.y;
    
    double distance = math.sqrt(dx * dx + dy * dy);  // Usamos math.sqrt aquí también
    if (distance > 0) {
      dx /= distance;
      dy /= distance;
      player.move(dx, dy);
    }

    // Ataque con el pez
    if (player.canAttack) {
      for (var enemy in gameWorld.enemies) {
        if (enemy.isActive && enemy.hitbox.overlaps(player.hitbox)) {
          enemy.isActive = false;
          handleEnemyDefeat();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battle Mode'),
        backgroundColor: const Color.fromRGBO(0, 32, 96, 1),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Time: $timeRemaining s',
              style: const TextStyle(fontSize: 18),
            ),
          ),
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