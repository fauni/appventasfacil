import 'package:equatable/equatable.dart';

class UserSerie extends Equatable {
  final int id;
  final int idUsuario;
  final String idSerie;
  final DateTime? createdAt;
  
  // Datos de SAP (tabla NNM1)
  final int? series;
  final String? seriesName;
  final int? objectCode;
  final String? indicator;
  final int? nextNumber;
  final String? prefix;
  final String? suffix;

  const UserSerie({
    required this.id,
    required this.idUsuario,
    required this.idSerie,
    this.createdAt,
    this.series,
    this.seriesName,
    this.objectCode,
    this.indicator,
    this.nextNumber,
    this.prefix,
    this.suffix,
  });

  factory UserSerie.fromJson(Map<String, dynamic> json) {
    return UserSerie(
      id: json['id'] ?? 0,
      idUsuario: json['idUsuario'] ?? 0,
      idSerie: json['idSerie'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      // Datos de SAP
      series: json['series'],
      seriesName: json['seriesName'],
      objectCode: json['objectCode'],
      indicator: json['indicator'],
      nextNumber: json['nextNumber'],
      prefix: json['prefix'],
      suffix: json['suffix'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idUsuario': idUsuario,
      'idSerie': idSerie,
      'createdAt': createdAt?.toIso8601String(),
      'series': series,
      'seriesName': seriesName,
      'objectCode': objectCode,
      'indicator': indicator,
      'nextNumber': nextNumber,
      'prefix': prefix,
      'suffix': suffix,
    };
  }

  // Propiedades calculadas
  String get displayName => seriesName != null && seriesName!.isNotEmpty
      ? '$idSerie - $seriesName'
      : idSerie;

  String get nextDocumentNumber => prefix != null && nextNumber != null
      ? '${prefix ?? ''}${nextNumber.toString().padLeft(6, '0')}${suffix ?? ''}'
      : '';

  // Override de == y hashCode para comparación correcta
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSerie &&
        other.id == id &&
        other.idUsuario == idUsuario &&
        other.idSerie == idSerie;
  }

  @override
  int get hashCode => Object.hash(id, idUsuario, idSerie);

  @override
  List<Object?> get props => [
    id, idUsuario, idSerie, createdAt, series, seriesName, 
    objectCode, indicator, nextNumber, prefix, suffix
  ];

  @override
  String toString() => 'UserSerie(id: $id, idUsuario: $idUsuario, idSerie: $idSerie, seriesName: $seriesName)';
}