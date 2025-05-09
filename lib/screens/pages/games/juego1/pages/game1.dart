import 'package:flutter/services.dart';
import '../../../../../dependencias/imports.dart';

class Game1 extends StatefulWidget {
  const Game1({Key? key}) : super(key: key);

  @override
  State<Game1> createState() => _Game1State();
}

class _Game1State extends State<Game1> {
  late Player player;
  late GestorColisiones gestorColisiones;
  double groundLevel = 0.0;
  bool isGameActive = true;
  bool _isFirstBuild = true;
  double worldOffset = 0.0;
  late double maxWorldOffset;
  late double minWorldOffset;
  final GameEventBus _eventBus = GameEventBus();
  
  int monedas = 0;
  int vida = 100;
  int distancia = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    gestorColisiones = GestorColisiones();
    _setupEventListeners();
  }

  void _setupEventListeners() {
    _eventBus.on(GameEvents.playerJump, (_) {
      // Reproducir sonido de salto
      // TODO: Implementar sonido de salto
    });

    _eventBus.on(GameEvents.playerSlide, (_) {
      // Reproducir sonido de deslizamiento
      // TODO: Implementar sonido de deslizamiento
    });

    _eventBus.on(GameEvents.playerCollision, (data) {
      setState(() {
        if (data['type'] == 'damage') {
          vida = (vida - (data['amount'] as int)).clamp(0, 100);
        }
      });
    });

    _eventBus.on(GameEvents.playerMove, (data) {
      setState(() {
        if (data['type'] == 'coin') {
          monedas++;
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      _isFirstBuild = false;
      _initializeGame();
    }
  }

  void _initializeGame() {
    final size = MediaQuery.of(context).size;
    groundLevel = size.height - 80;
    maxWorldOffset = 0;
    minWorldOffset = -(size.width * 4);
    player = Player(
      x: size.width * 0.5,
      y: groundLevel - (Player.defaultHeight * 0.3),
    );
    _startGameLoop();
  }

  Widget _buildBackground() {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/imagenes/juego.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(worldOffset, 0),
          child: Container(
            width: size.width * 5,
            height: size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/imagenes/juego.png'),
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeatX,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF87CEEB),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _startGameLoop() {
    Future.delayed(const Duration(milliseconds: 16), () {
      if (mounted && isGameActive) {
        setState(() {
          player.updateAnimation(0.016);
          
          if (player.currentState == PenguinPlayerState.walking ||
              player.currentState == PenguinPlayerState.sliding ||
              (player.isJumping && player.lastMoveDirection != 0)) {
            if (player.isFacingRight) {
              worldOffset = (worldOffset - player.speed * 0.5).clamp(minWorldOffset, maxWorldOffset);
            } else {
              worldOffset = (worldOffset + player.speed * 0.5).clamp(minWorldOffset, maxWorldOffset);
            }
          }
          
          if (gestorColisiones.verificarColisionSuelo(player, groundLevel)) {
            player.y = groundLevel - (player.size * 0.5);
            if (player.isJumping) {
              player.isJumping = false;
              player.velocidadVertical = 0;
              if (player.currentState == PenguinPlayerState.jumping) {
                player.currentState = player.lastMoveDirection != 0 ? 
                  PenguinPlayerState.walking : PenguinPlayerState.idle;
              }
              _eventBus.emit(GameEvents.playerLand);
            }
          }

          // Actualizar distancia recorrida
          if (player.currentState == PenguinPlayerState.walking ||
              player.currentState == PenguinPlayerState.sliding) {
            distancia += (player.speed * 0.5).round();
            _eventBus.emit(GameEvents.distanceUpdated, {'distance': distancia});
          }
        });
        _startGameLoop();
      }
    });
  }

  Widget _buildPlayer() {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.5,
      top: player.y,
      child: Transform.scale(
        scaleX: player.isFacingRight ? 0.7 : -0.7,
        scaleY: 0.7,
        child: Image.asset(
          player.getCurrentSprite(),
          width: player.size * 0.8,
          height: player.size * 0.8,
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Stack(
      children: [
        Positioned(
          left: 50,
          bottom: 30,
          child: ActionButtons(
            onJump: () => setState(() {
              player.jump();
              _eventBus.emit(GameEvents.buttonPressed, {'type': 'jump'});
            }),
            onSlide: () => setState(() {
              if (!player.isSliding) {
                player.slide();
                _eventBus.emit(GameEvents.buttonPressed, {'type': 'slide'});
              }
            }),
          ),
        ),
        Positioned(
          right: 50,
          bottom: 30,
          child: Joystick(
            onDirectionChanged: (dx, dy) {
              setState(() {
                player.move(dx, 0, groundLevel: groundLevel);
                _eventBus.emit(GameEvents.joystickMoved, {'dx': dx, 'dy': dy});
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Positioned(
      bottom: 5,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 16),
              const SizedBox(width: 2),
              Text('$vida', style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(width: 10),
              const Icon(Icons.star, color: Colors.yellow, size: 16),
              const SizedBox(width: 2),
              Text('$monedas', style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(width: 10),
              const Icon(Icons.speed, color: Colors.blue, size: 16),
              const SizedBox(width: 2),
              Text('${distancia}m', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildPlayer(),
          _buildControls(),
          _buildStats(),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    isGameActive = false;
    // Limpiar listeners de eventos usando la instancia existente
    _eventBus.off(GameEvents.playerJump, (_) {});
    _eventBus.off(GameEvents.playerSlide, (_) {});
    _eventBus.off(GameEvents.playerCollision, (_) {});
    _eventBus.off(GameEvents.playerMove, (_) {});
    _eventBus.off(GameEvents.playerLand, (_) {});
    _eventBus.off(GameEvents.buttonPressed, (_) {});
    _eventBus.off(GameEvents.joystickMoved, (_) {});
    _eventBus.off(GameEvents.distanceUpdated, (_) {});
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}