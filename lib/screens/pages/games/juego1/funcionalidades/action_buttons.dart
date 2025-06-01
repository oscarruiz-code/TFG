import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onJump;
  final VoidCallback onSlide;
  final VoidCallback onCrouch;

  const ActionButtons({
    super.key,
    required this.onJump,
    required this.onSlide,
    required this.onCrouch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildActionButton(
          onTap: onJump,
          icon: Icons.close,
          color: Colors.blue,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildActionButton(
              onTap: onCrouch,
              icon: Icons.change_history,
              color: Colors.blue,
            ),
            const SizedBox(width: 20),
            _buildActionButton(
              onTap: onSlide,
              icon: Icons.circle_outlined,
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        // Solo ejecutar la acción si no hay otra animación en curso
        onTap();
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.7),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 30,
        ),
      ),
    );
  }
}