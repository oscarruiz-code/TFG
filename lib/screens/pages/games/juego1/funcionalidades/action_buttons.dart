import 'package:flutter/material.dart';

/// Widget que implementa los botones de acción para el control del juego.
///
/// Proporciona tres botones interactivos para las acciones principales del jugador:
/// saltar, deslizarse y agacharse. Los botones están dispuestos en una configuración
/// ergonómica para facilitar el acceso durante el juego.
class ActionButtons extends StatelessWidget {
  /// Callback que se ejecuta cuando el jugador presiona el botón de salto.
  final VoidCallback onJump;
  
  /// Callback que se ejecuta cuando el jugador presiona el botón de deslizamiento.
  final VoidCallback onSlide;
  
  /// Callback que se ejecuta cuando el jugador presiona el botón para agacharse.
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

  /// Construye un botón de acción individual con el aspecto visual definido.
  ///
  /// @param onTap Función que se ejecuta cuando se presiona el botón.
  /// @param icon Icono que se muestra en el botón.
  /// @param color Color base del botón.
  /// @return Un widget GestureDetector configurado como botón de acción.
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