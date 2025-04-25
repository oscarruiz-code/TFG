import 'package:oscarruizcode_pingu/dependencias/imports.dart';

void main() {
  runApp(const MyApp());
}

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
