import 'package:flutter/services.dart';
import 'dart:convert';
import '../../../../../../dependencias/imports.dart';

class GameInitializer {
  // Variables que necesitamos para la inicialización
  final BuildContext context;
  final TickerProvider vsync;
  final Map<String, dynamic>? savedGameData;
  final Function setState;
  final Function(AnimationController) onGameLoopControllerCreated;
  final Function(double)? onJoystickMoved; // Nuevo callback para el joystick
  
  // Variables del juego que se inicializarán
  late double minWorldOffset;
  late double maxWorldOffset;
  // Eliminada la variable _maxCalibrationOffset que no se usa
  late Player player;
  late Mapa1 mapa;
  late ColisionManager _colisionManager;
  late Timer _gameTimer;
  late bool _isInitialized;
  late bool _isFullyWarmedUp;
  late int _gameDuration;
  late double worldOffset;
  late int monedas;
  late int vida;
  
  // Event bus para comunicación
  final GameEventBus _eventBus = GameEventBus();
  
  GameInitializer({
    required this.context,
    required this.vsync,
    required this.savedGameData,
    required this.setState,
    required this.onGameLoopControllerCreated,
    required double calibrationOffset,
    this.onJoystickMoved, // Nuevo parámetro opcional
  }) {
    // Eliminada la asignación a _maxCalibrationOffset
    _isInitialized = false;
    _isFullyWarmedUp = false;
    _gameDuration = 0;
    worldOffset = 0.0;
    monedas = 0;
    vida = 100;
  }
  
  void initializeGame() {
    // Configurar orientación de pantalla
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Inicializar los límites del mundo
    minWorldOffset = 0.0;
    maxWorldOffset = 6000.0;

    List<Map<String, double>>? savedCoinsPositions;
    if (savedGameData != null) {
      String? savedPositions;
      if (savedGameData!['collected_coins_positions'] != null) {
        var blob = savedGameData!['collected_coins_positions'];
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
    
    setupEventListeners();

    // Cargar datos guardados si existen
    if (savedGameData != null) {
      worldOffset =
          (savedGameData!['world_offset'] as num?)?.toDouble() ?? 0.0;
      monedas = savedGameData!['coins_collected'] as int? ?? 0;
      vida = savedGameData!['health'] as int? ?? 100;
      _gameDuration = savedGameData!['duration'] as int? ?? 0;

      // Inicializar el jugador con la posición guardada
      player = Player(
        x: (savedGameData!['position_x'] as num?)?.toDouble() ?? 0.0,
        y: (savedGameData!['position_y'] as num?)?.toDouble() ?? 200.0,
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
        if (savedGameData == null) {
          player.x = size.width * 0.4;
        }

        // Crear el controlador de animación y pasarlo de vuelta a Game1
        final gameLoopController = AnimationController(
          vsync: vsync,
          duration: const Duration(
            milliseconds: 16,
          ),
        );
        gameLoopController.repeat();
        onGameLoopControllerCreated(gameLoopController);

        _isInitialized = true;
      });
    });

    // Inicializar el timer con el tiempo guardado ya cargado anteriormente
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Solo incrementar si el juego está activo Y completamente inicializado Y completamente calibrado
      if (_isInitialized && _isFullyWarmedUp) {
        setState(() {
          _gameDuration++;
        });
      }
    });
  }

  void setupEventListeners() {
    _eventBus.on(GameEvents.buttonPressed, (data) {
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
      final dx = data['dx'] as double;

      setState(() {
        // Usar el callback si está definido
        if (onJoystickMoved != null) {
          onJoystickMoved!(dx);
        }
      });
    });
    
    // Añadir listener para actualizar el contador de monedas
    _eventBus.on(GameEvents.coinCollected, (coin) {
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

        // Aquí necesitarás una forma de actualizar distancia en Game1
        // Podrías usar un callback o devolver el valor
      });
    });

    // Añadir listener para el fin del deslizamiento
    _eventBus.on(GameEvents.playerEndSlide, (_) {
      setState(() {
        // Asegurarse de que el jugador esté en el centro
        player.x = MediaQuery.of(context).size.width * 0.4;
        
        // Aquí necesitarás una forma de actualizar _currentMovementDirection en Game1
        // Podrías usar un callback o devolver el valor
      });
    });
  }
  
  // Método para limpiar recursos
  void dispose() {
    _gameTimer.cancel();
  }
  
  // Getters para acceder a las variables inicializadas
  bool get isInitialized => _isInitialized;
  bool get isFullyWarmedUp => _isFullyWarmedUp;
  int get gameDuration => _gameDuration;
  ColisionManager get colisionManager => _colisionManager;
}