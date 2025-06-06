import 'package:oscarruizcode_pingu/dependencias/imports.dart';

/// Widget que muestra un video de fondo con un controlador compartido.
///
/// Implementa un patrón singleton para el controlador de video, permitiendo
/// precargar y compartir una única instancia del video en toda la aplicación,
/// optimizando así el uso de recursos.
class VideoBackground extends StatefulWidget {
  const VideoBackground({super.key});

  static VideoPlayerController? _sharedController;
  static bool _isInitialized = false;
  
  /// Precarga el video de fondo para su uso posterior.
  ///
  /// Inicializa el controlador compartido si aún no está inicializado.
  /// Configura el video para reproducción en bucle y sin sonido.
  /// Retorna true si la inicialización fue exitosa, false en caso contrario.
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

  /// Inicia la reproducción del video si está inicializado.
  static Future<void> playVideo() async {
    if (_isInitialized && _sharedController != null) {
      await _sharedController!.play();
    }
  }

  /// Libera los recursos del controlador de video compartido.
  static void disposeVideo() {
    _sharedController?.dispose();
    _sharedController = null;
    _isInitialized = false;
  }

  /// Obtiene el controlador de video compartido.
  ///
  /// Retorna null si el controlador no está inicializado.
  static VideoPlayerController? getController() {
    return _sharedController;
  }

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

/// Estado interno del widget VideoBackground.
///
/// Gestiona la visualización del video de fondo con ajuste de tamaño
/// y una capa semitransparente superpuesta.
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