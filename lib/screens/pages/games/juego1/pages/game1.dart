import 'package:flutter/services.dart';
import 'dart:convert';
import '../../../../../dependencias/imports.dart';

/// Implementa el primer juego de la aplicación, un plataformas 2D con un pingüino como protagonista.
///
/// Esta clase gestiona todo el ciclo de vida del juego, incluyendo:
/// - Inicialización y carga de datos guardados
/// - Sistema de calibración inicial para optimizar el rendimiento
/// - Bucle de juego con física, colisiones y animaciones
/// - Controles táctiles (joystick y botones de acción)
/// - Recolección de monedas y power-ups
/// - Guardado de progreso y puntuaciones
/// - Gestión de estados de victoria y derrota

class Game1 extends StatefulWidget {
  final int userId;
  final String username;
  final Map<String, dynamic>? savedGameData;
  final bool precargado;

  const Game1({
    super.key,
    required this.userId,
    required this.username,
    this.savedGameData,
    this.precargado = false,
  });

  @override
  State<Game1> createState() => _Game1State();
}

/// Estado interno del juego que implementa la lógica principal y la interfaz de usuario.
///
/// Utiliza [TickerProviderStateMixin] para gestionar las animaciones y el bucle de juego.
/// Implementa un sistema de eventos para la comunicación entre componentes.
class _Game1State extends State<Game1> with TickerProviderStateMixin {
  bool isGameActive = true;
  bool _isInitialized = false;
  bool _isFullyWarmedUp =
      false; // Nueva variable para el calentamiento completo
  bool _showReadyMessage = false; // Variable para mostrar el mensaje de listo
  double worldOffset = 0.0;
  double _currentMovementDirection = 0.0;
  int monedas = 0;
  int vida = 100;
  int distancia = 0;
  int _gameDuration = 0;
  int _movementCounter = 0; // Contador para el movimiento del jugador
  double _maxCalibrationOffset =
     700.0; // Límite para la calibración (hasta el último suelo inicial)

  List<Map<String, double>> collectedCoinsPositions = [];

  late double maxWorldOffset;
  late double minWorldOffset;
  late Player player;
  late AnimationController _gameLoopController;
  late Mapa1 mapa;
  late Timer _gameTimer;
  late ColisionManager _colisionManager;

  final GameEventBus _eventBus = GameEventBus();

  @override
  void initState() {
    super.initState();
    // Optimizar el rendimiento de Flutter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Usar un modo de renderizado más eficiente
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
    _initializeGame();
  }

  /// Inicializa el juego configurando la orientación de pantalla, límites del mundo,
  /// carga de datos guardados, y preparación de componentes como el mapa y el jugador.
  void _initializeGame() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Inicializar los límites del mundo
    minWorldOffset = 0.0;
    maxWorldOffset = 6000.0;
    
    // Reducir el límite de calibración
    _maxCalibrationOffset;

    List<Map<String, double>>? savedCoinsPositions;
    if (widget.savedGameData != null) {
      String? savedPositions;
      if (widget.savedGameData!['collected_coins_positions'] != null) {
        var blob = widget.savedGameData!['collected_coins_positions'];
        debugPrint('Tipo de dato: ${blob.runtimeType}');

        // Manejar diferentes tipos de datos
        if (blob is Uint8List) {
          savedPositions = String.fromCharCodes(blob);
        } else if (blob is String) {
          savedPositions = blob;
        } else if (blob is Blob) {
          // Convertir Blob a String
          savedPositions = blob.toString();
        }
      }

      if (savedPositions != null) {
        try {
          // Si savedPositions contiene caracteres de escape adicionales, limpiarlo
          if (savedPositions.startsWith('"') && savedPositions.endsWith('"')) {
            savedPositions = savedPositions.substring(
              1,
              savedPositions.length - 1,
            );
          }

          List<dynamic> positions = jsonDecode(savedPositions);
          savedCoinsPositions =
              positions
                  .map(
                    (pos) => {
                      'x':
                          (pos['x'] is num)
                              ? (pos['x'] as num).toDouble()
                              : 0.0,
                      'y':
                          (pos['y'] is num)
                              ? (pos['y'] as num).toDouble()
                              : 0.0,
                    },
                  )
                  .toList();
        } catch (e) {
          savedCoinsPositions = [];
        }
      }
    }

