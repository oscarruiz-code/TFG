import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBackground extends StatefulWidget {
  const VideoBackground({super.key});

  static VideoPlayerController? _sharedController;
  
  static Future<bool> preloadVideo() async {
    try {
      if (_sharedController == null) {
        _sharedController = VideoPlayerController.asset('assets/videos/fondo_inicio.mp4');
        await _sharedController!.initialize();
        await _sharedController!.setLooping(true);
        await _sharedController!.setVolume(0.0);
        await _sharedController!.play();
        return true;
      }
      return _sharedController!.value.isInitialized;
    } catch (e) {
      debugPrint('Error initializing video: $e');
      return false;
    }
  }

  static void disposeVideo() {
    try {
      _sharedController?.dispose();
      _sharedController = null;
    } catch (e) {
      debugPrint('Error disposing video: $e');
    }
  }

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _checkVideoStatus();
  }

  void _checkVideoStatus() {
    if (VideoBackground._sharedController?.value.isInitialized ?? false) {
      if (mounted) {
        setState(() {
          _isReady = true;
        });
        VideoBackground._sharedController?.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || VideoBackground._sharedController == null || 
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
              color: Color.fromRGBO(0, 0, 0, 0.2),
            ),
          ),
        ],
      ),
    );
  }
}