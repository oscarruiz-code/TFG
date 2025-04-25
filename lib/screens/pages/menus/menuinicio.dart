import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class MenuInicio extends StatefulWidget {
  final int userId;
  final String username;
  final PlayerStats initialStats;  // Agregar este parámetro

  const MenuInicio({
    super.key, 
    required this.userId,
    required this.username,
    required this.initialStats,  // Agregar este parámetro
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
          _buildGameButtons(playerStats),
          const SizedBox(height: 20),
          _buildHistoryButton(playerStats), 
          const Spacer(),
          SharedBottomNav(pageController: _pageController),
        ],
      ),
    );
  }

  Widget _buildGameButtons(PlayerStats playerStats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGameButton('Game 1', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Game1()),
          );
        }),
        _buildGameButton('Game 2', () async {
          if (playerStats.ticketsGame2 > 0) {
            // Descontar un ticket antes de iniciar el juego
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
        }),
      ],
    );
  }

  Widget _buildGameButton(String title, VoidCallback onPressed) {
    return SizedBox(
      width: 150,
      height: 150,
      child: GlassContainer(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(15),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryButton(PlayerStats playerStats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: Material(
        color: const Color.fromRGBO(0, 32, 96, 1),
        elevation: 4,
        borderRadius: BorderRadius.circular(15),
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
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Historial de Partidas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}