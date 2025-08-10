// lib/core/app_colors.dart
import 'package:flutter/material.dart';

/// Sistema de colores simplificado y parametrizable para SAP Sales App
/// 
/// Para cambiar el tema de toda la aplicación, solo modifica las 4 variables _primaryBase,
/// _secondaryBase, _backgroundBase y _surfaceBase al inicio de esta clase.
class AppColors {
  
  // ==================== CONFIGURACIÓN PRINCIPAL ====================
  // 🎯 CAMBIAR ESTOS 4 VALORES PARA MODIFICAR TODA LA APP
  
  /// Color primario principal (Azul SAP por defecto)
  /// Este color se usa en: AppBar, botones principales, FAB, elementos destacados
  static const Color _primaryBase = Color(0xFF1976D2);
  
  /// Color secundario 
  /// Este color se usa en: botones secundarios, elementos de apoyo, iconos secundarios
  static const Color _secondaryBase = Color(0xFF42A5F5);
  
  /// Color de fondo principal
  /// Este color se usa en: fondo de pantallas, áreas de contenido
  static const Color _backgroundBase = Color(0xFFF5F5F5);
  
  /// Color de superficie (cards, containers, formularios)
  /// Este color se usa en: cards, dialogs, bottom sheets, formularios
  static const Color _surfaceBase = Color(0xFFFFFFFF);
  
  // ==================== COLORES PRINCIPALES ====================
  
  /// Color primario (botones principales, AppBar, etc.)
  static Color get primary => _primaryBase;
  
  /// Texto sobre color primario (siempre legible)
  static Color get onPrimary => Colors.white;
  
  /// Color secundario (elementos destacados, botones secundarios)
  static Color get secondary => _secondaryBase;
  
  /// Texto sobre color secundario (siempre legible)
  static Color get onSecondary => Colors.white;
  
  /// Color de fondo principal de la aplicación
  static Color get background => _backgroundBase;
  
  /// Texto sobre fondo (siempre legible)
  static Color get onBackground => Colors.black87;
  
  /// Color de superficie (cards, containers, formularios)
  static Color get surface => _surfaceBase;
  
  /// Texto sobre superficie (siempre legible)
  static Color get onSurface => Colors.black87;
  
  // ==================== COLORES DE ESTADO ====================
  
  /// Color de éxito (confirmaciones, completado)
  static Color get success => const Color(0xFF4CAF50);
  
  /// Texto sobre color de éxito
  static Color get onSuccess => Colors.white;
  
  /// Color de error (errores, cancelaciones, eliminaciones)
  static Color get error => const Color(0xFFE53935);
  
  /// Texto sobre color de error
  static Color get onError => Colors.white;
  
  /// Color de advertencia (alertas, pendientes)
  static Color get warning => const Color(0xFFFF9800);
  
  /// Texto sobre color de advertencia
  static Color get onWarning => Colors.white;
  
  /// Color de información (tips, ayuda, información adicional)
  static Color get info => const Color(0xFF2196F3);
  
  /// Texto sobre color de información
  static Color get onInfo => Colors.white;
  
  // ==================== COLORES AUXILIARES ====================
  
  /// Color de texto secundario (subtítulos, descripciones, placeholders)
  static Color get textSecondary => Colors.grey[600]!;
  
  /// Color de bordes, divisores y líneas de separación
  static Color get border => Colors.grey[300]!;
  
  /// Color de sombras para elevaciones y efectos
  static Color get shadow => Colors.black.withOpacity(0.1);
  
  /// Color para elementos deshabilitados
  static Color get disabled => Colors.grey[400]!;
  
  /// Color de texto para elementos deshabilitados
  static Color get onDisabled => Colors.grey[600]!;
  
  /// Color de superficie variante (fondos alternativos, áreas destacadas)
  static Color get surfaceVariant => _lighten(_backgroundBase, 0.05);
  
  /// Texto sobre superficie variante
  static Color get onSurfaceVariant => Colors.grey[700]!;
  
  // ==================== VARIANTES DE COLORES PRINCIPALES ====================
  
  /// Versión clara del color primario (hover, estados activos)
  static Color get primaryLight => _lighten(primary, 0.2);
  
  /// Versión oscura del color primario (pressed, estados activos)
  static Color get primaryDark => _darken(primary, 0.2);
  
  /// Versión muy clara del color primario (fondos sutiles, highlights)
  static Color get primaryVeryLight => primary.withOpacity(0.1);
  
  /// Versión clara del color secundario
  static Color get secondaryLight => _lighten(secondary, 0.2);
  
