class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final String type;
  final int? employeeCodeSap;
  final String? almacenCode;
  final String? userSap;
  final String? passwordSap;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.type,
    this.employeeCodeSap,
    this.almacenCode,
    this.userSap,
    this.passwordSap
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      type: json['type'],
      employeeCodeSap: json['employeeCodeSap'],
      almacenCode: json['almacenCode'],
      userSap: json['userSap'],
      passwordSap: json['passwordSap'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'type': type,
      'employeeCodeSap': employeeCodeSap,
      'almacenCode': almacenCode,
      'userSap': userSap,
      'passwordSap': passwordSap,
    };
  }

  // Método de conveniencia para verificar si tiene configuración SAP
  bool get hasSapConfiguration => employeeCodeSap != null && employeeCodeSap! > 0;
  
  // Método para obtener el código de empleado como string para mostrar
  String get employeeCodeDisplay => employeeCodeSap?.toString() ?? '';
}


  