import 'package:oscarruizcode_pingu/dependencias/imports.dart';

/// Servicio que gestiona los efectos de sonido para las animaciones del juego.
///
/// Implementa el patrón Singleton para garantizar una única instancia
/// que maneja todos los efectos de sonido durante el ciclo de vida del juego.
class SoundEffectService {
  // Implementación Singleton
  static final SoundEffectService _instance = SoundEffectService._internal();
  factory SoundEffectService() => _instance;
  SoundEffectService._internal();

  // Reproductor de audio para efectos de sonido
  final Map<String, AudioPlayer> _audioPlayers = {};
  bool _isMuted = false;
  bool _isGameActive = false;
  
  // Rutas a los archivos de sonido
  static const Map<String, String> _soundPaths = {
    'music': 'sonidos/musicajuego.mp3',
    'jump': 'sonidos/efectos/salto.mp3',
    'coin': 'sonidos/efectos/moneda.mp3',
  };

  /// Inicializa el servicio y configura los listeners de eventos.
  ///
  /// Debe llamarse cuando se inicia el juego para registrar todos los
  /// manejadores de eventos necesarios.
  void initialize() {
    final GameEventBus eventBus = GameEventBus();
    
    // Registrar listeners para eventos del juego
    eventBus.on(GameEvents.playerJump, (_) => playSound('jump'));
    eventBus.on(GameEvents.coinCollected, (_) => playSound('coin'));
    eventBus.on(GameEvents.playerLand, (_) => stopSound('jump'));
    
    // Eventos para controlar la música de fondo
    eventBus.on('gameStarted', (_) => gameStarted());
    eventBus.on('gameExited', (_) => gameExited());
    eventBus.on(GameEvents.gameOver, (_) => gameExited());
  }

  /// Método llamado cuando se inicia el juego
  void gameStarted() {
    _isGameActive = true;
    playBackgroundMusic();
  }

  /// Método llamado cuando se sale del juego
  void gameExited() {
    _isGameActive = false;
    stopAllSounds(); // Cambiado para detener todos los sonidos, no solo la música
  }

  /// Reproduce la música de fondo del juego.
  Future<void> playBackgroundMusic() async {
    if (!_isGameActive || _isMuted) return;
    
    try {
      // Crear un nuevo reproductor para la música si no existe
      _audioPlayers['music'] ??= AudioPlayer();
      
      // Verificar si la música ya está reproduciéndose
      final playerState = _audioPlayers['music']!.state;
      if (playerState == PlayerState.playing) return;
      
      // Configurar el origen del audio
      await _audioPlayers['music']!.setSource(
        AssetSource(_soundPaths['music']!)
      ).timeout(const Duration(seconds: 2));
      
      // Reproducir en bucle
      await _audioPlayers['music']!.setReleaseMode(ReleaseMode.loop);
      
      // Reproducir la música
      await _audioPlayers['music']!.resume()
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      print('Error reproduciendo música de fondo: $e');
    }
  }

  /// Reproduce un efecto de sonido específico.
  ///
  /// @param soundName Nombre del sonido a reproducir (debe existir en _soundPaths).
  /// @return Future que se completa cuando el sonido comienza a reproducirse.
  Future<void> playSound(String soundName) async {
    if (_isMuted || !_soundPaths.containsKey(soundName)) return;
    if (soundName == 'music' && !_isGameActive) return;

    try {
      // Para sonidos que pueden sonar múltiples veces simultáneamente (como monedas)
      if (soundName == 'coin') {
        // Limitar el número de reproductores de monedas a 3 para evitar sobrecarga
        const int maxCoinPlayers = 3;
        
        // Buscar un reproductor de moneda que ya haya terminado
        String? availableId;
        int coinPlayerCount = 0;
        
        // Contar reproductores de monedas activos y buscar uno disponible
        for (var entry in _audioPlayers.entries) {
          if (entry.key.startsWith('coin_')) {
            coinPlayerCount++;
            if (entry.value.state == PlayerState.completed || 
                entry.value.state == PlayerState.stopped) {
              availableId = entry.key;
              break;
            }
          }
        }
        
        // Si hay demasiados reproductores activos, no crear uno nuevo
        if (coinPlayerCount >= maxCoinPlayers && availableId == null) {
          return; // Omitir este sonido para evitar sobrecarga
        }
        
        // Crear un ID único o reutilizar uno existente
        final uniqueId = availableId ?? 'coin_${DateTime.now().millisecondsSinceEpoch}';
        
        // Crear un nuevo reproductor o reutilizar uno existente
        _audioPlayers[uniqueId] ??= AudioPlayer();
        
        // Configurar el origen del audio
        await _audioPlayers[uniqueId]!.setSource(
          AssetSource(_soundPaths[soundName]!)
        ).timeout(const Duration(milliseconds: 500)); // Reducir el timeout
        
        // Configurar modo de reproducción
        await _audioPlayers[uniqueId]!.setReleaseMode(ReleaseMode.release);
        
        // Reproducir el sonido
        await _audioPlayers[uniqueId]!.resume()
            .timeout(const Duration(milliseconds: 500)); // Reducir el timeout
            
        // Eliminar el reproductor después de que termine el sonido
        _audioPlayers[uniqueId]!.onPlayerComplete.listen((_) {
          // No eliminar el reproductor, solo marcarlo como completado para reutilizarlo
        });
        
        return;
      }
      
      // Para otros sonidos, usar el comportamiento normal
      // Crear un nuevo reproductor para este sonido si no existe
      _audioPlayers[soundName] ??= AudioPlayer();
      
      // Configurar el origen del audio
      await _audioPlayers[soundName]!.setSource(
        AssetSource(_soundPaths[soundName]!)
      ).timeout(const Duration(seconds: 2));
      
      // Configurar modo de reproducción (loop para sonidos continuos)
      if (soundName == 'music') {
        await _audioPlayers[soundName]!.setReleaseMode(ReleaseMode.loop);
      } else {
        await _audioPlayers[soundName]!.setReleaseMode(ReleaseMode.release);
      }
      
      // Reproducir el sonido
      await _audioPlayers[soundName]!.resume()
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      print('Error reproduciendo sonido $soundName: $e');
    }
  }

  /// Detiene un efecto de sonido específico.
  ///
  /// @param soundName Nombre del sonido a detener.
  Future<void> stopSound(String soundName) async {
    if (!_audioPlayers.containsKey(soundName)) return;
    
    try {
      await _audioPlayers[soundName]!.stop()
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      print('Error deteniendo sonido $soundName: $e');
    }
  }

  /// Detiene todos los efectos de sonido actualmente en reproducción.
  Future<void> stopAllSounds() async {
    for (var player in _audioPlayers.values) {
      try {
        await player.stop().timeout(const Duration(seconds: 2));
      } catch (e) {
        print('Error deteniendo sonido: $e');
      }
    }
  }

  /// Activa o desactiva todos los efectos de sonido.
  void toggleMute() {
    _isMuted = !_isMuted;
    
    if (_isMuted) {
      stopAllSounds();
    } else if (_isGameActive) {
      // Si se activa el sonido y estamos en el juego, reproducir música de fondo
      playBackgroundMusic();
    }
  }

  /// Libera los recursos utilizados por el servicio.
  ///
  /// Debe llamarse cuando se cierra el juego para liberar memoria.
  Future<void> dispose() async {
    await stopAllSounds();
    
    for (var player in _audioPlayers.values) {
      await player.dispose();
    }
    _audioPlayers.clear();
  }

  /// Indica si los efectos de sonido están silenciados.
  bool get isMuted => _isMuted;
}