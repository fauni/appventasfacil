import 'package:equatable/equatable.dart';

class TfeUnitOfMeasure extends Equatable {
  final String code;
  final String name;

  const TfeUnitOfMeasure({
    required this.code,
    required this.name,
  });

  factory TfeUnitOfMeasure.fromJson(Map<String, dynamic> json) {
    return TfeUnitOfMeasure(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }

  String get displayText => '$code - $name';
  String get displayShort => code;

  @override
  List<Object?> get props => [code, name];
}