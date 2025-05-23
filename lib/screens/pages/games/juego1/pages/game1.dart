import 'package:flutter/services.dart';
import '../../../../../dependencias/imports.dart';

class Game1 extends StatefulWidget {
  final int userId;
  final String username;
  final Map<String, dynamic>? savedGameData;

  const Game1({
    Key? key,
    required this.userId,
    required this.username,
    this.savedGameData,
  }) : super(key: key);

  @override
  State<Game1> createState() => _Game1State();
}

class _Game1State extends State<Game1> with TickerProviderStateMixin {
  bool isGameActive = true;
  bool _isFirstBuild = true;
  double worldOffset = 0.0;
  double _currentMovementDirection = 0.0;
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

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isGameActive) setState(() => _gameDuration++);
    });
  }

  void _gameLoop() {
    if (!isGameActive) return;

    final dt = _gameLoopController.lastElapsedDuration?.inMicroseconds ?? 0;
    final dtSeconds = (dt / 1000000.0).clamp(0.016, 0.05);

    setState(() {
      // Actualizar la física del jugador
      _updatePlayerPhysics(dtSeconds);

      // Actualizar la posición del mundo y el jugador
      _updateWorldPosition(dtSeconds);

      // Actualizar animaciones del jugador
      player.updateWalkingAnimation(dtSeconds);

      // Verificar colisiones
      _checkCollisions();
    });
  }

  void _updatePlayerPhysics(double dtSeconds) {
    final groundLevel = ColisionSuelo().obtenerAltura(player, mapa.objetos);

    if (player.isJumping) {
      player.velocidadVertical += player.gravedad * dtSeconds;
      player.y += player.velocidadVertical * dtSeconds;

      // Verificar si el jugador ha aterrizado
      if (player.y >= groundLevel - player.size * 0.5) {
        player.y = groundLevel - player.size * 0.5;
        player.isJumping = false;
        player.velocidadVertical = 0;
        _eventBus.emit(GameEvents.playerLand);
      }
    } else {
      player.y = groundLevel - player.size * 0.5;
    }
  }

  void _updateWorldPosition(double dtSeconds) {
    if (_currentMovementDirection != 0) {
      // Primero, hacer que el jugador se mueva
      player.move(
        _currentMovementDirection,
        0,
        groundLevel: ColisionSuelo().obtenerAltura(player, mapa.objetos),
      );

      double velocidadJugador =
          player.velocidadTemp > 0
              ? player.velocidadTemp
              : (player.isCrouching
                  ? player.velocidadBaseAgachado
                  : player.velocidadBase);

      double desplazamiento =
          _currentMovementDirection * velocidadJugador * dtSeconds;
      double personajeCentro = MediaQuery.of(context).size.width * 0.4;
      double limiteIzquierdo = MediaQuery.of(context).size.width * 0.4;

      if ((worldOffset <= minWorldOffset && _currentMovementDirection < 0) ||
          (worldOffset >= maxWorldOffset && _currentMovementDirection > 0)) {
        player.x += desplazamiento;
        player.x = player.x.clamp(
          limiteIzquierdo, // Usamos el límite izquierdo aquí también
          MediaQuery.of(context).size.width - player.size * 0.5,
        );
      } else {
        worldOffset += desplazamiento;
        worldOffset = worldOffset.clamp(minWorldOffset, maxWorldOffset);
        player.x = personajeCentro;
      }

      distancia += desplazamiento.abs().round();
    } else {
      // Si no hay movimiento, asegurarse de que el jugador esté en estado idle
      player.move(
        0,
        0,
        groundLevel: ColisionSuelo().obtenerAltura(player, mapa.objetos),
      );
    }
  }

  void _checkCollisions() {
    final groundLevel = ColisionSuelo().obtenerAltura(player, mapa.objetos);

    _checkVoidCollision(groundLevel);
    _checkCheckpoints();
    _checkHouseCollision(ColisionCasa());
    _checkCoinCollision(ColisionItem());

    // Optimizar la verificación de objetos en pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final buffer = screenWidth * 0.5;

    for (var obstaculo in mapa.objetos.where((o) {
      final enPantalla =
          (o.x - worldOffset) > -buffer &&
          (o.x - worldOffset) < screenWidth + buffer;
      return enPantalla && o is! MonedaBase;
    })) {
      if (ColisionObstaculo().verificar(player, obstaculo.hitbox)) {
        if (!player.isInvulnerable) {
          setState(() {
            vida -= 10;
            player.isInvulnerable = true;
          });

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => player.isInvulnerable = false);
          });

          if (vida <= 0) {
            _handleGameOver(false);
            break;
          }
        }
      }
    }
  }

  void _checkVoidCollision(double groundLevel) {
    if (player.y > MediaQuery.of(context).size.height + 100 &&
        !player.isInvulnerable) {
      setState(() {
        vida -= 20;
        if (vida <= 0) {
          _handleGameOver(false);
        } else {
          _respawnPlayer(groundLevel);
        }
      });
    }
  }

  void _checkCheckpoints() {
    if (distancia > 0 && distancia % 500 == 0) {
      player.setCheckpoint(player.x, player.y, worldOffset);
      _eventBus.emit(GameEvents.checkpointSet);
    }
  }

  void _checkHouseCollision(ColisionCasa colisionCasa) {
    for (var casa in mapa.casas) {
      if (colisionCasa.verificar(player, casa)) {
        _handleGameOver(true);
        break;
      }
    }
  }

  void _checkCoinCollision(ColisionItem colisionItem) {
    for (var i = mapa.monedas.length - 1; i >= 0; i--) {
      final moneda = mapa.monedas[i];
      if (!moneda.isCollected &&
          colisionItem.verificar(player, moneda.hitbox)) {
        setState(() {
          moneda.isCollected = true;
          monedas += 10; // Corregido: antes era monedas += monedas + 10
          moneda.aplicarEfecto(player);
          mapa.monedas.removeAt(i);
          _eventBus.emit(GameEvents.coinCollected, {'value': moneda.valor});
        });
      }
    }
  }

  void _respawnPlayer(double groundLevel) {
    setState(() {
      if (player.checkpointX != 0) {
        worldOffset = player.checkpointWorldOffset;
        player.respawnAtCheckpoint();
      } else {
        worldOffset = 0;
        player.x = MediaQuery.of(context).size.width / 2;
        player.y = groundLevel - player.size * 0.5;
      }
      player.isJumping = false;
      player.velocidadVertical = 0;
      player.isInvulnerable = true;

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => player.isInvulnerable = false);
        }
      });
    });
  }

  void _setupEventListeners() {
    _eventBus.on(GameEvents.buttonPressed, (data) {
      if (!mounted) return;
      final type = data['type'] as String;

      setState(() {
        switch (type) {
          case 'jump':
            if (!player.isJumping) {
              player.jump();
              if (player.isCrouching) player.crouch();
            }
            break;

          case 'slide':
            player.slide();
            if (player.isCrouching) player.standUp();
            break;

          case 'crouch':
            player.isCrouching ? player.standUp() : player.crouch();
            break;
        }
      });
    });

    _eventBus.on(GameEvents.joystickMoved, (data) {
      if (!mounted) return;
      final dx = data['dx'] as double;

      setState(() {
        _currentMovementDirection = dx;
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
    minWorldOffset = 0;
    maxWorldOffset = 6000 - size.width;
    mapa = Mapa1();

    // Calculamos el nivel del suelo inicial (y=300 es el borde superior de la plataforma)
    double initialGroundLevel = 250;
    double limiteIzquierdo =
        size.width * 0.2; // Límite izquierdo en 20% del ancho de la pantalla

    // Inicializamos el jugador directamente en la posición correcta
    player = Player(x: size.width * 0.4, y: initialGroundLevel);

    // Verificamos la posición con el sistema de colisiones
    final groundLevel = ColisionSuelo().obtenerAltura(player, mapa.objetos);

    if (widget.savedGameData != null) {
      worldOffset = widget.savedGameData!['worldOffset'] ?? 0.0;
      player.x = (widget.savedGameData!['playerX'] ?? size.width * 0.4).clamp(
        limiteIzquierdo,
        size.width - player.size * 0.5,
      );
      player.y =
          widget.savedGameData!['playerY'] ?? (groundLevel - player.size * 0.5);
      monedas = widget.savedGameData!['coins'] ?? 0;
      vida = widget.savedGameData!['health'] ?? 100;
      distancia = widget.savedGameData!['score'] ?? 0;
    } else {
      player.y = groundLevel - player.size * 0.5;
      player.x = player.x.clamp(
        limiteIzquierdo,
        size.width - player.size * 0.5,
      );
    }

    // Asegurarnos de que el jugador nunca esté por debajo del nivel del suelo
    if (player.y > groundLevel - player.size * 0.5) {
      player.y = groundLevel - player.size * 0.5;
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
              _buildParallaxBackground(),
              _buildWorldObjects(),
              _buildPlayer(),
              _buildControls(),
              _buildStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParallaxBackground() {
    // El fondo debe ocupar toda la pantalla y NO moverse con el worldOffset
    return Positioned.fill(
      child: Image.asset(
        'assets/imagenes/fondo.png',
        fit: BoxFit.cover, // Así el fondo ocupa toda la pantalla sin deformarse
      ),
    );
  }

  Widget _buildWorldObjects() {
    return Stack(
      children: [
        ...mapa.objetos
            .where(
              (objeto) =>
                  objeto is! MonedaNormal &&
                  objeto is! MonedaSalto &&
                  objeto is! MonedaVelocidad,
            )
            .map(
              (objeto) => Positioned(
                left: objeto.x - worldOffset,
                top: objeto.y,
                child: Container(
                  width: objeto.width,
                  height: objeto.height,
                  child: Image.asset(objeto.sprite, fit: BoxFit.cover),
                ),
              ),
            ),
        ...mapa.monedas
            .where((m) => !m.isCollected)
            .map(
              (moneda) => Positioned(
                left: moneda.x - worldOffset,
                top: moneda.y,
                child: SizedBox(
                  width: moneda.width,
                  height: moneda.height,
                  child: Image.asset(moneda.sprite, fit: BoxFit.contain),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildPlayer() {
    return Positioned(
      left:
          player.x -
          player.size * 0.5, // Ajustar la posición para centrar el sprite
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

  Widget _buildControls() {
    return Stack(
      children: [
        Positioned(
          left: 40,
          bottom: 40,
          child: ActionButtons(
            onJump:
                () =>
                    _eventBus.emit(GameEvents.buttonPressed, {'type': 'jump'}),
            onSlide:
                () =>
                    _eventBus.emit(GameEvents.buttonPressed, {'type': 'slide'}),
            onCrouch:
                () => _eventBus.emit(GameEvents.buttonPressed, {
                  'type': 'crouch',
                }),
          ),
        ),
        Positioned(
          right: 40,
          bottom: 40,
          child: Joystick(
            onDirectionChanged: (dx, dy) {
              _eventBus.emit(GameEvents.joystickMoved, {'dx': dx, 'dy': dy});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Positioned(
      bottom: 10, // Reducir la distancia desde abajo
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 16,
          ), // Más estrecho
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(15), // Bordes más redondeados
          ),
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width * 0.7, // Ancho máximo del 70%
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centrar contenido
            mainAxisSize: MainAxisSize.min, // Tamaño mínimo necesario
            children: [
              _buildStatItem(Icons.monetization_on, Colors.amber, '$monedas'),
              const SizedBox(width: 20), // Espaciado entre elementos
              _buildStatItem(Icons.favorite, Colors.red, '$vida'),
              const SizedBox(width: 20),
              _buildStatItem(Icons.timer, Colors.blue, '${_gameDuration}s'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Tamaño mínimo
      children: [
        Icon(icon, color: color, size: 18), // Icono más pequeño
        const SizedBox(width: 4), // Espaciado reducido
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14, // Texto más pequeño
            fontWeight: FontWeight.w600, // Semi-bold
          ),
        ),
      ],
    );
  }

  Future<bool> _onWillPop() async {
    isGameActive = false;
    _gameLoopController.stop();

    final shouldSave = await showDialog<bool>(
      context: context,
      barrierDismissible: true, // Cambiado a true para permitir cerrar al hacer clic fuera
      builder: (context) => AlertDialog(
        title: const Text(
          '¿Guardar partida?',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[800],
        content: const Text(
          '¿Deseas guardar tu progreso actual?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Salir sin guardar',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Guardar y salir',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );

    // Si el usuario hizo clic fuera del diálogo, shouldSave será null
    if (shouldSave == null) {
      // Reanudar el juego
      isGameActive = true;
      _gameLoopController.repeat();
      return false; // No salir del juego
    }

    // Solo guardamos si el usuario seleccionó "Guardar y salir"
    if (shouldSave) {
      await _saveGameProgress();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => MenuInicio(
                userId: widget.userId,
                username: widget.username,
                initialStats: PlayerStats(
                  userId: widget.userId,
                  coins: monedas,
                  bestScore: distancia,
                  playTime: _gameDuration,
                ),
              ),
        ),
      );
    }
    return true;
  }

  void _handleGameOver(bool victory) async {
    isGameActive = false;
    _gameLoopController.stop();

    // Calcular puntuación basada en monedas y tiempo
    int puntuacionFinal = 0;
    if (victory) {
      // Base: 1000 puntos por victoria
      puntuacionFinal = 1000;
      
      // Bonus por monedas: 100 puntos por moneda
      puntuacionFinal += monedas * 100;
      
      // Bonus por tiempo: más puntos por completar más rápido
      // Si completa en menos de 60 segundos, obtiene bonus máximo
      int bonusTiempo = _gameDuration <= 60 ? 2000 : 
                        _gameDuration <= 120 ? 1500 :
                        _gameDuration <= 180 ? 1000 : 500;
      puntuacionFinal += bonusTiempo;
    }

    // Guardar progreso independientemente de la victoria o derrota
    await _saveGameProgress(victory: victory, score: puntuacionFinal);
    
    // Actualizar monedas solo si hay victoria
    if (victory) {
      await PlayerService().updatePlayerCoins(
        userId: widget.userId,
        coinsToAdd: monedas,
      );
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        victory: victory,
        coins: monedas,
        score: puntuacionFinal,
        onRetry: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Game1(
              userId: widget.userId,
              username: widget.username,
            ),
          ),
        ),
        onMenu: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MenuInicio(
              userId: widget.userId,
              username: widget.username,
              initialStats: PlayerStats(
                userId: widget.userId,
                coins: monedas,
                bestScore: puntuacionFinal,
                playTime: _gameDuration,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    _gameLoopController.dispose();
    _eventBus.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  // Método auxiliar para guardar progreso
  Future<void> _saveGameProgress({bool victory = false, int score = 0}) async {
    try {
      await PlayerService().saveGameProgress(
        userId: widget.userId,
        gameType: 1,
        score: victory ? score : 0, // Solo guardar puntuación si hay victoria
        coins: monedas,
        victory: victory,
        duration: _gameDuration,
        worldOffset: worldOffset,
        playerX: player.x,
        playerY: player.y,
        health: vida,
        currentLevel: 1,
      );
    } catch (e) {
      debugPrint('Error saving game: $e');
    }
  }
}
