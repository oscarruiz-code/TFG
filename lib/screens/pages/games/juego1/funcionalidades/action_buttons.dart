import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onJump;
  final VoidCallback onSlide;

  const ActionButtons({
    Key? key,
    required this.onJump,
    required this.onSlide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          onTap: onJump,
          icon: Icons.keyboard_arrow_up,
          color: Colors.blue,
        ),
        const SizedBox(width: 20),
        _buildActionButton(
          onTap: onSlide,
          icon: Icons.keyboard_arrow_down,
          color: Colors.blue,
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
      onTapDown: (_) => onTap(),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}