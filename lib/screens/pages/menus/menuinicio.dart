import 'package:oscarruizcode_pingu/servicios/entity/player.dart';
import 'package:oscarruizcode_pingu/widgets/video_background.dart';
import 'package:flutter/material.dart';
import 'package:oscarruizcode_pingu/servicios/sevices/player_service.dart';
import 'package:oscarruizcode_pingu/widgets/shared_widgets.dart';
import 'menuopcion.dart';
import 'menutienda.dart';
import 'menuhistorial.dart';
import '../games/game1.dart';
import '../games/game2.dart';
import 'package:oscarruizcode_pingu/widgets/music_service.dart';

class MenuInicio extends StatefulWidget {
  final int userId;
  final String username;  // Add this line
  const MenuInicio({
    super.key, 
    required this.userId,
    required this.username,  // Add this line
  });

  @override
  State<MenuInicio> createState() => _MenuInicioState();
}

class _MenuInicioState extends State<MenuInicio> {
  final PlayerService _playerService = PlayerService();
  final MusicService _musicService = MusicService();
  final PageController _pageController = PageController(initialPage: 1);
  late PlayerStats _playerStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    VideoBackground.disposeVideo();
    _loadPlayerStats();
    _musicService.playBackgroundMusic();
  }

  @override
  void dispose() {
    _musicService.stopBackgroundMusic();
    super.dispose();
  }

  Future<void> _loadPlayerStats() async {
    _playerStats = await _playerService.getPlayerStats(widget.userId);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/imagenes/fondo.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _pageController,
          children: [
            MenuOpciones(
              userId: widget.userId,
              username: widget.username,
              pageController: _pageController,
              playerStats: _playerStats,
            ),
            _buildMainPage(_playerStats),
            MenuTienda(
              userId: widget.userId,
              username: widget.username,
              pageController: _pageController,
              playerStats: _playerStats,
            ),
          ],
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
          _buildHistoryButton(),
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
        _buildGameButton('Game 2', () {
          if (playerStats.ticketsGame2 > 0) {
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
      child: Material(
        color: const Color.fromRGBO(0, 32, 96, 1), // Dark navy blue
        elevation: 4,
        borderRadius: BorderRadius.circular(15),
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
    );
  }

  Widget _buildHistoryButton() {
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
                builder: (context) => MenuHistorial(userId: widget.userId),
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