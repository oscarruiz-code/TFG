import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBackground extends StatefulWidget {
  const VideoBackground({super.key});

  static VideoPlayerController? _sharedController;
  static bool _isInitialized = false;
  
  static Future<bool> preloadVideo() async {
    if (_isInitialized) return true;
    
    try {
      _sharedController = VideoPlayerController.asset('assets/videos/fondo_inicio.mp4');
      await _sharedController!.initialize();
      await _sharedController!.setLooping(true);
      await _sharedController!.setVolume(0.0);
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing video: $e');
      return false;
    }
  }

  static Future<void> playVideo() async {
    if (_isInitialized && _sharedController != null) {
      await _sharedController!.play();
    }
  }

  static void disposeVideo() {
    _sharedController?.dispose();
    _sharedController = null;
    _isInitialized = false;
  }

  static VideoPlayerController? getController() {
    return _sharedController;
  }

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  @override
  Widget build(BuildContext context) {
    if (!VideoBackground._isInitialized || 
        VideoBackground._sharedController == null || 
        !VideoBackground._sharedController!.value.isInitialized) {
      return Container(color: Colors.black);
    }

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: VideoBackground._sharedController!.value.size.width,
              height: VideoBackground._sharedController!.value.size.height,
              child: VideoPlayer(VideoBackground._sharedController!),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 0, 0, 0.2),
            ),
          ),
        ],
      ),
    );
  }
}