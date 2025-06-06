import 'package:oscarruizcode_pingu/dependencias/imports.dart';

void main() {
  runApp(const MyApp());
}

/// Widget principal de la aplicación.
///
/// Configura el tema y la pantalla inicial de la aplicación.
/// Establece [LogoScreen] como la pantalla de inicio.
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pingu Game',
      debugShowCheckedModeBanner: false,
      home: const LogoScreen(),
    );
  }
}