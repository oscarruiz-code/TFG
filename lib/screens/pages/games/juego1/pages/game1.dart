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
      // Actualizar la física del jugador
      if (player.isJumping) {
        player.velocidadVertical += player.gravedad * dtSeconds;
        player.y += player.velocidadVertical * dtSeconds;
      }
      
      player.animationTime += dtSeconds;
      _checkCollisions();
      
      // Emitir evento de actualización de distancia
      _eventBus.emit(GameEvents.distanceUpdated, {'distancia': distancia});
    });
  }

  void _checkCollisions() {
    final gestorColisiones = GestorColisiones();
    // Ajustamos la posición del jugador con el worldOffset para las colisiones
    player.x = MediaQuery.of(context).size.width / 2 - worldOffset;
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
      if (!mounted) return;
      if (data['type'] == 'jump') {
        setState(() {
          player.jump();
          if (player.isCrouching) {
            player.crouch();
          }
        });
      } else if (data['type'] == 'slide') {
        setState(() {
          player.slide();
          if (player.isCrouching) {
            player.standUp();
          }
        });
      } else if (data['type'] == 'crouch') {
        setState(() {
          if (player.isCrouching) {
            player.standUp();
          } else {
            player.crouch();
          }
        });
      }
    });

    _eventBus.on(GameEvents.joystickMoved, (data) {
      if (!mounted) return;
      final dx = data['dx'] as double;
      final dy = data['dy'] as double;
      
      setState(() {
        if (dx != 0) {
          worldOffset += dx * -5;
          worldOffset = worldOffset.clamp(minWorldOffset, maxWorldOffset);
        }
        
        distancia = (-worldOffset ~/ 100).abs();
        
        final groundLevel = GestorColisiones().obtenerAlturaDelSuelo(player, mapa.objetos);
        player.move(dx, dy, groundLevel: groundLevel);
      });
    });
  }

  Widget _buildMapObjects() {
    return Stack(
      children: mapa.objetos.map((objeto) {
        // Obtener el hitbox real del objeto
        final hitbox = objeto.hitbox;
        return Stack(
          children: [
            // Hitbox del suelo (visualización)
            Positioned(
              left: hitbox.left + worldOffset,  // Usar la posición real del hitbox
              top: hitbox.top,  // Usar la posición real del hitbox
              child: Container(
                width: hitbox.width,  // Usar el ancho real del hitbox
                height: hitbox.height,  // Usar el alto real del hitbox
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  border: Border.all(
                    color: Colors.blue,
                    width: 1,
                  ),
                ),
              ),
            ),
            // Sprite del suelo
            Positioned(
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
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPlayer() {
    final playerCenterX = MediaQuery.of(context).size.width / 2;
    return Stack(
      children: [
        // Hitbox del jugador (visualización)
        Positioned(
          left: playerCenterX - player.size * 0.46, // Ajustado para coincidir con el sprite
          top: player.y - player.size * 0.45, // Ajustado para coincidir con el sprite
          child: Container(
            width: player.size * 0.85,
            height: player.size * (player.isSliding ? 0.4 : 0.94),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.3),
              border: Border.all(
                color: Colors.red,
                width: 1,
              ),
            ),
          ),
        ),
        // Sprite del jugador
        Positioned(
          left: playerCenterX - player.size * 0.5,
          top: player.y - player.size * 0.5,
          child: Transform.scale(
            scaleX: player.isFacingRight ? 1 : -1,
            child: Image.asset(
              player.getCurrentSprite(),
              width: player.size,
              height: player.size,
            ),
          ),
        ),
      ],
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
      left: MediaQuery.of(context).size.width * 0.35, // Reducido de 0.4 a 0.35
      right: MediaQuery.of(context).size.width * 0.35, // Reducido de 0.4 a 0.35
      child: Container(
        height: 30, // Aumentado de 25 a 30
        padding: const EdgeInsets.symmetric(horizontal: 20), // Aumentado de 15 a 20
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20), // Aumentado de 15 a 20
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
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20), // Aumentado de 18 a 20
                const SizedBox(width: 5),
                Text(
                  '$monedas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14, // Aumentado de 12 a 14
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              height: 20, // Aumentado de 15 a 20
              width: 1,
              color: Colors.white.withOpacity(0.3),
            ),
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 20), // Aumentado de 18 a 20
                const SizedBox(width: 5),
                Text(
                  '$vida',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14, // Aumentado de 12 a 14
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
    minWorldOffset = -6000; // Ajustado al tamaño real del mapa
    mapa = Mapa1();
    
    player = Player(
      x: size.width / 2,
      y: size.height - 50, // Reducido de 60 a 45 para mantener la proporción
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
    // Remover todos los event listeners
    _eventBus.off(GameEvents.buttonPressed, (_) {});
    _eventBus.off(GameEvents.joystickMoved, (_) {});
    _eventBus.off(GameEvents.distanceUpdated, (_) {});

    // Restaurar la orientación
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}