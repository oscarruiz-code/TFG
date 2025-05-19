import 'package:oscarruizcode_pingu/dependencias/imports.dart';
import 'package:flutter/services.dart';

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
  int _currentPage = 0;
  static const int _itemsPerPage = 5;

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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

    final int totalPages = (filteredHistory.length / _itemsPerPage).ceil();
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = min(startIndex + _itemsPerPage, filteredHistory.length);
    final currentPageItems = filteredHistory.sublist(startIndex, endIndex);

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: currentPageItems.length,
              itemBuilder: (context, index) {
                return _buildHistoryItem(currentPageItems[index]);
              },
            ),
          ),
          if (totalPages > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                Text(
                  '${_currentPage + 1} / $totalPages',
                  style: const TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onPressed: _currentPage < totalPages - 1
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),
        ],
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
          Row(
            children: [
              Text(
                score['username'] ?? 'Usuario',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${score['score']} puntos',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                _formatDuration(score['duration']),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> game) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(0, 32, 96, 1),
            Color.fromRGBO(0, 48, 135, 1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Puntuación: ${game['score']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(game['duration']),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(game['played_at']),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (game['is_saved'] == true)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white24,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Game1(
                                userId: widget.userId,
                                savedGameData: game,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Continuar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () async {
                          await _playerStatsService.deleteSavedGame(widget.userId);
                          setState(() {
                            _gameHistoryFuture = _playerStatsService.getGameHistory(widget.userId);
                          });
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Eliminar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue is DateTime) {
      return '${dateValue.day}/${dateValue.month}/${dateValue.year}';
    } else if (dateValue is String) {
      final date = DateTime.parse(dateValue);
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'Fecha no válida';
  }
}