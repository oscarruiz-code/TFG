import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;

  Future<void> playBackgroundMusic() async {
      await _audioPlayer.setSource(AssetSource('sonidos/musica.mp3'));
      await _audioPlayer.resume();
  }

  Future<void> stopBackgroundMusic() async {
    await _audioPlayer.stop();
  }

  Future<void> toggleSound() async {
    _isMuted = !_isMuted;
    if (_isMuted) {
      await stopBackgroundMusic();
    } else {
      await playBackgroundMusic();
    }
  }

  bool get isMuted => _isMuted;
}