    // Inicializar el mapa con carga progresiva
    mapa = Mapa1(collectedCoinsPositions: savedCoinsPositions);
    MusicService().stopBackgroundMusic();
    
    // Inicializar el servicio de efectos de sonido
    SoundEffectService().initialize();
    
    _setupEventListeners();

    // Cargar datos guardados si existen
    if (widget.savedGameData != null) {
      worldOffset =
          (widget.savedGameData!['world_offset'] as num?)?.toDouble() ?? 0.0;
      monedas = widget.savedGameData!['coins_collected'] as int? ?? 0;
      vida = widget.savedGameData!['health'] as int? ?? 100;
      _gameDuration = widget.savedGameData!['duration'] as int? ?? 0;

      // Inicializar el jugador con la posición guardada
      player = Player(
        x: (widget.savedGameData!['position_x'] as num?)?.toDouble() ?? 0.0,
        y: (widget.savedGameData!['position_y'] as num?)?.toDouble() ?? 200.0,
        size: 50,
        isFacingRight: true,
      );

      // Saltarse la fase de calibración cuando se carga una partida guardada
      _isFullyWarmedUp = true;
    } else {
      // Inicialización normal para nueva partida
      player = Player(x: 0, y: 200, size: 50, isFacingRight: true);
      _gameDuration = 0;

    }

    // Inicializar el collision manager con valores iniciales
    _colisionManager = ColisionManager(player, mapa, worldOffset);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;

