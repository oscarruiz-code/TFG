import 'package:oscarruizcode_pingu/dependencias/imports.dart';

/// Clase que representa un administrador con permisos limitados.
///
/// Extiende la clase Admin pero restringe ciertos permisos de administración.
/// Los SubAdmin pueden gestionar usuarios regulares pero no otros administradores.
class SubAdmin extends Admin {
  /// Crea una nueva instancia de SubAdmin.
  ///
  /// Hereda los parámetros de Admin y mantiene los mismos requisitos.
  SubAdmin({
    super.id,
    required super.username,
    required super.email,
    required super.password,
    super.isActive = true,
  });

  /// Indica que un SubAdmin no puede gestionar todos los aspectos del sistema.
  ///
  /// Sobrescribe el método de Admin para limitar permisos.
  @override
  bool canManageAll() => false;

  /// Determina si este SubAdmin puede gestionar un usuario específico.
  ///
  /// Retorna true si el usuario no es un Admin, false en caso contrario.
  bool canManageUser(User user) {
    return user is! Admin;  // Puede manejar todo excepto admins
  }

  /// Convierte el objeto SubAdmin a un mapa para almacenamiento en base de datos.
  ///
  /// Sobrescribe el método de Admin para establecer el rol como 'subadmin'.
  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['role'] = 'subadmin';
    return map;
  }

  /// Crea un objeto SubAdmin a partir de un mapa de datos.
  factory SubAdmin.fromMap(Map<String, dynamic> map) {
    return SubAdmin(
      id: map['id'] != null ? int.parse(map['id'].toString()) : null,
      username: map['username'].toString(),
      email: map['email'].toString(),
      password: map['password'].toString(),
      isActive: map['is_active'] == 1,
    );
  }
}