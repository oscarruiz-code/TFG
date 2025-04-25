import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class MenuHistorial extends StatefulWidget {
  final int userId;
  final String username;  // Agregar username
  final PlayerStats playerStats;  // Agregar playerStats
  final PageController pageController;  // Agregar pageController

  const MenuHistorial({
    super.key, 
    required this.userId,
    required this.username,  // Agregar este parámetro
    required this.playerStats,  // Agregar este parámetro
    required this.pageController,  // Agregar este parámetro
  });

  @override
  State<MenuHistorial> createState() => _MenuHistorialState();
}

class _MenuHistorialState extends State<MenuHistorial> {
  final PlayerService _playerStatsService = PlayerService();
  int _selectedGameType = 1;
  late Future<List<Map<String, dynamic>>> _gameHistoryFuture;
  late Future<List<Map<String, dynamic>>> _topScoresFuture;

  @override
  void initState() {
    super.initState();
    // Preload data when the widget initializes
    _gameHistoryFuture = _playerStatsService.getGameHistory(widget.userId);
    _topScoresFuture = _playerStatsService.getTopScores(widget.userId, _selectedGameType);
  }

  void _refreshData() {
    setState(() {
      _topScoresFuture = _playerStatsService.getTopScores(widget.userId, _selectedGameType);
    });
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
        body: SafeArea(
          child: Column(
            children: [
              SharedTopBar(
                username: widget.username,
                playerStats: widget.playerStats,
              ),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: Future.wait([_gameHistoryFuture, _topScoresFuture]),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final gameHistory = snapshot.data![0] as List<Map<String, dynamic>>;
                    final topScores = snapshot.data![1] as List<Map<String, dynamic>>;

                    return Column(
                      children: [
                        _buildGameSelector(),
                        _buildTopScoresWidget(topScores),
                        const Divider(color: Colors.white30),
                        _buildGameHistoryWidget(gameHistory),
                      ],
                    );
                  },
                ),
              ),
              SharedBottomNav(pageController: widget.pageController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopScoresWidget(List<Map<String, dynamic>> scores) {
    final filteredScores = scores.where((score) => 
      score['game_type'] == _selectedGameType).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 32, 96, 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mejores Puntuaciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...filteredScores.map((score) => _buildScoreItem(score)),
        ],
      ),
    );
  }

  Widget _buildGameHistoryWidget(List<Map<String, dynamic>> history) {
    final filteredHistory = history
        .where((game) => game['game_type'] == _selectedGameType)
        .toList();

    return Expanded(
      child: ListView.builder(
        itemCount: filteredHistory.length,
        itemBuilder: (context, index) {
          return _buildHistoryItem(filteredHistory[index]);
        },
      ),
    );
  }

  Widget _buildGameSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 32, 96, 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSelectorButton('Game 1', 1),
          ),
          Expanded(
            child: _buildSelectorButton('Game 2', 2),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButton(String title, int gameType) {
    final isSelected = _selectedGameType == gameType;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedGameType = gameType);
        _refreshData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromRGBO(0, 0, 255, 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreItem(Map<String, dynamic> score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${score['score']} puntos',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            _formatDuration(score['duration']),
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> game) {
    return Material(  // Wrap with Material for elevation
      elevation: 4,
      color: const Color.fromRGBO(0, 32, 96, 1),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puntuación: ${game['score']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Duración: ${_formatDuration(game['duration'])}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            Text(
              _formatDate(game['played_at']),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ));
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
  }
}