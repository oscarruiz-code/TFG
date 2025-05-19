import 'package:flutter/services.dart';
import '../../../../../dependencias/imports.dart';

class Game1 extends StatefulWidget {
  final int userId;  // Añadimos la propiedad userId
  final Map<String, dynamic>? savedGameData;  // Añadimos este parámetro
  
  const Game1({
    Key? key,
    required this.userId,  // Requerimos el userId en el constructor
    this.savedGameData,  // Parámetro opcional para datos guardados
  }) : super(key: key);

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
  int _gameDuration = 0;
  late Timer _gameTimer;

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
    
    // Iniciar el temporizador del juego
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isGameActive) {
        setState(() {
          _gameDuration++;
        });
      }
    });
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
        
        // Obtener el nivel del suelo actual
        final groundLevel = GestorColisiones().obtenerAlturaDelSuelo(player, mapa.objetos);
        
        // Verificar si el jugador ha tocado el suelo
        if (player.y + player.size * 0.5 >= groundLevel) {
          player.y = groundLevel - player.size * 0.5;
          player.isJumping = false;
          player.velocidadVertical = 0;
          _eventBus.emit(GameEvents.playerLand);
        }
      }
      
      player.animationTime += dtSeconds;
      _checkCollisions();
      
      // Emitir evento de actualización de distancia
      _eventBus.emit(GameEvents.distanceUpdated, {'distancia': distancia});
    });
  }

  void _checkCollisions() {
    final gestorColisiones = GestorColisiones();
    player.x = MediaQuery.of(context).size.width / 2 - worldOffset;
    final groundLevel = gestorColisiones.obtenerAlturaDelSuelo(player, mapa.objetos);
    
    // Verificar si el jugador cayó al vacío
    if (player.y > MediaQuery.of(context).size.height + 50) {
      vida -= 20;
      if (vida <= 0) {
        _handleGameOver(false);
      } else {
        // Reproducir sonido de daño si lo tienes
        setState(() {
          if (player.checkpointX != 0) {
            worldOffset = player.checkpointWorldOffset;
            player.respawnAtCheckpoint();
          } else {
            worldOffset = 0;
            player.x = MediaQuery.of(context).size.width / 2;
            player.y = groundLevel - player.size * 0.5;
            player.isJumping = false;
            player.velocidadVertical = 0;
          }
          // Añadir efecto visual de daño
          player.isInvulnerable = true;
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                player.isInvulnerable = false;
              });
            }
          });
        });
      }
      return;
    }

    // Establecer checkpoints automáticos cada cierta distancia
    if (distancia > 0 && distancia % 500 == 0) { // Cada 500 unidades de distancia
      player.setCheckpoint(player.x, player.y, worldOffset);
    }
    
    // Verificar colisión con la casa
    for (var casa in mapa.casas) {
      if (gestorColisiones.verificarColisionCasa(player, casa)) {
        _handleGameOver(true);
        return;
      }
    }

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
    // Verificar colisión con monedas
    for (var moneda in mapa.monedas) {
      if (!moneda.isCollected && gestorColisiones.verificarColisionItem(player, moneda.hitbox)) {
        setState(() {
          moneda.isCollected = true;
          moneda.aplicarEfecto(player);
        });
      }
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
    
    if (widget.savedGameData != null) {
      // Cargar datos guardados
      worldOffset = widget.savedGameData!['worldOffset'] ?? 0.0;
      monedas = widget.savedGameData!['coins'] ?? 0;
      vida = widget.savedGameData!['health'] ?? 100;
      distancia = widget.savedGameData!['score'] ?? 0;
      
      player = Player(
        x: widget.savedGameData!['playerX'] ?? size.width / 2,
        y: widget.savedGameData!['playerY'] ?? size.height - 50,
      );
    } else {
      // Inicialización normal
      player = Player(
        x: size.width / 2,
        y: size.height - 50,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
      ),
    );
  }

  Future<bool> _onWillPop() async {
    isGameActive = false;
    _gameLoopController.stop();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(0, 32, 96, 1),
        title: const Text('¿Guardar partida?', style: TextStyle(color: Colors.white)),
        content: const Text('¿Deseas guardar tu progreso? Cuidado sobrescribirá la partida guardada anterior.', 
          style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('No guardar', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (result == true) {
      final PlayerService playerService = PlayerService();
      await playerService.saveGameProgress(
        userId: widget.userId,
        gameType: 1,
        score: distancia,
        coins: monedas,
        victory: false,
        duration: _gameDuration,
        worldOffset: worldOffset,
        playerX: player.x,
        playerY: player.y,
        health: vida
      );
      
      if (!mounted) return true;
      Navigator.of(context).pushReplacementNamed('/menuinicio');
      return true;
    } else if (result == false) {
      if (!mounted) return true;
      Navigator.of(context).pushReplacementNamed('/menuinicio');
      return true;
    }

    setState(() {
      isGameActive = true;
      _gameLoopController.repeat();
    });
    return false;
  }

  @override
  void dispose() {
    _gameTimer.cancel();
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

  void _handleGameOver(bool victory) async {
    final PlayerService playerService = PlayerService();
    
    // Detener el juego
    isGameActive = false;
    _gameLoopController.stop();

    // Guardar el progreso
    await playerService.saveGameProgress(
      userId: widget.userId, 
      gameType: 1,
      score: distancia,
      coins: monedas,
      victory: victory,
      duration: _gameDuration,
      worldOffset: worldOffset,
      playerX: player.x,
      playerY: player.y,
      health: vida
    );

    if (victory) {
      // Actualizar monedas del jugador
      await playerService.updatePlayerCoins(
        userId: widget.userId,
        coinsToAdd: monedas
      );
    }

    // Mostrar diálogo de resultado
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.blue.withOpacity(0.7),
              width: 2,
            ),
          ),
          title: Text(
            victory ? '¡Victoria!' : 'Game Over',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Distancia recorrida: $distancia',
                  style: const TextStyle(color: Colors.white, fontSize: 18)
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/personajes/items/monedas/monedacoin.png',
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Monedas: $monedas',
                      style: const TextStyle(color: Colors.white, fontSize: 18)
                    ),
                  ],
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            _buildGameOverButton('Reintentar', () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Game1(userId: widget.userId))
              );
            }),
            _buildGameOverButton('Menú Principal', () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }),
          ],
        ),
      );
    }
  }
}

  Widget _buildGameOverButton(String text, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.withOpacity(0.6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: Colors.white.withOpacity(0.7),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
