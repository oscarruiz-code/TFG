import 'package:flutter/services.dart';
import '../../../../../dependencias/imports.dart';

class Game1 extends StatefulWidget {
  const Game1({Key? key}) : super(key: key);

  @override
  State<Game1> createState() => _Game1State();
}

class _Game1State extends State<Game1> with TickerProviderStateMixin {
  bool isGameActive = true;
  bool _isFirstBuild = true;
  double worldOffset = 0.0;
  late double maxWorldOffset;
  late double minWorldOffset;
  final GameEventBus _eventBus = GameEventBus();
  late Mapa1 mapa;
  late Player player;
  late AnimationController _gameLoopController;
  
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
    final MusicService _musicService = MusicService();
    _musicService.stopBackgroundMusic();
    _setupEventListeners();
    
    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    
    _gameLoopController.addListener(_gameLoop);
  }

  void _gameLoop() {
    if (!isGameActive) return;
    
    final dt = _gameLoopController.lastElapsedDuration?.inMicroseconds ?? 0;
    final dtSeconds = dt / 1000000.0;
    
    setState(() {
      player.updateAnimation(dtSeconds);
      _checkCollisions();
    });
  }

  void _checkCollisions() {
    final gestorColisiones = GestorColisiones();
    final groundLevel = gestorColisiones.obtenerAlturaDelSuelo(player, mapa.objetos);
    
    if (player.isJumping) {
      if (player.y + player.size * 0.5 >= groundLevel) {
        player.y = groundLevel - player.size * 0.5;
        player.isJumping = false;
        player.velocidadVertical = 0;
        _eventBus.emit(GameEvents.playerLand);
      }
    } else {
      player.y = groundLevel - player.size * 0.5;
    }
  }

  void _setupEventListeners() {
    _eventBus.on(GameEvents.buttonPressed, (data) {
      if (data['type'] == 'jump') {
        player.jump();
      } else if (data['type'] == 'slide') {
        player.slide();
      } else if (data['type'] == 'crouch') {
        player.crouch();
      }
    });

    _eventBus.on(GameEvents.joystickMoved, (data) {
      final dx = data['dx'] as double;
      final dy = data['dy'] as double;
      final groundLevel = GestorColisiones().obtenerAlturaDelSuelo(player, mapa.objetos);
      player.move(dx, dy, groundLevel: groundLevel);
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
    maxWorldOffset = 0;
    minWorldOffset = -(size.width * 4);
    mapa = Mapa1();
    
    // Inicializar el jugador en el centro de la pantalla
    player = Player(
      x: size.width / 2,
      y: size.height - 100,
    );
  }

  Widget _buildPlayer() {
    return Positioned(
      left: player.x - player.size * 0.5,
      top: player.y - player.size * 0.5,
      child: Transform.scale(
        scaleX: player.isFacingRight ? 1 : -1,
        child: Image.asset(
          player.getCurrentSprite(),
          width: player.size,
          height: player.size,
        ),
      ),
    );
  }

  Widget _buildMapObjects() {
    return Stack(
      children: mapa.objetos.map((objeto) {
        return Positioned(
          left: objeto.x + worldOffset,
          top: objeto.y,
          child: Container(
            width: objeto.width,
            height: objeto.height,
            child: Image.asset(
              objeto.sprite,
              width: objeto.width,
              height: objeto.height,
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildControls() {
    return Stack(
      children: [
        Positioned(
          left: 40,
          bottom: 40,
          child: ActionButtons(
            onJump: () => setState(() {
              _eventBus.emit(GameEvents.buttonPressed, {'type': 'jump'});
            }),
            onSlide: () => setState(() {
              _eventBus.emit(GameEvents.buttonPressed, {'type': 'slide'});
            }),
            onCrouch: () => setState(() {
              _eventBus.emit(GameEvents.buttonPressed, {'type': 'crouch'});
            }),
          ),
        ),
        Positioned(
          right: 40,
          bottom: 40,
          child: Joystick(
            onDirectionChanged: (dx, dy) {
              setState(() {
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
      bottom: 20,
      left: MediaQuery.of(context).size.width * 0.3,
      right: MediaQuery.of(context).size.width * 0.3,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
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
    _gameLoopController.dispose();
    _eventBus.off(GameEvents.buttonPressed, (_) {});
    _eventBus.off(GameEvents.joystickMoved, (_) {});

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}