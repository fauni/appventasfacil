import 'package:appventas/services/storage_service.dart';
import 'package:appventas/models/user.dart';
import 'package:appventas/models/sales_person.dart';

class CurrentUserService {
  static User? _currentUser;
  static SalesPerson? _currentSalesPerson;

  // Singleton
  static final CurrentUserService _instance = CurrentUserService._internal();
  factory CurrentUserService() => _instance;
  CurrentUserService._internal();

  // Getters para el usuario y vendedor actual
  User? get currentUser => _currentUser;
  SalesPerson? get currentSalesPerson => _currentSalesPerson;

  // Método para actualizar el usuario actual desde StorageService
  Future<User?> loadCurrentUser() async {
    try {
      _currentUser = await StorageService.getUser();
      _currentSalesPerson = await StorageService.getSalesPerson();
      return _currentUser;
    } catch (e) {
      _currentUser = null;
      _currentSalesPerson = null;
      return null;
    }
  }

  // Método para actualizar el usuario y vendedor en memoria
  void setCurrentUser(User? user, [SalesPerson? salesPerson]) {
    _currentUser = user;
    _currentSalesPerson = salesPerson;
  }

  // Método para limpiar el usuario actual
  void clearCurrentUser() {
    _currentUser = null;
    _currentSalesPerson = null;
  }

  // Método para verificar si el usuario tiene configuración SAP
  bool get hasSapConfiguration => _currentUser?.hasSapConfiguration ?? false;

  // Método para obtener el código de empleado SAP
  int? get employeeCodeSap => _currentUser?.employeeCodeSap;

  // Método para obtener el código de empleado como string
  String get employeeCodeDisplay => _currentUser?.employeeCodeDisplay ?? '';

  // Métodos para obtener información del vendedor SAP
  String get salesPersonName => _currentSalesPerson?.slpName ?? '';
  String get salesPersonDisplayName => _currentSalesPerson?.displayName ?? '';
  bool get hasSalesPersonData => _currentSalesPerson != null;
  
  // Método para obtener el texto que se mostrará en el campo vendedor
  String get salesPersonFieldDisplay {
    if (_currentSalesPerson != null) {
      // Mostrar el displayName completo (ej: "2 - CRISTINA VEREDA")
      return _currentSalesPerson!.displayName;
    }
    return '';
  }
}