import 'package:oscarruizcode_pingu/dependencias/imports.dart';

/// Clase utilitaria para gestionar la conexión a la base de datos MySQL.
///
/// Proporciona un método estático para obtener una conexión a la base de datos
/// alojada en Clever Cloud, con manejo de errores integrado.
class DatabaseConnection {
  /// Establece y retorna una conexión a la base de datos MySQL.
  ///
  /// Configura los parámetros de conexión y establece la conexión.
  /// Registra mensajes de depuración sobre el estado de la conexión.
  /// En caso de error, registra el error y lo propaga.
  ///
  /// Retorna un objeto MySqlConnection que puede ser utilizado para
  /// realizar operaciones en la base de datos.
  static Future<MySqlConnection> getConnection() async {
    try {
      final settings = ConnectionSettings(
        host: 'bepsnkpq9ccmcvndmyjc-mysql.services.clever-cloud.com',
        port: 3306,
        user: 'uel3r1fi9jrcvkff',
        password: '8MbOCWddYEdl6qtneB8X',
        db: 'bepsnkpq9ccmcvndmyjc'
      );

      debugPrint('Connecting to Clever Cloud MySQL...');
      var connection = await MySqlConnection.connect(settings);
      debugPrint('Connection successful!');
      return connection;
    } catch (e) {
      debugPrint('Connection error: $e');
      rethrow;
    }
  }
}