      setState(() {
        // Solo actualizar la posición si es una nueva partida
        if (widget.savedGameData == null) {
          player.x = size.width * 0.4;
        }

        _gameLoopController =
            AnimationController(
                vsync: this,
                duration: const Duration(
                  milliseconds: 16,
                ), 
              )
              ..repeat()
              ..addListener(_gameLoop);

        _isInitialized = true;
      });
    });

    // Inicializar el timer con el tiempo guardado ya cargado anteriormente
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Solo incrementar si el juego está activo Y completamente inicializado Y completamente calibrado
      if (isGameActive && _isInitialized && _isFullyWarmedUp) {
        setState(() {
          _gameDuration++;
        });
      }
    });
  }

  // Modificar el método _gameLoop para cambiar la duración de la calibración
  /// Bucle principal del juego que se ejecuta en cada frame.
  /// 
  /// Gestiona la detección de colisiones, física, movimiento del jugador,
  /// y la fase de calibración inicial para optimizar el rendimiento.
  void _gameLoop() {
    if (!isGameActive || !_isInitialized) return;

    final dt = _gameLoopController.lastElapsedDuration?.inMicroseconds ?? 0;
    final dtSeconds = (dt / 1000000.0).clamp(0.008, 0.032);

    // Optimizar la detección de colisiones
    _colisionManager.updateWorldOffset(worldOffset);
    
    // Solo verificar colisiones para objetos cercanos al jugador
    final collisionResult = _colisionManager.checkCollisions();

    // Procesar las colisiones
    _handleCollisions(collisionResult);
    
    // Sincronizar los valores de power-up en cada frame
    player.velocidadTemp = player.powerUp.velocidadTemp;
    player.fuerzaSaltoTemp = player.powerUp.fuerzaSaltoTemp;

    // Acelerar la fase de calibración
    if (!_isFullyWarmedUp) {
      if (_currentMovementDirection != 0) {
        _movementCounter += 5; // Incremento más rápido
        if (_movementCounter >= 300) { // Umbral más bajo
        
          setState(() {
            _showReadyMessage = true;
          });

          // Terminar la calibración más rápido
      Future.delayed(const Duration(milliseconds: 2000), () { // Reducido a 2 segundos
        if (mounted) {
          setState(() {
            _isFullyWarmedUp = true;
            _showReadyMessage = false;
            
            // Resetear el joystick al centro cuando termina la calibración
            _currentMovementDirection = 0;
            _eventBus.emit(GameEvents.joystickMoved, {'dx': 0.0, 'dy': 0.0});
            
            // Emitir evento para iniciar la música de fondo cuando la calibración termina
            _eventBus.emit('gameStarted');
          });
        }
      });
        }
      }
    }

    setState(() {
      // Aplicar física antes de mover
      _applyPhysics(collisionResult, dtSeconds);

      // Mover el jugador después de la física
      player.move(
        _currentMovementDirection,
        0,
        groundLevel: collisionResult.groundLevel,
      );

      // Actualizar posición del mundo y animaciones
      _updateWorldPosition(dtSeconds, collisionResult);
      player.updateWalkingAnimation(dtSeconds);
    });
  }

  /// Aplica la física del juego, incluyendo gravedad y colisiones con el suelo.
  /// 
  /// @param result Resultado de las colisiones detectadas
  /// @param dtSeconds Delta de tiempo en segundos desde el último frame
  void _applyPhysics(CollisionResult result, double dtSeconds) {
    // Aplicar gravedad si está en el aire
    if (!player.isOnGround) {
      player.velocidadVertical += player.gravedad * dtSeconds;
      player.y += player.velocidadVertical * dtSeconds;
    }

    // Verificar colisión con el suelo
    if (result.groundLevel != double.infinity) {
      // Calcular el factor de ajuste vertical según el estado del jugador
      double verticalAdjustment = 0.5; // Factor por defecto cambiado a 0.15
      
      if (player.isSliding && player.isCrouching) {
        // Para cuando está agachado y deslizándose
        verticalAdjustment = 0.35; // Cambiado de 0.15 a 0.35
      } else if (player.isCrouching) {
        // Para cuando está agachado pero no deslizándose
        verticalAdjustment = 0.35; // Se mantiene en 0.35
      }
      
      if (player.y + player.size * verticalAdjustment >= result.groundLevel) {
        player.y = result.groundLevel - player.size * verticalAdjustment;
        player.isOnGround = true;
        player.isJumping = false;
        player.canJump = true;
        player.velocidadVertical = 0;
        _eventBus.emit(GameEvents.playerLand);
      } else {
        player.isOnGround = false; // Eliminada la condición de colisiones laterales
      }
    } else {
      player.isOnGround = false;
    }

    // Verificar si el personaje ha caído fuera de la pantalla
    if (player.y > MediaQuery.of(context).size.height) {
      _handleGameOver(false);
    }
  }

  /// Procesa las colisiones detectadas, incluyendo monedas, casa (victoria) y caídas al vacío.
  /// 
  /// @param result Resultado de las colisiones detectadas
  void _handleCollisions(CollisionResult result) {
    // Maneja colisión con la casa (fin del juego)
    if (result.isCollidingWithHouse) {
      _handleGameOver(true);
    }

    // Emitir eventos específicos para cada tipo de colisión
    if (result.isCollidingTop) {
      _eventBus.emit(GameEvents.playerCollisionTop);
    }

    if (result.isCollidingBottom) {
      _eventBus.emit(GameEvents.playerCollisionBottom);
    }

    // Maneja colisiones con monedas
    for (var moneda in result.collidingCoins) {
      if (!moneda.isCollected) {
        // Emitir el evento y dejar que el listener en Player maneje la lógica
        _eventBus.emit(GameEvents.coinCollected, moneda);

        // Actualizar el registro de monedas recogidas (solo la posición)
        setState(() {
          collectedCoinsPositions.add({'x': moneda.x, 'y': moneda.y});
        });
      }
    }

    // Maneja la caída al vacío
    if (result.isInVoid) {
      _handleVoidCollision();
    }
  }

  /// Actualiza la posición del mundo y del jugador basado en el movimiento y estado actual.
  /// 
  /// Gestiona el desplazamiento durante deslizamientos y limita el movimiento durante la calibración.
  /// @param dtSeconds Delta de tiempo en segundos desde el último frame
  /// @param collisionResult Resultado de las colisiones detectadas
  void _updateWorldPosition(double dtSeconds, CollisionResult collisionResult) {
    double personajeCentro = MediaQuery.of(context).size.width * 0.4;

    if (player.isSliding) {
      double desplazamiento =
          (player.isFacingRight ? 1 : -1) *
          player.velocidadBase *
          2.5 *
          dtSeconds;

      player.x = personajeCentro;
      distancia += desplazamiento.abs().round();
    } else if (_currentMovementDirection != 0) {
      // Verificar si estamos en fase de calibración y queremos ir más allá del límite
      bool canMove = true;

      // Si estamos en fase de calibración y vamos a la derecha más allá del límite, no permitir movimiento
      if (!_isFullyWarmedUp &&
          _currentMovementDirection > 0 &&
          worldOffset >= _maxCalibrationOffset) {
        canMove = false;
        // Forzar que el personaje se quede en el límite
        worldOffset = _maxCalibrationOffset;
      }

      player.move(
        canMove ? _currentMovementDirection : 0,
        0,
        groundLevel: collisionResult.groundLevel,
      );

      double velocidadJugador =
          player.velocidadTemp > 0
              ? player.velocidadTemp
              : (player.isCrouching
                  ? player.velocidadBaseAgachado
                  : player.velocidadBase);

      double desplazamiento =
          _currentMovementDirection * velocidadJugador * dtSeconds;
      double limiteIzquierdo = MediaQuery.of(context).size.width * 0.4;

      if ((worldOffset <= minWorldOffset && _currentMovementDirection < 0) ||
          (worldOffset >=
                  (_isFullyWarmedUp ? maxWorldOffset : _maxCalibrationOffset) &&
              _currentMovementDirection > 0)) {
        // Si estamos en el límite de calibración, no permitir movimiento hacia la derecha
        if (!_isFullyWarmedUp && 
            _currentMovementDirection > 0 && 
            worldOffset >= _maxCalibrationOffset) {
          // No permitir movimiento del personaje más allá del límite
          return;
        }
        
        player.x += desplazamiento;
        player.x = player.x.clamp(
          limiteIzquierdo,
          MediaQuery.of(context).size.width - player.size * 0.5,
        );
      } else {
        // Si estamos en fase de calibración y vamos a exceder el límite, no permitirlo
        if (!_isFullyWarmedUp &&
            _currentMovementDirection > 0 &&
            worldOffset + desplazamiento > _maxCalibrationOffset) {
          worldOffset = _maxCalibrationOffset;
        } else if (!_isFullyWarmedUp &&
            _currentMovementDirection < 0 &&
            worldOffset + desplazamiento < minWorldOffset) {
          worldOffset = minWorldOffset;
        } else {
          worldOffset += desplazamiento;
          // Durante la calibración, limitamos el movimiento estrictamente
          if (!_isFullyWarmedUp) {
            worldOffset = worldOffset.clamp(
              minWorldOffset,
              _maxCalibrationOffset,
            );
          } else {
            worldOffset = worldOffset.clamp(
              minWorldOffset,
              maxWorldOffset,
            );
          }
        }
        player.x = personajeCentro;
      }

      distancia += desplazamiento.abs().round();
    } else {
      player.move(0, 0, groundLevel: collisionResult.groundLevel);
    }
  }

  /// Configura los listeners de eventos para controles, colisiones y estados del jugador.
  void _setupEventListeners() {
    _eventBus.on(GameEvents.buttonPressed, (data) {
      if (!mounted) return;
      final type = data['type'] as String;

      setState(() {
        switch (type) {
          case 'jump':
            if (player.canJump && !player.isJumping) {
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
    
    // Añadir listener para actualizar el contador de monedas
    _eventBus.on(GameEvents.coinCollected, (coin) {
      if (!mounted) return;
      final moneda = coin as MonedaBase;

      setState(() {
        if (moneda.valor > 0) {
          monedas += moneda.valor;
        }
        
        // Marcar la moneda como recolectada
        moneda.markAsCollected();
        
        // Aplicar efectos según el tipo de moneda
        if (moneda is MonedaVelocidad) {
          player.powerUp.activarMonedaVelocidad();
          player.velocidadTemp = player.powerUp.velocidadTemp;
        } else if (moneda is MonedaSalto) {
          player.powerUp.activarMonedaSalto(player.isCrouching);
          player.fuerzaSaltoTemp = player.powerUp.fuerzaSaltoTemp;
        }
      });
    });

    // Añadir listener para el progreso del deslizamiento
    _eventBus.on(GameEvents.playerSlideProgress, (data) {
      if (!mounted) return;

      setState(() {
        // Obtener la dirección y el incremento del deslizamiento
        double direccion = data['direccion'] as double;
        double incremento = data['incremento'] as double;

        // Actualizar worldOffset si no estamos en los límites del mundo
        if ((worldOffset > minWorldOffset || direccion > 0) &&
            (worldOffset < maxWorldOffset || direccion < 0)) {
          worldOffset += direccion * incremento;
          worldOffset = worldOffset.clamp(minWorldOffset, maxWorldOffset);
        }

        // Mantener al jugador en el centro
        player.x = MediaQuery.of(context).size.width * 0.4;

        // Actualizar la distancia recorrida
        distancia += incremento.abs().round();
      });
    });

    // Añadir listener para el fin del deslizamiento
    _eventBus.on(GameEvents.playerEndSlide, (_) {
      if (!mounted) return;
      
      setState(() {
        // Asegurarse de que el jugador esté en el centro
        player.x = MediaQuery.of(context).size.width * 0.4;
        
        // Restablecer el estado del joystick si es necesario
        _currentMovementDirection = 0;  // Añadir esta línea para restablecer el joystick
      });
    });
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

              // Barrera visual derecha durante la calibración
              if (!_isFullyWarmedUp)
                Positioned(
                  left:
                      _maxCalibrationOffset -
                      worldOffset +
                      MediaQuery.of(context).size.width * 0.4,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 5,
                    color: Colors.red.withOpacity(0.7),
                  ),
                ),

              _buildControls(),
              _buildStats(),

              // Nuevo indicador para moverse durante la calibración
              if (!_isFullyWarmedUp && !_showReadyMessage)
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'No pasar los limtes de la barra roja hasta que no calibre',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),

              // Mensaje de "¡Listo!" cuando la calibración está completa
              if (_showReadyMessage)
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '¡LISTO!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el fondo estático del juego.
  Widget _buildParallaxBackground() {
    // El fondo debe ocupar toda la pantalla y NO moverse con el worldOffset
    return Positioned.fill(
      child: Image.asset(
        'assets/imagenes/fondo.png',
        fit: BoxFit.cover, // Así el fondo ocupa toda la pantalla sin deformarse
      ),
    );
  }

  /// Construye los objetos del mundo y las monedas no recolectadas.
  Widget _buildWorldObjects() {
    return Stack(
      children: [
        ...mapa.objetos
            .where(
              (objeto) =>
                  // Mostrar todos los objetos independientemente de la fase de calibración
                  objeto is! MonedaNormal &&
                  objeto is! MonedaSalto &&
                  objeto is! MonedaVelocidad,
              )
              .map(
                (objeto) => Stack(
                  children: [
                    // Sprite original
                    Positioned(
                      left: objeto.x - worldOffset,
                      top: objeto.y,
                      child: SizedBox(
                        width: objeto.width,
                        height: objeto.height,
                        child: Image.asset(objeto.sprite, fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ),
              ),
          ...mapa.monedas
              .where(
                (m) => !m.isCollected,
              )
              .map(
                (moneda) => Stack(
                  children: [
                    // Sprite original de la moneda
                    Positioned(
                      left: moneda.x - worldOffset,
                      top: moneda.y,
                      child: SizedBox(
                        width: moneda.width,
                        height: moneda.height,
                        child: Image.asset(moneda.sprite, fit: BoxFit.contain),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  /// Construye el sprite del jugador con la orientación correcta.
  Widget _buildPlayer() {
    return Stack(
      children: [
        // Sprite del jugador
        Positioned(
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
        ),
      ],
    );
  }

  /// Construye los controles de juego (botones de acción y joystick).
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

  /// Construye el panel de estadísticas del jugador (monedas, vida, tiempo).
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

  /// Maneja el intento de salir del juego, preguntando si se desea guardar el progreso.
  /// 
  /// @return Future<bool> que indica si se debe permitir salir (true) o no (false)
  Future<bool> _onWillPop() async {
    isGameActive = false;
    _gameLoopController.stop();

    final shouldSave = await showDialog<bool>(
      context: context,
      barrierDismissible:
          true, // Cambiado a true para permitir cerrar al hacer clic fuera
      builder:
          (context) => AlertDialog(
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
                ),
              ),
        ),
      );
    }
    return true;
  }

  /// Maneja la colisión con el vacío, resultando en game over.
  void _handleVoidCollision() {
    // Caer al vacío siempre resulta en game over
    _handleGameOver(false);
  }

  /// Gestiona el final del juego, ya sea por victoria o derrota.
  /// 
  /// Calcula la puntuación final, actualiza monedas del jugador, guarda el historial
  /// y muestra el diálogo de fin de juego con opciones para continuar.
  /// 
  /// @param victory Indica si el jugador ha ganado (true) o perdido (false)
  void _handleGameOver(bool victory) async {
    isGameActive = false;
    _gameLoopController.stop();
    
    // Emitir evento de fin de juego para detener todos los sonidos
    _eventBus.emit('gameExited');

    // Calcular puntuación basada en monedas y tiempo
    int puntuacionFinal = 0;
    if (victory) {
      // Base: 1000 puntos por victoria
      puntuacionFinal = 1000;
      puntuacionFinal += monedas * 10;
      int bonusTiempo =
          _gameDuration <= 60
              ? 2000
              : _gameDuration <= 120
              ? 1500
              : _gameDuration <= 180
              ? 1000
              : 500;
      puntuacionFinal += bonusTiempo;

      // En caso de victoria, eliminar la partida guardada ya que se completó el nivel
      await PlayerService().deleteSavedGame(widget.userId);

      // Actualizar monedas y guardar progreso
      await PlayerService().updatePlayerCoins(
        userId: widget.userId,
        coinsToAdd: monedas,
      );

      // Guardar el historial de victoria
      await _saveGameProgress(victory: true, score: puntuacionFinal);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => GameOverDialog(
            userId: widget.userId,
            username: widget.username,
            victory: victory,
            coins: monedas,
            score: puntuacionFinal,
            duration: _gameDuration,
            onRetry: () {
              // Navegar a la pantalla de transición en lugar de directamente al juego
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => TransicionGame1(
                    userId: widget.userId,
                    username: widget.username,
                  ),
                  settings: RouteSettings(
                    arguments: {
                      'userId': widget.userId,
                      'username': widget.username,
                    },
                  ),
                ),
              );
            },
            onMenu: () {
              // Solo eliminar la partida guardada si es victoria
              if (victory) {
                PlayerService().deleteSavedGame(widget.userId);
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => MenuInicio(
                        userId: widget.userId,
                        username: widget.username,
                        initialStats: PlayerStats(
                          userId: widget.userId,
                          coins: monedas,
                        ),
                      ),
                ),
              );
            },
            onSaveAndExit: () async {
              // Guardar el progreso actual
              await _saveGameProgress(victory: false, score: puntuacionFinal);
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => MenuInicio(
                        userId: widget.userId,
                        username: widget.username,
                        initialStats: PlayerStats(
                          userId: widget.userId,
                          coins: monedas,
                        ),
                      ),
                ),
              );
            },
          ),
    );
  }

  @override
  void dispose() {
    isGameActive = false;
    _gameLoopController.stop();
    _gameLoopController.dispose();
    _gameTimer.cancel();
    
    // Emitir evento para detener todos los sonidos
    _eventBus.emit('gameExited');
    
    // Liberar recursos del servicio de efectos de sonido
    SoundEffectService().dispose();
    
    // Liberar recursos del jugador
    player.dispose();
    
    // Asegurar que no queden listeners activos
    _eventBus.offAll(GameEvents.buttonPressed);
    _eventBus.offAll(GameEvents.joystickMoved);
    _eventBus.offAll(GameEvents.coinCollected);
    _eventBus.offAll(GameEvents.playerSlideProgress);
    _eventBus.offAll(GameEvents.playerEndSlide);
    
    // Restaurar orientación de pantalla
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Restaurar modo de UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }

  // Método auxiliar para guardar progreso
  /// Guarda el progreso actual del juego en la base de datos.
  /// 
  /// @param victory Indica si se trata de una partida completada con victoria
  /// @param score Puntuación obtenida en la partida
  Future<void> _saveGameProgress({bool victory = false, int score = 0}) async {
    try {
      // Crear una lista de posiciones de monedas recolectadas
      final collectedCoinsPositions =
          mapa.monedas
              .where((m) => m.isCollected)
              .map((m) => {'x': m.x, 'y': m.y})
              .toList();

      String collectedCoinsJson = '';
      try {
        collectedCoinsJson = jsonEncode(collectedCoinsPositions);
      } catch (e) {
        collectedCoinsJson = '[]';
      }

      await PlayerService().saveGameProgress(
        userId: widget.userId,
        gameType: 1,
        score: victory ? score : 0,
        coins: monedas,
        victory: victory,
        duration: _gameDuration,
        worldOffset: worldOffset,
        playerX: player.x,
        playerY: player.y,
        health: vida,
        currentLevel: 1,
        collectedCoinsPositions: collectedCoinsJson,
      );
    } catch (e) {
      debugPrint('Error saving game: $e');
    }
  }
}
