/// Clase que representa un usuario en el sistema.
///
/// Almacena la información básica de un usuario, incluyendo credenciales
/// de acceso y estado de la cuenta. Proporciona métodos para convertir
/// entre objetos User y mapas para persistencia en base de datos.
class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  bool isBlocked;
  bool isActive;
  String role;

  /// Crea una nueva instancia de usuario.
  ///
  /// Parámetros:
  /// * [id] - Identificador único del usuario, puede ser nulo para nuevos usuarios.
  /// * [username] - Nombre de usuario, debe ser único en el sistema.
  /// * [email] - Correo electrónico del usuario, debe ser único.
  /// * [password] - Contraseña del usuario (idealmente ya cifrada).
  /// * [isBlocked] - Indica si el usuario está bloqueado. Por defecto es false.
  /// * [isActive] - Indica si la cuenta está activa. Por defecto es true.
  /// * [role] - Rol del usuario en el sistema. Por defecto es 'user'.
  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.isBlocked = false,
    this.isActive = true,
    this.role = 'user',
  });

  /// Convierte el objeto User a un mapa para almacenamiento en base de datos.
  ///
  /// Los valores booleanos se convierten a enteros (0/1) para compatibilidad con SQL.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'is_blocked': isBlocked ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'role': role
    };
  }

  /// Crea un objeto User a partir de un mapa de datos.
  ///
  /// Utilizado principalmente para convertir resultados de consultas de base de datos
  /// en objetos User.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] != null ? int.parse(map['id'].toString()) : null,
      username: map['username'].toString(),
      email: map['email'].toString(),
      password: map['password'].toString(),
      isBlocked: map['is_blocked'] == 1,
      isActive: map['is_active'] == 1,
      role: map['role'].toString(),
    );
  }
}
