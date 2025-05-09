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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TransicionGame1()),
            );
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
        _buildHistoryButtonWithLabel(playerStats),
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

  Widget _buildHistoryButtonWithLabel(PlayerStats playerStats) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: GlassContainer(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuHistorial(
                        userId: widget.userId,
                        username: widget.username,
                        playerStats: playerStats,
                        pageController: _pageController,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(15),
                child: Center(
                  child: Icon(Icons.history, color: Colors.white, size: 40),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Historial',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}