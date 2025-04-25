import 'package:oscarruizcode_pingu/dependencias/imports.dart';

class SubAdmin extends Admin {
  SubAdmin({
    super.id,
    required super.username,
    required super.email,
    required super.password,
    super.isActive = true,
  });

  @override
  bool canManageAll() => false;

  bool canManageUser(User user) {
    return user is! Admin;  // Puede manejar todo excepto admins
  }

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['role'] = 'subadmin';
    return map;
  }

  factory SubAdmin.fromMap(Map<String, dynamic> map) {
    return SubAdmin(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      isActive: map['is_active'] == 1,
    );
  }
}