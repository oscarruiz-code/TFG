import 'package:oscarruizcode_pingu/dependencias/imports.dart';

/// Servicio singleton para gestionar la música de fondo de la aplicación.
///
/// Proporciona métodos para reproducir, detener y alternar el estado de la música,
/// con manejo de errores y tiempos de espera para evitar bloqueos.
class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;

  /// Reproduce la música de fondo desde el archivo de recursos.
  ///
  /// Establece tiempos de espera para evitar bloqueos en caso de error.
  /// Si ocurre un error, establece el estado como silenciado.
  Future<void> playBackgroundMusic() async {
    try {
      await _audioPlayer.setSource(AssetSource('sonidos/musica.mp3'))
          .timeout(const Duration(seconds: 5));
      await _audioPlayer.resume()
          .timeout(const Duration(seconds: 3)); 
    } catch (e) {
      _isMuted = true;
    }
  }

  /// Detiene la reproducción de la música de fondo.
  ///
  /// Incluye manejo de errores y tiempo de espera para evitar bloqueos.
  Future<void> stopBackgroundMusic() async {
    try {
      await _audioPlayer.stop()
          .timeout(const Duration(seconds: 3)); 
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  /// Alterna entre los estados de silencio y reproducción.
  ///
  /// Invierte el estado actual de _isMuted y llama al método correspondiente.
  Future<void> toggleSound() async {
    _isMuted = !_isMuted;
    try {
      if (_isMuted) {
        await stopBackgroundMusic();
      } else {
        await playBackgroundMusic();
      }
    } catch (e) {
      print('Error toggling sound: $e');
    }
  }

  /// Indica si el sonido está actualmente silenciado.
  bool get isMuted => _isMuted;
}