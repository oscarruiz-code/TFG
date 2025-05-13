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
  late Mapa1 mapa;

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
      // Sonido de salto
    });

    _eventBus.on(GameEvents.playerSlide, (_) {
      // Sonido de deslizamiento
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
    groundLevel = size.height * 0.8;
    maxWorldOffset = 0;
    minWorldOffset = -(size.width * 4);
    player = Player(
      x: size.width * 0.2,
      y: groundLevel - Player.defaultHeight * 1.5,
    );
    mapa = Mapa1();
    _startGameLoop();
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
              worldOffset = (worldOffset - player.speed * 0.3).clamp(minWorldOffset, maxWorldOffset);
            } else {
              worldOffset = (worldOffset + player.speed * 0.3).clamp(minWorldOffset, maxWorldOffset);
            }
          }

          final playerFeet = player.y + player.size * 0.5;
          final playerCenterX = player.x - worldOffset;
          var sueloDebajo = mapa.objetos.firstWhere(
            (obj) =>
              playerCenterX + player.size * 0.4 > obj.x &&
              playerCenterX - player.size * 0.4 < obj.x + obj.width &&
              (playerFeet >= obj.y && playerFeet <= obj.y + obj.height + 10),
            orElse: () => null,
          );

          if (sueloDebajo != null) {
            double sueloTop = sueloDebajo.y;
            if (player.y + player.size * 0.5 > sueloTop &&
                player.velocidadVertical >= 0) {
              player.y = sueloTop - player.size * 0.5;
              player.velocidadVertical = 0;
              if (player.isJumping) {
                player.isJumping = false;
                if (player.currentState == PenguinPlayerState.jumping) {
                  player.currentState = player.lastMoveDirection != 0
                      ? PenguinPlayerState.walking
                      : PenguinPlayerState.idle;
                }
                _eventBus.emit(GameEvents.playerLand);
              }
            }
          } else {
            player.isJumping = true;
          }

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

  Widget _buildMapObjects() {
    return Stack(
      children: mapa.objetos.map((objeto) {
        return Positioned(
          left: objeto.x + worldOffset,
          top: objeto.y,
          child: Container(
            color: Colors.blue.withOpacity(0.3),
            width: objeto.width,
            height: objeto.height,
            child: Image.asset(
              objeto.sprite,
              width: objeto.width,
              height: objeto.height,
              fit: BoxFit.fill,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayer() {
    return Positioned(
      left: player.x,
      top: player.y,
      child: Container(
        color: Colors.red.withOpacity(0.3),
        child: Transform.scale(
          scaleX: player.isFacingRight ? 0.7 : -0.7,
          scaleY: 0.7,
          child: Image.asset(
            player.getCurrentSprite(),
            width: player.size * 0.8,
            height: player.size * 0.8,
          ),
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
      top: 20,
      left: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monedas: $monedas', style: const TextStyle(color: Colors.white)),
          Text('Vida: $vida', style: const TextStyle(color: Colors.white)),
          Text('Distancia: $distancia', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blueGrey[900],
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/imagenes/fondo.png',
                fit: BoxFit.cover,
              ),
            ),
            _buildMapObjects(),
            _buildPlayer(),
            _buildControls(),
            _buildStats(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    isGameActive = false;
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