  /// Versión oscura del color secundario
  static Color get secondaryDark => _darken(secondary, 0.2);
  
  /// Versión muy clara del color secundario
  static Color get secondaryVeryLight => secondary.withOpacity(0.1);
  
  // ==================== COLORES ESPECÍFICOS DE MÓDULOS ====================
  
  /// Color para módulo de Cotizaciones
  static Color get quotations => primary;
  
  /// Color para módulo de Órdenes de Venta (Púrpura distintivo)
  static Color get salesOrders => const Color(0xFF7B1FA2);
  
  /// Color para módulo de Ventas (Verde distintivo)
  static Color get sales => const Color(0xFF388E3C);
  
  /// Color para Dashboard (usa el color primario)
  static Color get dashboard => primary;
  
  /// Color para módulo de Clientes
  static Color get customers => const Color(0xFF1976D2);
  
  /// Color para módulo de Productos/Items
  static Color get items => const Color(0xFF6D4C41);
  
  /// Color para Reportes
  static Color get reports => const Color(0xFF5E35B1);
  
  // ==================== ESTADOS DE DOCUMENTOS SAP ====================
  
  /// Color para documentos abiertos (Open)
  static Color get statusOpen => info;
  
  /// Color para documentos cerrados (Closed)
  static Color get statusClosed => success;
  
  /// Color para documentos cancelados (Cancelled)
  static Color get statusCancelled => error;
  
  /// Color para documentos pendientes (Pending)
  static Color get statusPending => warning;
  
  /// Color para borradores (Draft)
  static Color get statusDraft => Colors.grey[600]!;
  
  /// Color para documentos aprobados
  static Color get statusApproved => const Color(0xFF0D7377);
  
  /// Color para documentos rechazados
  static Color get statusRejected => const Color(0xFFD32F2F);
  
  // ==================== GRADIENTES PREDEFINIDOS ====================
  
  /// Gradiente principal de la aplicación
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradiente para cards destacados
  static LinearGradient get cardGradient => LinearGradient(
    colors: [surface, surfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  /// Gradiente para botones principales
  static LinearGradient get buttonGradient => LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  /// Gradiente para headers y secciones destacadas
  static LinearGradient get headerGradient => LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ==================== MÉTODOS UTILITARIOS ====================
  
  /// Obtener color de estado según string
  /// Ideal para estados de documentos SAP
  static Color getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'open':
      case 'o':
      case 'abierto':
      case 'activo':
        return statusOpen;
      case 'closed':
      case 'c':
      case 'cerrado':
      case 'completado':
        return statusClosed;
      case 'cancelled':
      case 'canceled':
      case 'x':
      case 'cancelado':
        return statusCancelled;
      case 'pending':
      case 'p':
      case 'pendiente':
      case 'en proceso':
        return statusPending;
      case 'draft':
      case 'd':
      case 'borrador':
      case 'temporal':
        return statusDraft;
      case 'approved':
      case 'aprobado':
        return statusApproved;
      case 'rejected':
      case 'rechazado':
        return statusRejected;
      default:
        return textSecondary;
    }
  }
  
  /// Obtener color de módulo según string
  /// Útil para iconos y elementos de navegación
  static Color getModuleColor(String module) {
    switch (module.toLowerCase().trim()) {
      case 'quotations':
      case 'cotizaciones':
      case 'quotes':
        return quotations;
      case 'sales_orders':
      case 'ordenes':
      case 'orders':
        return salesOrders;
      case 'sales':
      case 'ventas':
        return sales;
      case 'dashboard':
      case 'inicio':
        return dashboard;
      case 'customers':
      case 'clientes':
        return customers;
      case 'items':
      case 'productos':
      case 'inventory':
        return items;
      case 'reports':
      case 'reportes':
        return reports;
      default:
        return primary;
    }
  }
  
  /// Obtener color apropiado de texto para un fondo dado
  /// Retorna blanco o negro según el contraste
  static Color getContrastColor(Color backgroundColor) {
    // Calcular luminancia del color de fondo
    final luminance = backgroundColor.computeLuminance();
    // Si es oscuro, usar texto claro; si es claro, usar texto oscuro
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
  
  /// Obtener un color con opacidad específica
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }
  
  // ==================== MÉTODOS PRIVADOS PARA MANIPULACIÓN DE COLOR ====================
  
  /// Aclarar un color (hacer más brillante)
  static Color _lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1, 'Amount debe estar entre 0.0 y 1.0');
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Oscurecer un color (hacer más oscuro)
  static Color _darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1, 'Amount debe estar entre 0.0 y 1.0');
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}

