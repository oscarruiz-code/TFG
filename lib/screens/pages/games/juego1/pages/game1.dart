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
    // Detener la música al iniciar el juego
    final MusicService _musicService = MusicService();
    _musicService.stopBackgroundMusic();
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
    // Posicionar el jugador en el centro
    player = Player(
      x: size.width * 0.5, // Cambiado de 0.2 a 0.5 para centrarlo
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

          // Verificar colisiones con el suelo
          bool enSuelo = gestorColisiones.verificarColisionSuelo(player, mapa.suelos);
          double alturaDelSuelo = gestorColisiones.obtenerAlturaDelSuelo(player, mapa.suelos);
          
          if (enSuelo && player.velocidadVertical >= 0) {
            player.y = alturaDelSuelo - player.size * 0.5;
            player.handleCollision('ground');
          } else if (!enSuelo && !player.isJumping) {
            player.isJumping = true;
            player.velocidadVertical = 0;
          }

          // Actualizar el offset del mundo basado en la posición del jugador
          if (player.currentState == PenguinPlayerState.walking ||
              player.currentState == PenguinPlayerState.sliding ||
              (player.isJumping && player.lastMoveDirection != 0)) {
          
          // Calcular el centro de la pantalla
          final screenCenter = MediaQuery.of(context).size.width * 0.5;
          // Calcular cuánto debe moverse el mundo para mantener al jugador centrado
          final targetOffset = -(player.x - screenCenter);
          
          // Suavizar el movimiento
          worldOffset += (targetOffset - worldOffset) * 0.1;
          // Mantener el offset dentro de los límites
          worldOffset = worldOffset.clamp(minWorldOffset, maxWorldOffset);
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
          // Eliminamos el color de debug
          // color: Colors.blue.withOpacity(0.3),
          width: objeto.width,
          height: objeto.height,
          child: Image.asset(
            objeto.sprite,
            width: objeto.width,
            height: objeto.height,
            fit: BoxFit.cover, // Cambiado de fill a cover para mejor unión
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
          left: 20, // Ajustado más a la izquierda
          bottom: 20,
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
          right: 20, // Ajustado más a la derecha
          bottom: 20,
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
      bottom: 10, // Más pegado al borde inferior
      left: MediaQuery.of(context).size.width * 0.2, // 20% desde la izquierda
      right: MediaQuery.of(context).size.width * 0.2, // 20% desde la derecha
      child: Container(
        height: 30, // Altura reducida para hacerla más fina
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                const SizedBox(width: 5),
                Text(
                  '$monedas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              height: 20,
              width: 1,
              color: Colors.white.withOpacity(0.3),
            ),
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 20),
                const SizedBox(width: 5),
                Text(
                  '$vida',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              height: 20,
              width: 1,
              color: Colors.white.withOpacity(0.3),
            ),
            Row(
              children: [
                const Icon(Icons.speed, color: Colors.blue, size: 20),
                const SizedBox(width: 5),
                Text(
                  '$distancia m',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
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