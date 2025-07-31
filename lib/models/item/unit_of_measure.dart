import 'package:equatable/equatable.dart';

class UnitOfMeasure extends Equatable {
  final int uomEntry;
  final String uomCode;
  final String uomName;
  final double baseQty;
  final double altQty;
  final bool isDefault;
  final String itemCode;

  const UnitOfMeasure({
    required this.uomEntry,
    required this.uomCode,
    required this.uomName,
    required this.baseQty,
    required this.altQty,
    required this.isDefault,
    required this.itemCode,
  });

  factory UnitOfMeasure.fromJson(Map<String, dynamic> json) {
    return UnitOfMeasure(
      uomEntry: json['uomEntry'] ?? 0,
      uomCode: json['uomCode'] ?? '',
      uomName: json['uomName'] ?? '',
      baseQty: (json['baseQty'] ?? 1).toDouble(),
      altQty: (json['altQty'] ?? 1).toDouble(),
      isDefault: json['isDefault'] ?? false,
      itemCode: json['itemCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uomEntry': uomEntry,
      'uomCode': uomCode,
      'uomName': uomName,
      'baseQty': baseQty,
      'altQty': altQty,
      'isDefault': isDefault,
      'itemCode': itemCode,
    };
  }

  String get displayText => '$uomCode - $uomName';
  String get displayShort => uomCode;

  @override
  List<Object?> get props => [uomEntry, uomCode, uomName, baseQty, altQty, isDefault, itemCode];
}