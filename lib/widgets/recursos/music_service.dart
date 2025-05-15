import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;

  Future<void> playBackgroundMusic() async {
    try {
      await _audioPlayer.setSource(AssetSource('sonidos/musica.mp3'))
          .timeout(const Duration(seconds: 5)); // Add timeout
      await _audioPlayer.resume()
          .timeout(const Duration(seconds: 3)); // Add timeout
    } catch (e) {
      _isMuted = true;
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _audioPlayer.stop()
          .timeout(const Duration(seconds: 3)); // Add timeout
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

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

  bool get isMuted => _isMuted;
}