import 'package:mysql1/mysql1.dart';
import 'package:flutter/foundation.dart';

class DatabaseConnection {
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