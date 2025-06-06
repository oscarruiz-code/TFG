/// Clase que representa un administrador del sistema.
///
/// Los administradores tienen acceso completo a la gestión del sistema
/// y pueden realizar todas las operaciones administrativas.
class Admin {
  final int? id;
  final String username;
  final String email;
  final String password;
  bool isActive;

  /// Crea una nueva instancia de administrador.
  ///
  /// Parámetros:
  /// * [id] - Identificador único del administrador, puede ser nulo para nuevos registros.
  /// * [username] - Nombre de usuario del administrador.
  /// * [email] - Correo electrónico del administrador.
  /// * [password] - Contraseña del administrador (idealmente ya cifrada).
  /// * [isActive] - Indica si la cuenta está activa. Por defecto es true.
  Admin({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.isActive = true,
  });

  /// Indica que un Admin puede gestionar todos los aspectos del sistema.
  ///
  /// Este método puede ser sobrescrito por subclases para limitar permisos.
  bool canManageAll() => true;

  /// Crea un objeto Admin a partir de un mapa de datos.
  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id'] != null ? int.parse(map['id'].toString()) : null,
      username: map['username'].toString(),
      email: map['email'].toString(),
      password: map['password'].toString(),
      isActive: map['is_active'] == 1,
    );
  }

  /// Convierte el objeto Admin a un mapa para almacenamiento en base de datos.
  ///
  /// Los valores booleanos se convierten a enteros (0/1) para compatibilidad con SQL.
  /// Establece el rol como 'admin'.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'is_active': isActive ? 1 : 0,
      'role': 'admin'
    };
  }
}