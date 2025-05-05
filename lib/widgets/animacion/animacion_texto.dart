import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class TextoAnimado extends StatefulWidget {
  final String text;
  final TextStyle style;

  const TextoAnimado({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<TextoAnimado> createState() => _TextoAnimadoState();
}

class _TextoAnimadoState extends State<TextoAnimado> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }
}