// ==================== ESQUEMAS DE COLORES PREDEFINIDOS ====================

/// Clase con esquemas de colores predefinidos para cambiar fácilmente el tema
/// Solo copia y pega los valores en las variables _primaryBase, etc.
class ColorSchemes {
  
  /// Esquema SAP Azul (por defecto)
  static const Map<String, Color> sapBlue = {
    'primary': Color(0xFF1976D2),
    'secondary': Color(0xFF42A5F5),
    'background': Color(0xFFF5F5F5),
    'surface': Color(0xFFFFFFFF),
  };
  
  /// Esquema Verde Corporativo
  static const Map<String, Color> corporateGreen = {
    'primary': Color(0xFF388E3C),
    'secondary': Color(0xFF66BB6A),
    'background': Color(0xFFF1F8E9),
    'surface': Color(0xFFFFFFFF),
  };
  
  /// Esquema Púrpura Moderno
  static const Map<String, Color> modernPurple = {
    'primary': Color(0xFF7B1FA2),
    'secondary': Color(0xFF9C27B0),
    'background': Color(0xFFF3E5F5),
    'surface': Color(0xFFFFFFFF),
  };
  
  /// Esquema Naranja Energético
  static const Map<String, Color> energyOrange = {
    'primary': Color(0xFFFF6F00),
    'secondary': Color(0xFFFF8F00),
    'background': Color(0xFFFFF3E0),
    'surface': Color(0xFFFFFFFF),
  };
  
  /// Esquema Azul Marino Profesional
  static const Map<String, Color> navyProfessional = {
    'primary': Color(0xFF0D47A1),
    'secondary': Color(0xFF1976D2),
    'background': Color(0xFFF3F8FF),
    'surface': Color(0xFFFFFFFF),
  };
  
  /// Esquema Verde Agua Relajante
  static const Map<String, Color> tealCalm = {
    'primary': Color(0xFF00695C),
    'secondary': Color(0xFF26A69A),
    'background': Color(0xFFE0F2F1),
    'surface': Color(0xFFFFFFFF),
  };
  
  /// Esquema Rojo Corporativo
  static const Map<String, Color> corporateRed = {
    'primary': Color(0xFFD32F2F),
    'secondary': Color(0xFFEF5350),
    'background': Color(0xFFFFF5F5),
    'surface': Color(0xFFFFFFFF),
  };
  
  /// Esquema Gris Minimalista
  static const Map<String, Color> minimalistGray = {
    'primary': Color(0xFF455A64),
    'secondary': Color(0xFF78909C),
    'background': Color(0xFFFAFAFA),
    'surface': Color(0xFFFFFFFF),
  };
}

// ==================== EXTENSIONES ÚTILES ====================

/// Extensión para facilitar el uso de colores en widgets
extension ColorExtensions on Color {
  /// Convertir a MaterialColor para usar en primarySwatch
  MaterialColor get materialColor {
    return MaterialColor(value, {
      50: AppColors.withOpacity(this, 0.1),
      100: AppColors.withOpacity(this, 0.2),
      200: AppColors.withOpacity(this, 0.3),
      300: AppColors.withOpacity(this, 0.4),
      400: AppColors.withOpacity(this, 0.6),
      500: this,
      600: AppColors._darken(this, 0.1),
      700: AppColors._darken(this, 0.2),
      800: AppColors._darken(this, 0.3),
      900: AppColors._darken(this, 0.4),
    });
  }
  
  /// Obtener color de texto apropiado (blanco o negro) para este color de fondo
  Color get appropriateTextColor {
    return AppColors.getContrastColor(this);
  }
  
  /// Versión clara de este color
  Color lighten([double amount = 0.1]) => AppColors._lighten(this, amount);
  
  /// Versión oscura de este color
  Color darken([double amount = 0.1]) => AppColors._darken(this, amount);
}

/// Extensión para usar colores desde el contexto de widgets
extension AppColorsContext on BuildContext {
  /// Acceso rápido a los colores de la app
  AppColors get appColors => AppColors();
  
  /// Acceso directo al color primario
  Color get primaryColor => AppColors.primary;
  
  /// Acceso directo al color de fondo
  Color get backgroundColor => AppColors.background;
  
  /// Acceso directo al color de superficie
  Color get surfaceColor => AppColors.surface;
  
  /// Acceso directo al color de texto principal
  Color get textColor => AppColors.onSurface;
  
  /// Acceso directo al color de texto secundario
  Color get secondaryTextColor => AppColors.textSecondary;
}