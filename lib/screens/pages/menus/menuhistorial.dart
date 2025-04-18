import 'package:flutter/material.dart';
import 'package:oscarruizcode_pingu/servicios/sevices/player_service.dart';

class MenuHistorial extends StatefulWidget {
  final int userId;
  const MenuHistorial({super.key, required this.userId});

  @override
  State<MenuHistorial> createState() => _MenuHistorialState();
}

class _MenuHistorialState extends State<MenuHistorial> {
   final PlayerService _playerStatsService = PlayerService();
  int _selectedGameType = 1; // 1 para Game1, 2 para Game2

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Historial de Partidas'),
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildGameSelector(),
            _buildTopScores(),
            const Divider(color: Colors.white30),
            _buildGameHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
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
      onTap: () => setState(() => _selectedGameType = gameType),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
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

  Widget _buildTopScores() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _playerStatsService.getTopScores(widget.userId, _selectedGameType),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final scores = snapshot.data!;
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
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
              ...scores.map((score) => _buildScoreItem(score)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameHistory() {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _playerStatsService.getGameHistory(widget.userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final history = snapshot.data!
              .where((game) => game['game_type'] == _selectedGameType)
              .toList();

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final game = history[index];
              return _buildHistoryItem(game);
            },
          );
        },
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
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
    );
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