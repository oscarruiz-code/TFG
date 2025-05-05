import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class Game2 extends StatefulWidget {
  final int? userId;
  
  const Game2({super.key, this.userId});

  @override
  State<Game2> createState() => _Game2State();
}

class _Game2State extends State<Game2> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Modo Batalla - En desarrollo'),
      ),
    );
  }
}