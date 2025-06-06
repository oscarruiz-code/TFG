import 'package:oscarruizcode_pingu/dependencias/imports.dart';
import 'package:flutter/services.dart';

class MenuInicio extends StatefulWidget {
  final int userId;
  final String username;
  final PlayerStats initialStats;

  const MenuInicio({
    super.key, 
    required this.userId,
    required this.username,
    required this.initialStats,
  });

  @override
  State<MenuInicio> createState() => _MenuInicioState();
}

class _MenuInicioState extends State<MenuInicio> {
  final PlayerService _playerService = PlayerService();
  final MusicService _musicService = MusicService();
  final PageController _pageController = PageController(initialPage: 1);
  late Stream<PlayerStats> _statsStream;

  @override
  void initState() {
    super.initState();
    // Forzar orientación vertical al entrar al menú de inicio
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Eliminar esta línea que detiene el video
    // VideoBackground.disposeVideo();
    _statsStream = Stream.periodic(const Duration(seconds: 1))
      .asyncMap((_) => _playerService.getPlayerStats(widget.userId));
    _musicService.playBackgroundMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/imagenes/fondo.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: StreamBuilder<PlayerStats>(
          stream: _statsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final playerStats = snapshot.data!;
            
            return PageView(
              controller: _pageController,
              children: [
                MenuOpciones(
                  userId: widget.userId,
                  username: widget.username,
                  pageController: _pageController,
                  playerStats: playerStats,
                ),
                _buildMainPage(playerStats),
                MenuTienda(
                  userId: widget.userId,
                  username: widget.username,
                  pageController: _pageController,
                  playerStats: playerStats,
                ),
                MenuHistorial( // Add MenuHistorial here
                  userId: widget.userId,
                  username: widget.username,
                  pageController: _pageController,
                  playerStats: playerStats,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainPage(PlayerStats playerStats) {
    return SafeArea(
      child: Column(
        children: [
          SharedTopBar(
            username: widget.username,
            playerStats: playerStats,
          ),
          const Spacer(),
          // Zona de vitrina para el sprite y futuros skins
          Container(
            height: 120,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/personajes/principal/andar/andar1.png',
              width: 100,
              height: 100,
            ),
          ),
          const SizedBox(height: 30), // Aumenta el espacio entre el sprite y los botones
          _buildGameAndHistoryButtons(playerStats),
          const Spacer(),
          SharedBottomNav(pageController: _pageController),
        ],
      ),
    );
  }

  Widget _buildGameAndHistoryButtons(PlayerStats playerStats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGameButtonWithLabel(
          icon: Icons.videogame_asset,
          label: 'Game 1',
          onPressed: () async {
            try {

              final savedGame = await _playerService.loadGameState(widget.userId, 1);
              if (savedGame != null) {
                if (!mounted) return;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color.fromRGBO(0, 32, 96, 1),
                    title: const Text('Partida Guardada', 
                      style: TextStyle(color: Colors.white)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¿Deseas continuar la partida anterior o iniciar una nueva?',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Progreso guardado:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Monedas: ${savedGame['coins_collected']}',
                          style: TextStyle(color: Colors.white.withOpacity(0.8)),
                        ),
                        Text(
                          'Duración: ${_formatDuration(savedGame['duration'])}',
                          style: TextStyle(color: Colors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Game1(
                                userId: widget.userId,
                                username: widget.username,
                                savedGameData: savedGame,
                              ),
                            ),
                          );
                        },
                        child: const Text('Continuar', 
                          style: TextStyle(color: Colors.blue)),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            await _playerService.deleteGameSave(widget.userId, 1);
                            if (!mounted) return;
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransicionGame1(
                                  userId: widget.userId,
                                  username: widget.username,
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error al eliminar la partida guardada'),
                              ),
                            );
                          }
                        },
                        child: const Text('Nueva Partida', 
                          style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransicionGame1(
                      userId: widget.userId,
                      username: widget.username,
                    ),
                  ),
                );
              }
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error al cargar la partida guardada'),
                ),
              );
            }
          },
        ),
        _buildGameButtonWithLabel(
          icon: Icons.videogame_asset_outlined,
          label: 'Game 2',
          onPressed: () async {
            if (playerStats.ticketsGame2 > 0) {
              await _playerService.updateTicketsGame2(widget.userId, playerStats.ticketsGame2 - 1);
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Game2()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Necesitas un ticket para jugar Game 2')),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildGameButtonWithLabel({required IconData icon, required String label, required VoidCallback onPressed}) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: GlassContainer(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(15),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 40),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

  // Función para formatear la duración en formato mm:ss
  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }