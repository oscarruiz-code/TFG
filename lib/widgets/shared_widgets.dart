import 'package:flutter/material.dart';
import '../servicios/entity/player.dart';

class SharedTopBar extends StatelessWidget {
  final String username;
  final PlayerStats playerStats;

  const SharedTopBar({
    super.key,
    required this.username,
    required this.playerStats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.blue, blurRadius: 10)],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.yellow),
              const SizedBox(width: 5),
              Text(
                '${playerStats.coins}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(width: 15),
              const Icon(Icons.confirmation_number, color: Colors.green),
              const SizedBox(width: 5),
              Text(
                '${playerStats.ticketsGame2}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SharedBottomNav extends StatelessWidget {
  final PageController pageController;

  const SharedBottomNav({
    super.key,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => pageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white, size: 32),
            onPressed: () => pageController.animateToPage(
              1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.store, color: Colors.white),
            onPressed: () => pageController.animateToPage(
              2,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}