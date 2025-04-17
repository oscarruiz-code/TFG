import 'package:mysql1/mysql1.dart';
import 'package:flutter/foundation.dart';  // Agregamos esta importación

class DatabaseConnection {
  static Future<MySqlConnection> getConnection() async {
    try {
      final settings = ConnectionSettings(
        host: 'localhost',  // Cambiado de '127.0.0.1' a 'localhost'
        port: 3306,
        user: 'root',
        password: '',
        db: 'icebergs_db',
        timeout: const Duration(seconds: 10)  // Reducido el timeout
      );

      debugPrint('Intentando conectar a MySQL...');
      var connection = await MySqlConnection.connect(settings);
      debugPrint('Conexión exitosa a MySQL');
      return connection;
    } catch (e) {
      debugPrint('Error de conexión MySQL: $e');
      rethrow;
    }
  }
}