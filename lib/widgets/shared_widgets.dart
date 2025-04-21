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
    return Material(
      color: const Color.fromRGBO(0, 32, 96, 1),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: const BorderSide(color: Color.fromRGBO(0, 0, 255, 0.3)),
          ),
        ),
        child: Row(
          children: [
            Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 5),
                Text(
                  '${playerStats.coins}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 15),
                const Text(
                  '🎟️',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 5),
                Text(
                  '${playerStats.ticketsGame2}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
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
    return Material(
      color: const Color.fromRGBO(0, 32, 96, 1),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            top: const BorderSide(color: Color.fromRGBO(0, 0, 255, 0.3)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => pageController.animateToPage(0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () => pageController.animateToPage(1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
            ),
            IconButton(
              icon: const Icon(Icons.store, color: Colors.white),
              onPressed: () => pageController.animateToPage(2,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
            ),
          ],
        ),
      ),
    );
  }
}